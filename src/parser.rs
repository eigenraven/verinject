use crate::ast::*;
use crate::lexer::{Token, TokenKind};
use std::borrow::Cow;

pub fn parse<'s>(tokens: &'s [Token<'s>]) -> Result<AstRoot<'s>, String> {
    let mut root = AstRoot {
        common: AstCommon {
            top_space: Cow::default(),
            tokens: Cow::from(tokens),
        },
        children: Vec::new(),
    };

    let mut first_space = 0usize;
    let mut space_count = 0usize;
    let mut remaining = tokens;

    while !remaining.is_empty() {
        let space_tokens = &tokens[first_space..first_space + space_count];
        match remaining[0].kind {
            TokenKind::KModule => {
                let (m, new_remaining) = parse_module(space_tokens, remaining)?;
                root.children.push(AstAnyNode::from(m));
                remaining = new_remaining;
                first_space = tokens.len() - remaining.len();
                space_count = 0;
            }
            _ => {
                space_count += 1;
                remaining = &remaining[1..];
            }
        }
    }

    Ok(root)
}

fn p_ensure_equal<'s>(
    remaining: &mut &'s [Token<'s>],
    equal_to: TokenKind,
) -> Result<&'s Token<'s>, String> {
    match remaining.first() {
        None => Err(format!("Expected {:?}, found end of file", equal_to)),
        Some(t) => {
            if t.kind == equal_to {
                *remaining = &(*remaining)[1..];
                Ok(t)
            } else {
                Err(format!("Expected {:?}, found {:?}", equal_to, t))
            }
        }
    }
}

fn p_skip_whitespace<'s>(remaining: &mut &'s [Token<'s>]) -> &'s [Token<'s>] {
    let cnt = remaining
        .iter()
        .take_while(|e| e.kind == TokenKind::Whitespace)
        .count();
    let spaces = &remaining[0..cnt];
    *remaining = &(*remaining)[cnt..];
    spaces
}

fn parse_range<'s>(
    space_tokens: &'s [Token<'s>],
    tokens: &'s [Token<'s>],
) -> Result<(AstRange<'s>, &'s [Token<'s>]), String> {
    let mut remaining = tokens;
    let num_tokens = tokens.len() - remaining.len();

    p_ensure_equal(&mut remaining, TokenKind::LBracket)?;
    let left_space = p_skip_whitespace(&mut remaining);

    let num_left = remaining
        .iter()
        .take_while(|t| t.kind != TokenKind::Colon)
        .count();
    if num_left == 0 {
        return Err(format!(
            "Expected a valid range at {:?} - missing left bound",
            tokens[0].location.unwrap()
        ));
    }
    let left = AstValue {
        common: AstCommon {
            top_space: Cow::from(left_space),
            tokens: Cow::from(&remaining[0..num_left]),
        },
        numeric: None,
    }
    .try_with_numeric();
    remaining = &remaining[num_left..];

    p_ensure_equal(&mut remaining, TokenKind::Colon)?;
    let right_space = p_skip_whitespace(&mut remaining);

    let num_right = remaining
        .iter()
        .take_while(|t| t.kind != TokenKind::RBracket)
        .count();
    if num_right == 0 {
        return Err(format!(
            "Expected a valid range at {:?} - missing right bound",
            tokens[0].location.unwrap()
        ));
    }
    let right = AstValue {
        common: AstCommon {
            top_space: Cow::from(right_space),
            tokens: Cow::from(&remaining[0..num_right]),
        },
        numeric: None,
    }
    .try_with_numeric();
    remaining = &remaining[num_right..];

    p_ensure_equal(&mut remaining, TokenKind::RBracket)?;

    Ok((
        AstRange {
            common: AstCommon {
                top_space: Cow::from(space_tokens),
                tokens: Cow::from(&tokens[0..num_tokens]),
            },
            left,
            right,
        },
        remaining,
    ))
}

fn parse_varnetdecl<'s>(
    space_tokens: &'s [Token<'s>],
    tokens: &'s [Token<'s>],
) -> Result<(AstVarNetDecl<'s>, &'s [Token<'s>]), String> {
    let mut remaining = tokens;
    let mut next = remaining
        .first()
        .ok_or_else(|| "Expected variable/net declaration, got end of file".to_owned())?;
    let ioq = match next.kind {
        TokenKind::KInput => VerilogIoQualifier::Input,
        TokenKind::KOutput => VerilogIoQualifier::Output,
        TokenKind::KInOut => VerilogIoQualifier::InOut,
        _ => VerilogIoQualifier::None,
    };
    let mut space: &'s [Token] = &[];
    if ioq != VerilogIoQualifier::None {
        remaining = &remaining[1..];
        space = p_skip_whitespace(&mut remaining);
        next = remaining
            .first()
            .ok_or_else(|| "Expected variable/net declaration, got end of file".to_owned())?;
    }
    let verilog_type = match next.kind {
        TokenKind::KLogic(_) => {
            remaining = &remaining[1..];
            space = p_skip_whitespace(&mut remaining);
            next = remaining
                .first()
                .ok_or_else(|| "Expected variable/net declaration, got end of file".to_owned())?;
            VerilogType::Reg
        }
        TokenKind::KWire => {
            remaining = &remaining[1..];
            space = p_skip_whitespace(&mut remaining);
            next = remaining
                .first()
                .ok_or_else(|| "Expected variable/net declaration, got end of file".to_owned())?;
            VerilogType::Wire
        }
        _ => VerilogType::Wire,
    };
    let bit_rg = match next.kind {
        TokenKind::LBracket => {
            let (r, new_remaining) = parse_range(space, remaining)?;
            remaining = new_remaining;
            p_skip_whitespace(&mut remaining);
            next = remaining
                .first()
                .ok_or_else(|| "Expected variable/net declaration, got end of file".to_owned())?;
            Some(r)
        }
        _ => None,
    };
    let name = match next.kind {
        TokenKind::Identifier => {
            let nm = next.instance.clone();
            remaining = &remaining[1..];
            space = p_skip_whitespace(&mut remaining);
            next = remaining
                .first()
                .ok_or_else(|| "Expected variable/net declaration, got end of file".to_owned())?;
            nm
        }
        _ => {
            return Err("Expected variable/net declaration, got end of file".to_owned());
        }
    };
    let arr_rg = match next.kind {
        TokenKind::LBracket => {
            let (r, new_remaining) = parse_range(space, remaining)?;
            remaining = new_remaining;
            Some(r)
        }
        _ => None,
    };
    let num_tokens = tokens.len() - remaining.len();
    let atype = AstType {
        common: AstCommon {
            tokens: Cow::from(&tokens[0..num_tokens]),
            top_space: Cow::from(space_tokens),
        },
        vtype: verilog_type,
        bit_range: bit_rg,
        array_range: arr_rg,
    };
    Ok((
        AstVarNetDecl {
            common: AstCommon {
                tokens: Cow::from(&tokens[0..num_tokens]),
                top_space: Cow::from(space_tokens),
            },
            io_qual: ioq,
            atype,
            name,
        },
        remaining,
    ))
}

fn parse_port_list<'s>(
    tokens: &'s [Token<'s>],
) -> Result<(Vec<AstVarNetDecl<'s>>, &'s [Token<'s>]), String> {
    let mut remaining = tokens;
    p_ensure_equal(&mut remaining, TokenKind::LParen)?;
    let mut ports = Vec::new();
    loop {
        let space = p_skip_whitespace(&mut remaining);
        let next = remaining
            .first()
            .ok_or_else(|| "Expected port declaration or `)`, got end of file".to_owned())?;
        if next.kind == TokenKind::RParen {
            break;
        }
        let (port, new_remaining) = parse_varnetdecl(space, remaining)?;
        ports.push(port);
        remaining = new_remaining;
        p_skip_whitespace(&mut remaining);
        if let Some(t) = remaining.first() {
            if t.kind == TokenKind::Comma {
                remaining = &remaining[1..];
            }
        }
    }
    p_ensure_equal(&mut remaining, TokenKind::RParen)?;
    Ok((ports, remaining))
}

fn parse_module<'s>(
    space_tokens: &'s [Token<'s>],
    tokens: &'s [Token<'s>],
) -> Result<(AstModule<'s>, &'s [Token<'s>]), String> {
    let mut remaining = tokens;
    p_ensure_equal(&mut remaining, TokenKind::KModule)?;
    // todo: parameters (#(...))
    p_skip_whitespace(&mut remaining);
    let name_token = p_ensure_equal(&mut remaining, TokenKind::Identifier)?;
    p_skip_whitespace(&mut remaining);
    let ports = {
        let (ports, new_remaining) = parse_port_list(remaining)?;
        remaining = new_remaining;
        ports
    };
    p_skip_whitespace(&mut remaining);
    p_ensure_equal(&mut remaining, TokenKind::Semicolon)?;
    let children = Vec::new(); // todo
    let num_tokens = tokens.len() - remaining.len();
    Ok((
        AstModule {
            common: AstCommon {
                top_space: Cow::from(space_tokens),
                tokens: Cow::from(&tokens[0..num_tokens]),
            },
            name: name_token.instance.clone(),
            ports,
            children,
        },
        remaining,
    ))
}
