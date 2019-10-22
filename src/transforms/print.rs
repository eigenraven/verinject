use crate::ast::*;
use std::fmt::{Display, Formatter, Error};

pub struct AstToVerilogPrinter<'s, 'a> {
    ast: &'a AstRoot<'s>
}

impl<'s, 'a> AstToVerilogPrinter<'s, 'a> {
    pub fn new(ast: &'a AstRoot<'s>) -> Self {
        Self {
            ast
        }
    }
}

impl Display for AstToVerilogPrinter<'_, '_> {
    fn fmt(&self, f: &mut Formatter<'_>) -> Result<(), Error> {
        fmt_root(self.ast, f)
    }
}

fn fmt_any(ast: &AstAnyNode<'_>, f: &mut Formatter<'_>) -> Result<(), Error> {
    match ast {
        AstAnyNode::Root(a) => fmt_root(a, f),
        AstAnyNode::Module(a) => fmt_module(a, f),
        AstAnyNode::VarNetDecl(a) => fmt_varnetdecl(a, f, true),
        AstAnyNode::Range(a) => fmt_range(a, f),
        AstAnyNode::Value(a) => fmt_value(a, f),
        AstAnyNode::Type(a) => fmt_type(a, f),
    }
}

fn fmt_root(ast: &AstRoot<'_>, f: &mut Formatter<'_>) -> Result<(), Error> {
    for t in ast.common.top_space.iter() {
        write!(f, "{}", t)?;
    }
    for ch in ast.children.iter() {
        fmt_any(ch, f)?;
    }
    Ok(())
}

fn fmt_module(ast: &AstModule<'_>, f: &mut Formatter<'_>) -> Result<(), Error> {
    Ok(())
}

fn fmt_varnetdecl(ast: &AstVarNetDecl<'_>, f: &mut Formatter<'_>, freestanding: bool) -> Result<(), Error> {
    Ok(())
}

fn fmt_range(ast: &AstRange<'_>, f: &mut Formatter<'_>) -> Result<(), Error> {
    Ok(())
}

fn fmt_value(ast: &AstValue<'_>, f: &mut Formatter<'_>) -> Result<(), Error> {
    Ok(())
}

fn fmt_type(ast: &AstType<'_>, f: &mut Formatter<'_>) -> Result<(), Error> {
    Ok(())
}
