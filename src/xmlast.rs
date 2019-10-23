use crate::ast::VerilogIoQualifier;
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
    UnpackArray {},
}

#[derive(Copy, Clone, Eq, PartialEq, Debug)]
pub enum XmlVarUsage {
    Unused,
    Clocked,
    Combinatorial,
}

pub struct XmlVariable {
    pub name: String,
    pub dir: VerilogIoQualifier,
    pub xtype: Rc<XmlType>,
    pub usage: XmlVarUsage,
}

#[derive(Default)]
pub struct XmlMetadata {
    pub types: HashMap<i32, Rc<XmlType>>,
    pub top_module: String,
    pub variables: HashMap<String, Rc<RefCell<XmlVariable>>>,
    pub variables_by_xml: HashMap<String, Rc<RefCell<XmlVariable>>>,
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
    parse_top_module(&xml, &mut meta)?;
    Ok(meta)
}

fn xerror(msg: &str) -> Error {
    Error::new(ErrorKind::InvalidInput, msg.to_owned())
}

fn xserror(msg: String) -> Error {
    Error::new(ErrorKind::InvalidInput, msg)
}

fn parse_top_module(xml: &Element, meta: &mut XmlMetadata) -> Result<()> {
    let xnetlist = xml
        .children()
        .find(|p| p.name() == "netlist")
        .ok_or_else(|| xerror("Missing <netlist>"))?;
    let mut xmodule = None;
    for xmod in xnetlist.children() {
        if xmod.name() != "module" {
            continue;
        }
        if xmod.attr("topModule") != Some("1") {
            continue;
        }
        if xmodule.is_some() {
            return Err(xerror(
                "Verinject supports only one top-level module per file",
            ));
        }
        xmodule = Some(xmod);
    }
    if xmodule.is_none() {
        xmodule = xnetlist.children().find(|e| e.name() == "module");
    }
    let xmodule = xmodule.ok_or_else(|| xerror("No top-level module found"))?;

    parse_m_vars(xmodule, meta)?;
    explore_usages(XmlVarUsage::Unused, xmodule, meta)?;
    Ok(())
}

fn parse_m_vars(xmodule: &Element, meta: &mut XmlMetadata) -> Result<()> {
    for xvar in xmodule.children() {
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
        meta.variables_by_xml.insert(xname, vrc.clone());
        meta.variables.insert(name, vrc);
    }
    Ok(())
}

fn explore_usages(block_kind: XmlVarUsage, elem: &Element, meta: &mut XmlMetadata) -> Result<()> {
    match elem.name() {
        "always" => {
            let always_kind = parse_sentree_kind(elem);
            for child in elem.children() {
                explore_usages(always_kind, child, meta)?;
            }
        }
        "sentree" | "senitem" => {}
        "assigndly" | "assign" => {
            let xref = elem.children().last().unwrap();
            if xref.name() != "varref" {
                return Err(xerror("Invalid XML assign tag"));
            }
            let xname = xref.attr("name").expect("Xml varref with no name");
            let xvar = meta
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
                explore_usages(block_kind, child, meta)?;
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
                let tt_type = XmlType::UnpackArray {};
                meta.types.insert(id, Rc::new(tt_type));
            }
            _ => {
                return Err(xserror(format!("Unsupported XML type: {}", xtype.name())));
            }
        }
    }
    Ok(())
}
