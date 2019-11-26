use crate::xmlast::{XmlMetadata, XmlModule, XmlVarUsage};
use std::fmt::Write;

fn recurse_module(
    meta: &XmlMetadata,
    xmod: &XmlModule,
    mut pstart: i32,
    path: &str,
    map: &mut String,
) -> i32 {
    // all clocked/mem variables
    for (xvname, xvar) in xmod.variables.iter() {
        let xvar = xvar.borrow();
        if !xvar.xtype.is_memory() && xvar.usage != XmlVarUsage::Clocked {
            continue;
        }
        let xt = &xvar.xtype;
        let tot_bits = xt.bit_count();
        writeln!(
            map,
            "{pstart} {pend} {path}.{xvname} {bitcount} {lword} {rword} {lmem} {rmem} {kind}",
            pstart = pstart,
            pend = pstart + tot_bits - 1,
            path = path,
            xvname = xvname,
            bitcount = xt.bit_count(),
            lword = xt.word_range().0,
            rword = xt.word_range().1,
            lmem = xt.mem1_range().0,
            rmem = xt.mem1_range().1,
            kind = (if xt.is_memory() { "mem" } else { "var" })
        )
        .unwrap();
        pstart += tot_bits;
    }
    // children instances
    for xchild in xmod.children.iter() {
        let cpath = format!("{}.{}", path, xchild.name);
        let ch = meta.modules.get(&xchild.module).unwrap().borrow();
        pstart = recurse_module(meta, &ch, pstart, &cpath, map);
    }
    pstart
}

pub fn generate_bit_map(meta: &XmlMetadata) -> String {
    let mut map = String::with_capacity(1024);
    let top = meta.modules.get(&meta.top_module).unwrap().borrow();
    recurse_module(meta, &top, 0, &top.name, &mut map);
    map
}
