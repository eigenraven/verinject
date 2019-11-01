use crate::ast::VerilogType;
use crate::lexer::Token;
use crate::lexer::TokenKind as TK;
use crate::xmlast::{XmlMetadata, XmlVarUsage};

fn modified_ff(name: &str) -> String {
    format!("verinject_modified__{}", name)
}

pub fn ff_error_injection<'s>(
    mut toks: &[Token<'s>],
    xml_meta: &'s XmlMetadata,
) -> Result<Vec<Token<'s>>, String> {
    let mut r: Vec<Token<'s>> = Vec::new();

    let mut in_module = false;
    let mut in_assignment = false;
    let mut in_instance = false;
    loop {
        if toks.is_empty() {
            break;
        }
        let tok = &toks[0];
        toks = &toks[1..];

        //eprintln!("Tok: {:?}", tok);

        if tok.kind == TK::Semicolon {
            in_assignment = false;
            in_instance = false;
        } else if let TK::AssignSeq | TK::AssignConc = tok.kind {
            in_assignment = true;
        } else if tok.kind == TK::Identifier {
            if toks
                .iter()
                .filter(|t| t.kind != TK::Whitespace)
                .next()
                .map_or(false, |t| t.kind == TK::Identifier)
            {
                // module instantiation
                in_instance = true;
            }
        }

        if in_instance {
            if tok.kind == TK::LParen {
                in_assignment = true;
            } else if tok.kind == TK::Dot {
                in_assignment = false; // ensure that .port(val) only changes into .port(val_inj)
            }
        }

        //eprintln!("instance: {:?} assignment: {:?}", in_instance, in_assignment);

        match tok.kind {
            TK::KModule => {
                if in_module {
                    return Err("Nested modules not supported".to_owned());
                }
                in_module = true;
                r.push(tok.clone());
                inject_modargs(&mut toks, xml_meta, &mut r)?;
                // put all created registers
                r.push(Token::inject("\n".to_owned()));
                for (_, var) in xml_meta.variables.iter() {
                    let var = var.borrow();
                    if var.usage != XmlVarUsage::Clocked {
                        continue;
                    }
                    // create a verinject_modified__ff for each ff
                    let mname = modified_ff(&var.name);
                    let (left, right) = var.xtype.bit_range();
                    r.push(var.xtype.create_var(VerilogType::Reg, &mname));
                    r.push(Token::inject(";\n".to_owned()));
                    r.push(Token::inject(format!(
                        r#"verinject_ff_injector u_verinject__inj__{vname} #(.LEFT({left}), .RIGHT({right}) (
//  .state(verinject__injector_state),
  .unmodified({vname}),
  .modified({mname})
);
"#, vname=&var.name, mname=&mname, left=left, right=right
                    )));
                }
            }
            TK::KEndModule => {
                in_module = false;
                r.push(tok.clone());
            }
            TK::Identifier => {
                let id: &str = &tok.instance;
                let mut no_print = false;
                if in_assignment {
                    if let Some(xvar) = xml_meta.variables.get(id) {
                        if xvar.borrow().usage == XmlVarUsage::Clocked {
                            no_print = true;
                            r.push(Token::inject(modified_ff(id)));
                        }
                    }
                }
                if !no_print {
                    r.push(tok.clone());
                }
            }
            _ => {
                r.push(tok.clone());
            }
        }
    }
    Ok(r)
}

fn consume_until<'s>(
    toks: &mut &[Token<'s>],
    kind: TK,
    r: &mut Vec<Token<'s>>,
) -> Result<(), String> {
    while !toks.is_empty() && toks[0].kind != kind {
        r.push(toks[0].clone());
        *toks = &toks[1..];
    }
    if toks.is_empty() {
        return Err(format!("Could not find expected token kind: {:?}", kind));
    }
    Ok(())
}

fn consume_including<'s>(
    toks: &mut &[Token<'s>],
    kind: TK,
    r: &mut Vec<Token<'s>>,
) -> Result<(), String> {
    consume_until(toks, kind, r)?;
    r.push(toks[0].clone());
    *toks = &toks[1..];
    Ok(())
}

fn inject_modargs<'s>(
    toks: &mut &[Token<'s>],
    xml_meta: &XmlMetadata,
    r: &mut Vec<Token<'s>>,
) -> Result<(), String> {
    while !toks.is_empty() && toks[0].kind != TK::LParen {
        if toks[0].kind == TK::Hash {
            // parameter syntax #()
            consume_including(toks, TK::Hash, r)?;
            consume_including(toks, TK::LParen, r)?;
            let mut parcount = 1i32;
            // eat balanced parens
            while !toks.is_empty() && parcount > 0 {
                if toks[0].kind == TK::LParen {
                    parcount += 1;
                }
                if toks[0].kind == TK::RParen {
                    parcount -= 1;
                }
                r.push(toks[0].clone());
                *toks = &toks[1..];
            }
            continue;
        }
        r.push(toks[0].clone());
        *toks = &toks[1..];
    }
    if toks.is_empty() {
        return Err("Could not find start of module ports".to_owned());
    }
    r.push(toks[0].clone());
    *toks = &toks[1..];
    // found (
    let mut num_args = 0i32;
    while !toks.is_empty() && toks[0].kind != TK::RParen {
        if toks[0].kind != TK::Whitespace {
            if let TK::KInput | TK::KOutput | TK::KInOut = toks[0].kind {
                num_args += 1;
            }
        }
        r.push(toks[0].clone());
        *toks = &toks[1..];
    }
    if toks.is_empty() {
        return Err("Could not find end of module ports".to_owned());
    }
    // ) is tok[0], put additional args here

    /*r.push(Token::inject(format!(
        "{}input [31:0] verinject__injector_state\n",
        if num_args > 0 {", "} else {""}
    )));*/

    // put the )
    r.push(toks[0].clone());
    *toks = &toks[1..];
    consume_including(toks, TK::Semicolon, r)?;

    Ok(())
}
