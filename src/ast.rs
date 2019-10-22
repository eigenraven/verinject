use crate::lexer::{Token, TokenKind};
use std::borrow::Cow;
use std::fmt::{Debug, Display, Error, Formatter};
use std::str::FromStr;

#[derive(Clone, Hash)]
pub struct AstCommon<'s> {
    pub top_space: TokensRef<'s>,
    pub tokens: TokensRef<'s>,
}

impl Debug for AstCommon<'_> {
    fn fmt(&self, f: &mut Formatter<'_>) -> Result<(), Error> {
        write!(
            f,
            "AstCommon(#={}+{})",
            self.top_space.len(),
            self.tokens.len()
        )
    }
}

pub trait AstNode<'s> {
    fn common(&self) -> &AstCommon<'s>;
    fn common_mut(&mut self) -> &mut AstCommon<'s>;
    fn display<'c>(&'c self) -> AstNodeDisplay<'c, 's> {
        AstNodeDisplay(self.common())
    }
}

pub struct AstNodeDisplay<'c, 's>(&'c AstCommon<'s>);

impl<'c, 's> Display for AstNodeDisplay<'c, 's> {
    fn fmt(&self, f: &mut Formatter<'_>) -> Result<(), Error> {
        let common = self.0;
        for t in common.top_space.iter().chain(common.tokens.iter()) {
            Display::fmt(t, f)?;
        }
        Ok(())
    }
}

type TokensRef<'s> = Cow<'s, [Token<'s>]>;
pub type NodeList<'s> = Vec<AstAnyNode<'s>>;

#[derive(Copy, Clone, Debug, Hash, Eq, PartialEq)]
pub enum VerilogType {
    Wire,
    Reg,
}

#[derive(Copy, Clone, Debug, Hash, Eq, PartialEq)]
pub enum VerilogIoQualifier {
    None,
    Input,
    Output,
    InOut,
}

#[derive(Clone, Debug, Hash)]
pub enum AstAnyNode<'s> {
    Root(AstRoot<'s>),
    Module(AstModule<'s>),
    VarNetDecl(AstVarNetDecl<'s>),
    Range(AstRange<'s>),
    Value(AstValue<'s>),
    Type(AstType<'s>),
}

macro_rules! ast_any_node_from {
    ($t:ty, $id:ident) => {
        impl<'s> From<$t> for AstAnyNode<'s> {
            fn from(a: $t) -> Self {
                AstAnyNode::$id(a)
            }
        }
    };
}

ast_any_node_from!(AstRoot<'s>, Root);
ast_any_node_from!(AstModule<'s>, Module);
ast_any_node_from!(AstVarNetDecl<'s>, VarNetDecl);
ast_any_node_from!(AstRange<'s>, Range);
ast_any_node_from!(AstValue<'s>, Value);
ast_any_node_from!(AstType<'s>, Type);

impl<'s> AstNode<'s> for AstAnyNode<'s> {
    fn common(&self) -> &AstCommon<'s> {
        match self {
            AstAnyNode::Root(n) => n.common(),
            AstAnyNode::Module(n) => n.common(),
            AstAnyNode::VarNetDecl(n) => n.common(),
            AstAnyNode::Range(n) => n.common(),
            AstAnyNode::Value(n) => n.common(),
            AstAnyNode::Type(n) => n.common(),
        }
    }

    fn common_mut(&mut self) -> &mut AstCommon<'s> {
        match self {
            AstAnyNode::Root(n) => n.common_mut(),
            AstAnyNode::Module(n) => n.common_mut(),
            AstAnyNode::VarNetDecl(n) => n.common_mut(),
            AstAnyNode::Range(n) => n.common_mut(),
            AstAnyNode::Value(n) => n.common_mut(),
            AstAnyNode::Type(n) => n.common_mut(),
        }
    }
}

#[derive(Clone, Debug, Hash)]
pub struct AstRoot<'s> {
    pub common: AstCommon<'s>,
    pub children: NodeList<'s>,
}

impl<'s> AstNode<'s> for AstRoot<'s> {
    fn common(&self) -> &AstCommon<'s> {
        &self.common
    }

    fn common_mut(&mut self) -> &mut AstCommon<'s> {
        &mut self.common
    }
}

#[derive(Clone, Debug, Hash)]
pub struct AstModule<'s> {
    pub common: AstCommon<'s>,
    pub name: Cow<'s, str>,
    pub ports: Vec<AstVarNetDecl<'s>>,
    pub children: NodeList<'s>,
}

impl<'s> AstNode<'s> for AstModule<'s> {
    fn common(&self) -> &AstCommon<'s> {
        &self.common
    }

    fn common_mut(&mut self) -> &mut AstCommon<'s> {
        &mut self.common
    }
}

#[derive(Clone, Debug, Hash)]
pub struct AstVarNetDecl<'s> {
    pub common: AstCommon<'s>,
    pub io_qual: VerilogIoQualifier,
    pub atype: AstType<'s>,
    pub name: Cow<'s, str>,
}

impl<'s> AstNode<'s> for AstVarNetDecl<'s> {
    fn common(&self) -> &AstCommon<'s> {
        &self.common
    }

    fn common_mut(&mut self) -> &mut AstCommon<'s> {
        &mut self.common
    }
}

#[derive(Clone, Debug, Hash)]
pub struct AstRange<'s> {
    pub common: AstCommon<'s>,
    pub left: AstValue<'s>,
    pub right: AstValue<'s>,
}

impl<'s> AstNode<'s> for AstRange<'s> {
    fn common(&self) -> &AstCommon<'s> {
        &self.common
    }

    fn common_mut(&mut self) -> &mut AstCommon<'s> {
        &mut self.common
    }
}

#[derive(Clone, Debug, Hash)]
pub struct AstValue<'s> {
    pub common: AstCommon<'s>,
    pub numeric: Option<i64>,
}

impl AstValue<'_> {
    pub fn try_with_numeric(mut self) -> Self {
        let mut ts = self
            .common
            .tokens
            .iter()
            .filter(|t| t.kind != TokenKind::Whitespace);
        let num = ts.clone().count();
        if num != 1 {
            return self;
        }
        let tok = ts.next().unwrap();
        if tok.kind != TokenKind::Number {
            return self;
        }
        let s = &tok.instance;
        if s.contains('\'') {
            // todo: parse verilog numerals
        } else {
            let flt = s.replace('_', "");
            self.numeric = i64::from_str(&flt).ok();
        }
        self
    }
}

impl<'s> AstNode<'s> for AstValue<'s> {
    fn common(&self) -> &AstCommon<'s> {
        &self.common
    }

    fn common_mut(&mut self) -> &mut AstCommon<'s> {
        &mut self.common
    }
}

#[derive(Clone, Debug, Hash)]
pub struct AstType<'s> {
    pub common: AstCommon<'s>,
    pub vtype: VerilogType,
    pub bit_range: Option<AstRange<'s>>,
    pub array_range: Option<AstRange<'s>>,
}

impl<'s> AstNode<'s> for AstType<'s> {
    fn common(&self) -> &AstCommon<'s> {
        &self.common
    }

    fn common_mut(&mut self) -> &mut AstCommon<'s> {
        &mut self.common
    }
}
