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
        left: i32,
        right: i32,
    },
    MemoryArray1D {
        name: String,
        /// Size of a single word in the array
        left_bits: i32,
        right_bits: i32,
        /// Determines number of blocks in the array
        left_arr: i32,
        right_arr: i32,
    },
}

fn abs_diff(l: i32, r: i32) -> i32 {
    if l < r {
        r - l + 1
    } else {
        l - r + 1
    }
}

fn ilog2_ceil(x: u32) -> u32 {
    let mut r = 0u32;
    while (1u32 << r) < x {
        r += 1;
    }
    r
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

    pub fn is_memory(&self) -> bool {
        match self {
            XmlType::Basic { .. } | XmlType::BasicRange { .. } => false,
            XmlType::MemoryArray1D { .. } => true,
        }
    }

    pub fn word_range(&self) -> (i32, i32) {
        match self {
            XmlType::Basic { .. } => (0, 0),
            XmlType::BasicRange { left, right, .. } => (*left, *right),
            XmlType::MemoryArray1D {
                left_bits,
                right_bits,
                ..
            } => (*left_bits, *right_bits),
        }
    }

    pub fn mem1_range(&self) -> (i32, i32) {
        match self {
            XmlType::Basic { .. } | XmlType::BasicRange { .. } => (0, 0),
            XmlType::MemoryArray1D {
                left_arr,
                right_arr,
                ..
            } => (*left_arr, *right_arr),
        }
    }

    pub fn mem1_addr_bits(&self) -> (i32, i32) {
        let (ml, mr) = self.mem1_range();
        let (al, ar) = (ilog2_ceil(ml as u32) as i32, ilog2_ceil(mr as u32) as i32);
        (al.max(ar) - 1, 0)
    }

    pub fn word_bit_count(&self) -> i32 {
        let (l, r) = self.word_range();
        abs_diff(l, r)
    }

    pub fn mem1_word_count(&self) -> i32 {
        let (l, r) = self.mem1_range();
        abs_diff(l, r)
    }

    pub fn bit_count(&self) -> i32 {
        self.word_bit_count() * self.mem1_word_count()
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
    pub read_count: u32,
    pub write_count: u32,
}

#[derive(Clone)]
pub struct XmlModule {
    pub is_top: bool,
    pub path: String,
    pub variables: HashMap<String, Rc<RefCell<XmlVariable>>>,
    pub variables_by_xml: HashMap<String, Rc<RefCell<XmlVariable>>>,
    pub clock_name: Option<String>,
    pub children: Vec<String>,
    pub previsit_number: i32,
    pub postvisit_number: i32,
    pub own_bits_used: i32,
    pub bits_used: i32,
}

#[derive(Default)]
pub struct XmlMetadata {
    pub types: HashMap<i32, Rc<XmlType>>,
    pub top_module: String,
    pub modules: HashMap<String, Rc<RefCell<XmlModule>>>,
}

fn parse_verilog_num(mut vnum: &str) -> Option<i32> {
    // ignore width specifier
    if let Some(pos) = vnum.find('\'') {
        vnum = &vnum[pos + 1..];
    }
    // ignore signedness
    if vnum.starts_with('s') {
        vnum = &vnum[1..];
    }
    let mut base = match vnum.chars().next().unwrap() {
        'h' | 'H' => 16,
        'o' | 'O' => 8,
        'b' | 'B' => 2,
        'd' | 'D' => 10,
        _ => 0,
    };
    if base != 0 {
        vnum = &vnum[1..];
    } else {
        base = 10;
    }
    let vnum = vnum.replace('_', "");
    i32::from_str_radix(&vnum, base).ok()
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
    calculate_module_params(&meta);
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
    modules_dfs(xml, xcells.children().next().unwrap(), meta, 0).map(|_| ())?;
    Ok(())
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
        let mut xm = XmlModule {
            is_top: number == 0,
            path: mfile,
            variables: Default::default(),
            variables_by_xml: Default::default(),
            clock_name: None,
            children: Vec::new(),
            previsit_number: number,
            postvisit_number: -1,
            own_bits_used: -1,
            bits_used: -1,
        };
        for child in cell.children() {
            if child.name() != "cell" {
                continue;
            }
            xm.children
                .push(child.attr("submodname").unwrap().to_owned());
        }
        if xm.is_top {
            meta.top_module = mname.to_owned();
        }
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
        explore_usages(&mut xmodule, XmlVarUsage::Unused, mnode, false, meta)?;
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
            read_count: 0,
            write_count: 0,
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
    varref_write: bool,
    meta: &mut XmlMetadata,
) -> Result<()> {
    match elem.name() {
        "always" => {
            let always_kind = parse_sentree_kind(elem);
            for child in elem.children() {
                explore_usages(xmodule, always_kind, child, varref_write, meta)?;
            }
        }
        "senitem" => {
            let edge = elem.attr("edgeType");
            if edge != Some("POS") {
                // unsupported: negedge clocks
                return Ok(());
            }
            let vref = elem.children().next();
            if let Some(vref) = vref {
                if vref.name() != "varref" {
                    return Ok(());
                }
                let vname = vref.attr("name").expect("<varref> with no name");
                if vname == "rst" || vname == "rst_n" || vname == "reset" || vname == "reset_n" {
                    // common reset names
                    return Ok(());
                }
                if xmodule.clock_name.is_none() {
                    xmodule.clock_name = Some(vname.to_owned());
                }
            }
        }
        "assigndly" | "assign" => {
            explore_usages(
                xmodule,
                block_kind,
                elem.children().last().unwrap(),
                true,
                meta,
            )?;
            explore_usages(
                xmodule,
                block_kind,
                elem.children().next().unwrap(),
                false,
                meta,
            )?;
        }
        "arraysel" | "sel" => {
            explore_usages(
                xmodule,
                block_kind,
                elem.children().next().unwrap(),
                varref_write,
                meta,
            )?;
            for child in elem.children().skip(1) {
                explore_usages(xmodule, block_kind, child, false, meta)?;
            }
        }
        "varref" => {
            let xname = elem.attr("name").expect("Xml varref with no name");
            let xvar = xmodule
                .variables_by_xml
                .get(xname)
                .expect("Xml varref with unknown variable");
            let mut var = xvar.borrow_mut();
            if varref_write {
                var.write_count += 1;
                if var.usage != XmlVarUsage::Unused && var.usage != block_kind {
                    return Err(xserror(format!(
                        "Variable {} assigned to in both clocked and combinatorial blocks",
                        xname
                    )));
                }
                var.usage = block_kind;
            } else {
                var.read_count += 1;
            }
        }
        _ => {
            for child in elem.children() {
                explore_usages(xmodule, block_kind, child, varref_write, meta)?;
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
    let mut array_types = Vec::new();
    for xtype in xtypetable.children() {
        match xtype.name() {
            "basicdtype" => {
                let id = xtype.attr("id").expect("Malformed xml");
                let id = i32::from_str(id).expect("Malformed xml");
                let name = xtype.attr("name").expect("Malformed xml").into();
                let tt_type = if let Some(left) = xtype.attr("left") {
                    let right = xtype.attr("right").expect("Malformed xml").parse().unwrap();
                    XmlType::BasicRange {
                        name,
                        left: left.parse().unwrap(),
                        right,
                    }
                } else {
                    XmlType::Basic { name }
                };
                meta.types.insert(id, Rc::new(tt_type));
            }
            "unpackarraydtype" => {
                array_types.push(xtype);
            }
            _ => {
                return Err(xserror(format!("Unsupported XML type: {}", xtype.name())));
            }
        }
    }
    for xtype in array_types.into_iter() {
        assert_eq!(xtype.name(), "unpackarraydtype");
        let id_str = xtype.attr("id").expect("Malformed xml");
        let id = i32::from_str(id_str).expect("Malformed xml");
        let subtypeid = i32::from_str(xtype.attr("sub_dtype_id").unwrap()).expect("Malformed xml");
        let word_type = meta.types.get(&subtypeid).unwrap();
        let word_range = word_type.word_range();
        if xtype.children().count() != 1 {
            return Err(xerror("Multi-dimensional arrays not currently supported"));
        }
        let xarange = xtype.children().next().unwrap();
        assert_eq!(xarange.children().count(), 2);
        let xaleft = xarange.children().next().unwrap().attr("name").unwrap();
        let xaright = xarange.children().nth(1).unwrap().attr("name").unwrap();
        let aleft = parse_verilog_num(xaleft).expect("Can't parse <const> integer");
        let aright = parse_verilog_num(xaright).expect("Can't parse <const> integer");
        let tt_type = XmlType::MemoryArray1D {
            name: id_str.to_owned(),
            left_arr: aleft,
            right_arr: aright,
            left_bits: word_range.0,
            right_bits: word_range.1,
        };
        meta.types.insert(id, Rc::new(tt_type));
    }
    Ok(())
}

fn calculate_module_params(meta: &XmlMetadata) {
    let top = meta.modules.get(&meta.top_module).unwrap();
    visit_calc_bits(meta, top);
}

fn visit_calc_bits(meta: &XmlMetadata, module: &RefCell<XmlModule>) -> i32 {
    let module_r = module
        .try_borrow()
        .expect("Module graph contains a cycle - unsupported");
    if module_r.bits_used >= 0 {
        return module_r.bits_used;
    }
    let own_bits: i32 = if module_r.own_bits_used >= 0 {
        module_r.own_bits_used
    } else {
        module_r
            .variables
            .values()
            .filter(|v| v.borrow().usage == XmlVarUsage::Clocked || v.borrow().xtype.is_memory())
            .map(|v| v.borrow().xtype.bit_count())
            .sum()
    };
    let mut other_bits = 0;
    for child_name in module_r.children.iter() {
        let child = meta.modules.get(child_name).unwrap();
        other_bits += visit_calc_bits(meta, child);
    }
    drop(module_r);
    let total_bits = own_bits + other_bits;
    let mut module_w = module.borrow_mut();
    module_w.own_bits_used = own_bits;
    module_w.bits_used = total_bits;
    total_bits
}
