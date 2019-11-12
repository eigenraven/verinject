use crate::lexer::{Token, TokenKind};
use crate::lexer::TokenKind as TK;
use crate::xmlast::{XmlMetadata, XmlModule};

pub mod inject_ff_errors;

pub struct ParserParams<'v, 's> {
    output: &'v mut Vec<Token<'s>>,
    xml_meta: &'s XmlMetadata,
    xml_module: &'s XmlModule,
}

type PResult = Result<(), String>;

#[allow(unused_variables)]
pub trait RtlTransform {
    fn full_transform<'s>(
        &mut self,
        toks: &[Token<'s>],
        xml_meta: &'s XmlMetadata,
        xml_module: &'s XmlModule,
    ) -> Result<Vec<Token<'s>>, String> {
        let mut v = Vec::new();
        self.parse_module(toks, &mut ParserParams {
            output: &mut v,
            xml_meta,
            xml_module
        })?;
        Ok(v)
    }

    /// splits a b S c d into (a b, S, c d)
    fn token_split<'s, 't>(toks: &'t[Token<'s>], split_at: TokenKind) -> Option<(&'t [Token<'s>], &'t Token<'s>, &'t[Token<'s>])> {
        let idx = toks.iter().take_while(|t| t.kind != split_at).count();
        if idx == toks.len() {
            return None;
        }
        let left = &toks[..idx];
        let mid = &toks[idx];
        let right = &toks[idx..];
        return Some((left, mid, right));
    }

    /// splits p (a (b)) S c d into (p (a (b)), c d)
    fn token_split_balanced_parens<'s, 't>(toks: &'t [Token<'s>], lparen: TokenKind, rparen: TokenKind) -> Option<(&'t[Token<'s>], &'t[Token<'s>])> {
        let first_paren = toks.iter().take_while(|t| t.kind != lparen).count();
        let mut last_paren = first_paren + 1;
        let mut balance = 1i32;
        while last_paren < toks.len() {
            if toks[last_paren].kind == lparen {
                balance += 1;
            } else if toks[last_paren].kind == rparen {
                balance -= 1;
            }
            if balance == 0 {
                break;
            }
            last_paren += 1;
        }
        if balance != 0 {
            return None;
        }
        return Some(toks.split_at(last_paren+1));
    }

    fn push_until<'s, 't>(&mut self, toks: &'t [Token<'s>], stop_at: TokenKind,
                      params: &mut ParserParams<'_, 's>) -> &'t [Token<'s>] {
        let pushed_cnt = toks.iter().take_while(|t| t.kind != stop_at).count();
        let (to_push, to_ret) = toks.split_at(pushed_cnt);
        self.push_tokens(to_push, params);
        to_ret
    }

    fn push_while<'s, 't>(&mut self, toks: &'t [Token<'s>], while_at: TokenKind,
                      params: &mut ParserParams<'_, 's>) -> &'t [Token<'s>] {
        let pushed_cnt = toks.iter().take_while(|t| t.kind == while_at).count();
        let (to_push, to_ret) = toks.split_at(pushed_cnt);
        self.push_tokens(to_push, params);
        to_ret
    }

    fn push_tokens<'s>(&mut self, toks: &[Token<'s>],
                  params: &mut ParserParams<'_, 's>) {
        toks.iter().cloned().for_each(|t| params.output.push(t));
    }

    fn parse_verilog<'s>(&mut self, mut toks: &[Token<'s>],
                        params: &mut ParserParams<'_, 's>) -> PResult {
        while !toks.is_empty() {
            let tok = &toks[0];
            match tok.kind {
                TK::KModule => {
                    if let Some((mtoks, mend, nexttoks)) = Self::token_split(toks, TK::KEndModule) {
                        self.parse_module(mtoks, params)?;
                        params.output.push(mend.clone());
                        toks = nexttoks;
                    } else {
                        return Err(String::from("Could not find endmodule"));
                    }
                }
                _ => {
                    params.output.push(tok.clone());
                    toks = &toks[1..];
                }
            }
        }
        Ok(())
    }

    fn parse_module<'s>(&mut self, toks: &[Token<'s>],
                    params: &mut ParserParams<'_, 's>) -> PResult {
        assert_eq!(toks[0].kind, TK::KModule);
        let (premodid, modid, toks) = Self::token_split(toks, TK::Identifier)
            .ok_or_else(||"Can't find module name".to_owned())?;
        self.push_tokens(premodid, params);
        self.on_module_name(modid, params, false)?;
        let mut toks = self.push_while(toks, TK::Whitespace, params);
        if toks[0].kind == TK::Hash {
            // has parameters
            let (param_toks, next_toks) = Self::token_split_balanced_parens(toks, TK::LParen, TK::RParen).unwrap();
            assert_eq!(param_toks.last().unwrap().kind, TK::RParen);
            self.push_tokens(&param_toks[..param_toks.len()-1], params);
            self.on_post_module_parameter(params)?;
            params.output.push(param_toks.last().unwrap().clone());
            toks = next_toks;
        } else {
            self.on_no_module_parameters(params)?;
        }
        let mut toks = self.push_while(toks, TK::Whitespace, params);
        assert_eq!(toks[0].kind, TK::LParen);
        let (port_toks, next_toks) = Self::token_split_balanced_parens(toks, TK::LParen, TK::RParen).expect("Broken module definition");
        assert_eq!(port_toks.last().unwrap().kind, TK::RParen);
        self.push_tokens(&port_toks[..port_toks.len()-1], params);
        self.on_post_module_ports(params)?;
        params.output.push(port_toks.last().unwrap().clone());
        toks = self.push_until(next_toks, TK::Semicolon, params);
        params.output.push(toks[0].clone());
        toks = &toks[1..];
        // in module body now
        self.parse_body(toks, params)?;
        Ok(())
    }

    fn parse_body<'s>(&mut self, mut toks: &[Token<'s>],
                        params: &mut ParserParams<'_, 's>) -> PResult {
        loop {
            toks = self.push_while(toks, TK::Whitespace, params);
            if toks.is_empty() {break;}
            // detect module instantiations
            if toks.iter().filter(|t| t.kind != TK::Whitespace)
                .map(|t| &t.kind)
                .take(2)
                .eq([TK::Identifier, TK::Identifier].iter())
            {
                let modname = &toks[0];
                self.on_module_name(modname, params, true)?;
                toks = self.push_until(&toks[1..], TK::Identifier, params);
                let instid = &toks[0];
                params.output.push(instid.clone());
                toks = self.push_while(&toks[1..], TK::Whitespace, params);
            }
        }
        Ok(())
    }

    fn on_module_name<'s>(&mut self, id: &Token<'s>, params: &mut ParserParams<'_, 's>, instance: bool) -> PResult {
        params.output.push(id.clone());
        Ok(())
    }

    fn on_no_module_parameters<'s>(&mut self, params: &mut ParserParams<'_, 's>) -> PResult {
        Ok(())
    }

    // module abc #(parameter a = 1, parameter b = 2 .HERE.) ...
    fn on_post_module_parameter<'s>(&mut self, params: &mut ParserParams<'_, 's>) -> PResult {
        Ok(())
    }

    // module abc #(parameter a = 1, parameter b = 2) (input a, output [31:0] b .HERE.) ...
    fn on_post_module_ports<'s>(&mut self, params: &mut ParserParams<'_, 's>) -> PResult {
        Ok(())
    }

    fn on_pre_instance<'s>(&mut self, modname: &Token<'s>, id: &Token<'s>, params: &mut ParserParams<'_, 's>) -> PResult {
        Ok(())
    }
}
