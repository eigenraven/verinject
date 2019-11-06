use crate::lexer::Token;
use crate::lexer::{VerilogIoQualifier, VerilogType};
use minidom::Element;
use std::cell::RefCell;
use std::collections::HashMap;
use std::io::{Error, ErrorKind, Result};
use std::rc::Rc;
use std::str::FromStr;

#[derive(Clone, Eq, PartialEq, Debug)]
pub enum XmlType {
    Basic {
        name: String,
    },
    BasicRange {
        name: String,
        left: String,
        right: String,
    },
    UnpackArray {
        name: String,
        left_bits: String,
        right_bits: String,
        left_arr: String,
        right_arr: String,
    },
}

impl XmlType {
    pub fn create_var<'s>(&self, vtype: VerilogType, name: &str) -> Token<'s> {
        let vt = if vtype == VerilogType::Reg {
            "reg"
        } else {
            "wire"
        };
        match self {
            XmlType::Basic { .. } => Token::inject(format!("{v} {name}", v = vt, name = name)),
            XmlType::BasicRange { left, right, .. } => Token::inject(format!(
                "{v} [{l}:{r}] {name}",
                v = vt,
                l = left,
                r = right,
                name = name
            )),
            _ => unimplemented!(),
        }
    }

    pub fn bit_range(&self) -> (&str, &str) {
        match self {
            XmlType::Basic { .. } => ("0", "0"),
            XmlType::BasicRange { left, right, .. } => (&left, &right),
            XmlType::UnpackArray {
                left_bits,
                right_bits,
                ..
            } => (&left_bits, &right_bits),
        }
    }
}

#[derive(Copy, Clone, Eq, PartialEq, Debug)]
pub enum XmlVarUsage {
    Unused,
    Clocked,
    Combinatorial,
}

#[derive(Clone)]
pub struct XmlVariable {
    pub name: String,
    pub dir: VerilogIoQualifier,
    pub xtype: Rc<XmlType>,
    pub usage: XmlVarUsage,
}

#[derive(Clone)]
pub struct XmlModule {
    pub is_top: bool,
    pub path: String,
    pub variables: HashMap<String, Rc<RefCell<XmlVariable>>>,
    pub variables_by_xml: HashMap<String, Rc<RefCell<XmlVariable>>>,
    pub previsit_number: i32,
    pub postvisit_number: i32,
}

#[derive(Default)]
pub struct XmlMetadata {
    pub types: HashMap<i32, Rc<XmlType>>,
    pub top_module: String,
    pub modules: HashMap<String, Rc<RefCell<XmlModule>>>,
}

pub fn parse_xml_metadata(xml_str: &str) -> Result<XmlMetadata> {
    let xml: Element = xml_str
        .parse()
        .map_err(|_| xerror("Verilator XML not valid"))?;
    let mut meta = XmlMetadata::default();

    if xml.name() != "verilator_xml" {
        return Err(xerror("Verilator XML root tag name not `verilator_xml`"));
    }

    parse_types(&xml, &mut meta)?;
    parse_module_list(&xml, &mut meta)?;
    debug_assert!(meta
        .modules
        .iter()
        .all(|(_, e)| e.borrow().previsit_number >= 0));
    debug_assert!(meta
        .modules
        .iter()
        .all(|(_, e)| e.borrow().postvisit_number >= 0));
    parse_module_nets(&xml, &mut meta)?;
    Ok(meta)
}

fn xerror(msg: &str) -> Error {
    Error::new(ErrorKind::InvalidInput, msg.to_owned())
}

fn xserror(msg: String) -> Error {
    Error::new(ErrorKind::InvalidInput, msg)
}

fn parse_module_list(xml: &Element, meta: &mut XmlMetadata) -> Result<()> {
    let xcells = xml
        .children()
        .find(|p| p.name() == "cells")
        .ok_or_else(|| xerror("Missing <cells>"))?;
    // DFS over cells
    modules_dfs(xml, xcells.children().next().unwrap(), meta, 0).map(|_| ())
}

fn modules_dfs(root: &Element, cell: &Element, meta: &mut XmlMetadata, number: i32) -> Result<i32> {
    let mname = cell
        .attr("submodname")
        .ok_or_else(|| xerror("Missing cells/cell:submodname"))?;
    if !meta.modules.contains_key(mname) {
        let xfiles = root
            .children()
            .find(|p| p.name() == "files")
            .ok_or_else(|| xerror("Missing <files>"))?;
        let mfile = {
            let mfl = cell
                .attr("fl")
                .ok_or_else(|| xerror("Missing cells/cell:fl"))?;
            let mfstr = mfl
                .split_at(mfl.find(|c: char| c.is_ascii_digit()).unwrap())
                .0;
            xfiles
                .children()
                .find(|c| c.attr("id") == Some(mfstr))
                .expect("Unknown path to one of modules")
                .attr("filename")
                .unwrap()
                .to_owned()
        };
        let xm = XmlModule {
            is_top: number == 0,
            path: mfile,
            variables: Default::default(),
            variables_by_xml: Default::default(),
            previsit_number: number,
            postvisit_number: -1,
        };
        meta.modules
            .insert(mname.to_owned(), Rc::new(RefCell::new(xm)));
    }
    // keep track of ordering
    // increases for each new visited child
    let mut new_number = number;
    for child in cell.children() {
        if child.name() != "cell" {
            continue;
        }
        new_number = modules_dfs(root, child, meta, new_number + 1)?;
    }
    let mut xmodule = meta.modules.get_mut(mname).unwrap().borrow_mut();
    xmodule.postvisit_number = new_number;
    debug_assert!(xmodule.postvisit_number >= xmodule.previsit_number);
    Ok(new_number)
}

fn parse_module_nets(xml: &Element, meta: &mut XmlMetadata) -> Result<()> {
    let xnetlist = xml
        .children()
        .find(|p| p.name() == "netlist")
        .ok_or_else(|| xerror("Missing <netlist>"))?;
    for mnode in xnetlist.children() {
        if mnode.name() != "module" {
            continue;
        }
        let mname = mnode
            .attr("origName")
            .ok_or_else(|| xerror("Missing netlist/module:origName"))?;
        let xmodule_rc = meta.modules.get(mname).unwrap().clone();
        let mut xmodule = (&xmodule_rc as &RefCell<XmlModule>).borrow_mut();
        if mnode.attr("topModule") == Some("1") || meta.modules.len() == 1 {
            xmodule.is_top = true;
        }
        parse_m_vars(&mut xmodule, mnode, meta)?;
        explore_usages(&mut xmodule, XmlVarUsage::Unused, mnode, meta)?;
    }
    Ok(())
}

fn parse_m_vars(xmodule: &mut XmlModule, mnode: &Element, meta: &mut XmlMetadata) -> Result<()> {
    for xvar in mnode.children() {
        if xvar.name() != "var" {
            continue;
        }
        let name = xvar
            .attr("origName")
            .or_else(|| xvar.attr("name"))
            .expect("XML Var with no name")
            .to_owned();
        let xname = xvar.attr("name").expect("XML Var with no name").to_owned();
        let xtype_id = xvar.attr("dtype_id").expect("XML Var with no type");
        let xtype_id = i32::from_str(xtype_id).expect("Malformed xml");
        let xtype = meta.types.get(&xtype_id).unwrap().clone();
        let dir = if let Some(xdir) = xvar.attr("dir") {
            match xdir {
                "input" => VerilogIoQualifier::Input,
                "output" => VerilogIoQualifier::Output,
                "inout" => VerilogIoQualifier::InOut,
                _ => VerilogIoQualifier::None,
            }
        } else {
            VerilogIoQualifier::None
        };
        let var = XmlVariable {
            name: name.clone(),
            xtype,
            dir,
            usage: XmlVarUsage::Unused,
        };
        let vrc = Rc::new(RefCell::new(var));
        xmodule.variables_by_xml.insert(xname, vrc.clone());
        xmodule.variables.insert(name, vrc);
    }
    Ok(())
}

fn explore_usages(
    xmodule: &mut XmlModule,
    block_kind: XmlVarUsage,
    elem: &Element,
    meta: &mut XmlMetadata,
) -> Result<()> {
    match elem.name() {
        "always" => {
            let always_kind = parse_sentree_kind(elem);
            for child in elem.children() {
                explore_usages(xmodule, always_kind, child, meta)?;
            }
        }
        "sentree" | "senitem" => {}
        "assigndly" | "assign" => {
            let xref = elem.children().last().unwrap();
            if xref.name() != "varref" {
                return Err(xerror("Invalid XML assign tag"));
            }
            let xname = xref.attr("name").expect("Xml varref with no name");
            let xvar = xmodule
                .variables_by_xml
                .get(xname)
                .expect("Xml varref with unknown variable");
            let mut var = xvar.borrow_mut();
            if var.usage != XmlVarUsage::Unused && var.usage != block_kind {
                return Err(xserror(format!(
                    "Variable {} assigned to in both clocked and combinatorial blocks",
                    xname
                )));
            }
            var.usage = block_kind;
        }
        "instance" => {
            // todo
        }
        _ => {
            for child in elem.children() {
                explore_usages(xmodule, block_kind, child, meta)?;
            }
        }
    }
    Ok(())
}

fn parse_sentree_kind(xalways: &Element) -> XmlVarUsage {
    let sentree = xalways.children().find(|e| e.name() == "sentree");
    match sentree {
        None => XmlVarUsage::Combinatorial,
        Some(sentree) => {
            if sentree.children().any(|e| e.attr("edgeType").is_some()) {
                XmlVarUsage::Clocked
            } else {
                XmlVarUsage::Combinatorial
            }
        }
    }
}

fn parse_types(xml: &Element, meta: &mut XmlMetadata) -> Result<()> {
    let xnetlist = xml
        .children()
        .find(|p| p.name() == "netlist")
        .ok_or_else(|| xerror("Missing <netlist>"))?;
    let xtypetable = xnetlist
        .children()
        .find(|p| p.name() == "typetable")
        .ok_or_else(|| xerror("Missing <typetable>"))?;
    for xtype in xtypetable.children() {
        match xtype.name() {
            "basicdtype" => {
                let id = xtype.attr("id").expect("Malformed xml");
                let id = i32::from_str(id).expect("Malformed xml");
                let name = xtype.attr("name").expect("Malformed xml").into();
                let tt_type = if let Some(left) = xtype.attr("left") {
                    let right = xtype.attr("right").expect("Malformed xml").into();
                    XmlType::BasicRange {
                        name,
                        left: left.into(),
                        right,
                    }
                } else {
                    XmlType::Basic { name }
                };
                meta.types.insert(id, Rc::new(tt_type));
            }
            "unpackarraydtype" => {
                let id = xtype.attr("id").expect("Malformed xml");
                let id = i32::from_str(id).expect("Malformed xml");
                let name = xtype.attr("name").expect("Malformed xml").into();
                let tt_type = XmlType::UnpackArray {
                    name,
                    left_arr: "0".to_owned(),
                    right_arr: "0".to_owned(),
                    left_bits: "0".to_owned(),
                    right_bits: "0".to_owned(),
                };
                meta.types.insert(id, Rc::new(tt_type));
            }
            _ => {
                return Err(xserror(format!("Unsupported XML type: {}", xtype.name())));
            }
        }
    }
    Ok(())
}
