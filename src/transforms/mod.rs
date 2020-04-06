use crate::lexer::TokenKind as TK;
use crate::lexer::{Token, TokenKind};
use crate::xmlast::{XmlMetadata, XmlModule, XmlVarUsage};

pub mod generate_bit_map;
pub mod inject_ff_errors;

pub struct ParserParams<'v, 's> {
    output: &'v mut Vec<Token<'s>>,
    xml_meta: &'s XmlMetadata,
    xml_module: &'s XmlModule,
}

pub type PResult = Result<(), String>;

#[allow(unused_variables)]
pub trait RtlTransform {
    fn full_transform<'s>(
        &mut self,
        toks: &[Token<'s>],
        xml_meta: &'s XmlMetadata,
        xml_module: &'s XmlModule,
    ) -> Result<Vec<Token<'s>>, String> {
        let mut v = Vec::new();
        self.parse_verilog(
            toks,
            &mut ParserParams {
                output: &mut v,
                xml_meta,
                xml_module,
            },
        )?;
        Ok(v)
    }

    /// splits a b S c d into (a b, S, c d)
    fn token_split<'s, 't>(
        toks: &'t [Token<'s>],
        split_at: TokenKind,
    ) -> Option<(&'t [Token<'s>], &'t Token<'s>, &'t [Token<'s>])> {
        let idx = toks.iter().take_while(|t| t.kind != split_at).count();
        if idx == toks.len() {
            return None;
        }
        let left = &toks[..idx];
        let mid = &toks[idx];
        let right = &toks[idx + 1..];
        Some((left, mid, right))
    }

    /// splits p (a (b)) S c d into (p (a (b)), c d)
    fn token_split_balanced_parens<'s, 't>(
        toks: &'t [Token<'s>],
        lparen: TokenKind,
        rparen: TokenKind,
    ) -> Option<(&'t [Token<'s>], &'t [Token<'s>])> {
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
        Some(toks.split_at(last_paren + 1))
    }

    fn push_until<'s, 't>(
        &mut self,
        toks: &'t [Token<'s>],
        stop_at: TokenKind,
        params: &mut ParserParams<'_, 's>,
    ) -> &'t [Token<'s>] {
        let pushed_cnt = toks.iter().take_while(|t| t.kind != stop_at).count();
        let (to_push, to_ret) = toks.split_at(pushed_cnt);
        self.push_tokens(to_push, params);
        to_ret
    }

    fn push_while<'s, 't>(
        &mut self,
        toks: &'t [Token<'s>],
        while_at: TokenKind,
        params: &mut ParserParams<'_, 's>,
    ) -> &'t [Token<'s>] {
        let pushed_cnt = toks.iter().take_while(|t| t.kind == while_at).count();
        let (to_push, to_ret) = toks.split_at(pushed_cnt);
        self.push_tokens(to_push, params);
        to_ret
    }

    fn push_tokens<'s>(&mut self, toks: &[Token<'s>], params: &mut ParserParams<'_, 's>) {
        toks.iter().cloned().for_each(|t| params.output.push(t));
    }

    fn parse_verilog<'s>(
        &mut self,
        mut toks: &[Token<'s>],
        params: &mut ParserParams<'_, 's>,
    ) -> PResult {
        while !toks.is_empty() {
            match toks[0].kind {
                TK::KModule => {
                    if let Some((mtoks, mend, nexttoks)) = Self::token_split(toks, TK::KEndModule) {
                        self.parse_module(mtoks, params)?;
                        self.on_end_module(params)?;
                        params.output.push(mend.clone());
                        toks = nexttoks;
                    } else {
                        return Err(String::from("Could not find endmodule"));
                    }
                }
                _ => {
                    params.output.push(toks[0].clone());
                    toks = &toks[1..];
                }
            }
        }
        Ok(())
    }

    fn parse_module<'s>(
        &mut self,
        toks: &[Token<'s>],
        params: &mut ParserParams<'_, 's>,
    ) -> PResult {
        assert_eq!(toks[0].kind, TK::KModule);
        let (premodid, modid, toks) = Self::token_split(toks, TK::Identifier)
            .ok_or_else(|| "Can't find module name".to_owned())?;
        self.push_tokens(premodid, params);
        self.on_module_name(modid, params, false)?;
        let mut toks = self.push_while(toks, TK::Whitespace, params);
        if toks[0].kind == TK::Hash {
            // has parameters
            let (param_toks, next_toks) =
                Self::token_split_balanced_parens(toks, TK::LParen, TK::RParen).unwrap();
            assert_eq!(param_toks.last().unwrap().kind, TK::RParen);
            self.push_tokens(&param_toks[..param_toks.len() - 1], params);
            self.on_post_module_parameters(params)?;
            params.output.push(param_toks.last().unwrap().clone());
            toks = self.push_while(next_toks, TK::Whitespace, params);
        } else {
            self.on_no_module_parameters(params)?;
        }
        assert_eq!(toks[0].kind, TK::LParen);
        let (port_toks, next_toks) =
            Self::token_split_balanced_parens(toks, TK::LParen, TK::RParen)
                .expect("Broken module definition");
        assert_eq!(port_toks.last().unwrap().kind, TK::RParen);
        self.on_module_ports(&port_toks[..port_toks.len() - 1], params)?;
        self.on_post_module_ports(params)?;
        params.output.push(port_toks.last().unwrap().clone());
        toks = self.push_until(next_toks, TK::Semicolon, params);
        params.output.push(toks[0].clone());
        toks = &toks[1..];
        // in module body now
        self.on_module_start(params)?;
        self.parse_body(toks, params)?;
        Ok(())
    }

    fn parse_body<'s>(
        &mut self,
        mut toks: &[Token<'s>],
        params: &mut ParserParams<'_, 's>,
    ) -> PResult {
        let mut append_end = false;
        loop {
            toks = self.push_while(toks, TK::Whitespace, params);
            if toks.is_empty() {
                break;
            }
            // Skip over parameter declarations
            if toks[0].kind == TK::KLocalparam || toks[0].kind == TK::KParameter {
                toks = self.push_until(toks, TK::Semicolon, params);
                toks = self.push_while(toks, TK::Semicolon, params);
                continue;
            }
            if toks[0].kind == TK::KPreprocessor {
                toks = self.push_while(toks, TK::KPreprocessor, params);
                continue;
            }
            // detect module instantiations
            if toks
                .iter()
                .filter(|t| t.kind != TK::Whitespace)
                .map(|t| &t.kind)
                .take(2)
                .eq([TK::Identifier, TK::Identifier].iter())
            {
                let (itoks, sc, next_toks) = Self::token_split(toks, TK::Semicolon).unwrap();
                self.parse_instance(itoks, params)?;
                params.output.push(sc.clone());
                toks = next_toks;
                self.on_post_statement(params)?;
                continue;
            }
            // if/case(xz)/... ()
            if [TK::KCase, TK::KCasez, TK::KCasex, TK::KFor, TK::KIf]
                .iter()
                .any(|k| toks[0].kind == *k)
            {
                let allow_end = toks[0].kind == TK::KIf;
                params.output.push(toks[0].clone());
                toks = self.push_while(&toks[1..], TK::Whitespace, params);
                let (args, next_toks) =
                    Self::token_split_balanced_parens(toks, TK::LParen, TK::RParen).unwrap();
                self.on_expression_read_toks(args, params)?;
                toks = self.push_while(next_toks, TK::Whitespace, params);
                if allow_end && toks[0].kind != TK::KBegin {
                    params.output.push(Token::inject("\nbegin\n".to_owned()));
                    append_end = true;
                }
                continue;
            }
            // variable declarations
            if [TK::KWire, TK::KLogic(false), TK::KLogic(true), TK::KInteger]
                .iter()
                .any(|k| toks[0].kind == *k)
            {
                let (atoks, sc, next_toks) = Self::token_split(toks, TK::Semicolon).unwrap();
                if toks[0].kind == TK::KInteger {
                    self.push_tokens(atoks, params);
                    params.output.push(sc.clone());
                    toks = next_toks;
                } else {
                    self.parse_var_decl(atoks, params)?;
                    params.output.push(sc.clone());
                    toks = next_toks;
                }
                self.on_post_statement(params)?;
                if append_end {
                    append_end = false;
                    params.output.push(Token::inject("\nend\n".to_owned()));
                }
                continue;
            }
            // don't touch initial blocks
            if toks[0].kind == TK::KInitial {
                params.output.push(toks[0].clone());
                toks = self.push_while(&toks[1..], TK::Whitespace, params);
                if toks[0].kind == TK::KBegin {
                    let (itoks, next_toks) =
                        Self::token_split_balanced_parens(toks, TK::KBegin, TK::KEnd).unwrap();
                    self.push_tokens(itoks, params);
                    toks = next_toks;
                } else {
                    let (itoks, sc, next_toks) = Self::token_split(toks, TK::Semicolon).unwrap();
                    self.push_tokens(itoks, params);
                    params.output.push(sc.clone());
                    toks = next_toks;
                }
                continue;
            }
            // always blocks with arguments - skip their sensitivity lists
            if [
                TK::KAlwaysLatch,
                TK::KAlwaysFF,
                TK::KAlways,
                TK::KAlwaysComb,
            ]
            .iter()
            .any(|k| toks[0].kind == *k)
            {
                let mut usage = XmlVarUsage::Combinatorial;
                if toks[0].kind != TK::KAlwaysComb {
                    let (atoks, at, next_toks) = Self::token_split(toks, TK::At).unwrap();
                    self.push_tokens(atoks, params);
                    params.output.push(at.clone());
                    toks = self.push_while(next_toks, TK::Whitespace, params);
                    if toks[0].kind == TK::LParen {
                        let (sense, next_toks) =
                            Self::token_split_balanced_parens(toks, TK::LParen, TK::RParen)
                                .unwrap();
                        if sense.iter().any(|t| t.kind == TK::KPosedge) {
                            usage = XmlVarUsage::Clocked;
                        }
                        self.push_tokens(sense, params);
                        toks = next_toks;
                    } else if toks[0].kind == TK::Star {
                        params.output.push(toks[0].clone());
                        toks = &toks[1..];
                    }
                } else {
                    params.output.push(toks[0].clone());
                    toks = &toks[1..];
                }
                toks = self.push_while(toks, TK::Whitespace, params);
                if toks[0].kind != TK::KBegin {
                    params.output.push(Token::inject("\nbegin\n".to_owned()));
                    append_end = true;
                } else {
                    params.output.push(toks[0].clone());
                    toks = self.push_while(&toks[1..], TK::Whitespace, params);
                    if toks[0].kind == TK::Colon {
                        // block name
                        params.output.push(toks[0].clone());
                        toks = self.push_while(&toks[1..], TK::Whitespace, params);
                        assert_eq!(toks[0].kind, TK::Identifier);
                        params.output.push(toks[0].clone());
                        toks = &toks[1..];
                    }
                }
                self.on_always_begin(usage, params)?;
                self.on_post_statement(params)?;
                continue;
            }
            // keywords
            if [TK::KBegin, TK::Semicolon]
                .iter()
                .any(|k| toks[0].kind == *k)
            {
                params.output.push(toks[0].clone());
                toks = &toks[1..];
                self.on_post_statement(params)?;
                if append_end {
                    append_end = false;
                    params.output.push(Token::inject("\nend\n".to_owned()));
                }
                continue;
            }
            if [TK::KEnd, TK::KElse, TK::KEndInterface, TK::KEndModule]
                .iter()
                .any(|k| toks[0].kind == *k)
            {
                self.on_post_statement(params)?;
                if append_end {
                    append_end = false;
                    params.output.push(Token::inject("\nend\n".to_owned()));
                }
                params.output.push(toks[0].clone());
                toks = &toks[1..];
                continue;
            }
            toks = self.parse_generic_statement(toks, params)?;
            if append_end {
                append_end = false;
                params.output.push(Token::inject("\nend\n".to_owned()));
            }
        }
        Ok(())
    }

    fn parse_instance<'s>(
        &mut self,
        mut toks: &[Token<'s>],
        params: &mut ParserParams<'_, 's>,
    ) -> PResult {
        let modname = &toks[0];
        self.on_module_name(modname, params, true)?;
        toks = self.push_while(&toks[1..], TK::Whitespace, params);
        if toks[0].kind == TK::Hash {
            // has parameters
            let (param_toks, next_toks) =
                Self::token_split_balanced_parens(toks, TK::LParen, TK::RParen).unwrap();
            assert_eq!(param_toks.last().unwrap().kind, TK::RParen);
            self.push_tokens(&param_toks[..param_toks.len() - 1], params);
            self.on_post_instance_parameters(params)?;
            params.output.push(param_toks.last().unwrap().clone());
            toks = self.push_while(next_toks, TK::Whitespace, params);
        } else {
            self.on_no_instance_parameters(params)?;
        }

        toks = self.push_until(&toks[0..], TK::Identifier, params);
        let instid = &toks[0];
        params.output.push(instid.clone());
        toks = self.push_while(&toks[1..], TK::Whitespace, params);

        assert_eq!(toks[0].kind, TK::LParen);
        params.output.push(toks[0].clone());
        toks = self.push_while(&toks[1..], TK::Whitespace, params);
        // Unsupported: non-dotted instances (mod u_mod(a,b,c);)
        loop {
            assert_eq!(toks[0].kind, TK::Dot);
            params.output.push(toks[0].clone());
            toks = self.push_until(&toks[1..], TK::Identifier, params);
            toks = self.push_until(toks, TK::LParen, params);
            let (argtoks, next_toks) =
                Self::token_split_balanced_parens(toks, TK::LParen, TK::RParen).unwrap();
            for tok in argtoks {
                match tok.kind {
                    TK::Identifier => {
                        self.on_instance_port_assignment(tok, params)?;
                    }
                    _ => {
                        params.output.push(tok.clone());
                    }
                }
            }
            toks = self.push_while(next_toks, TK::Whitespace, params);
            if toks[0].kind == TK::RParen {
                break;
            } else {
                toks = self.push_while(toks, TK::Comma, params);
            }
            toks = self.push_while(toks, TK::Whitespace, params);
        }
        assert_eq!(toks[0].kind, TK::RParen);
        self.on_post_instance_ports(params)?;
        self.push_tokens(toks, params);
        Ok(())
    }

    fn parse_var_decl<'s>(
        &mut self,
        mut toks: &[Token<'s>],
        params: &mut ParserParams<'_, 's>,
    ) -> PResult {
        params.output.push(toks[0].clone());
        toks = self.push_while(&toks[1..], TK::Whitespace, params);
        if toks[0].kind == TK::LBracket {
            let (vtoks, next_toks) =
                Self::token_split_balanced_parens(toks, TK::LBracket, TK::RBracket).unwrap();
            self.push_tokens(vtoks, params);
            toks = self.push_while(next_toks, TK::Whitespace, params);
        }
        assert_eq!(toks[0].kind, TK::Identifier);
        let assignee_id = &toks[0];
        self.on_declaration_name(assignee_id, params)?;
        toks = self.push_while(&toks[1..], TK::Whitespace, params);
        while !toks.is_empty() && toks[0].kind == TK::LBracket {
            let (vtoks, next_toks) =
                Self::token_split_balanced_parens(toks, TK::LBracket, TK::RBracket).unwrap();
            self.push_tokens(vtoks, params);
            toks = self.push_while(next_toks, TK::Whitespace, params);
        }
        toks = self.push_while(toks, TK::Whitespace, params);
        if !toks.is_empty() {
            if toks[0].kind == TK::AssignConc {
                self.on_expression_read_toks(toks, params)?;
            } else {
                self.push_tokens(toks, params);
            }
        }
        Ok(())
    }

    fn parse_generic_statement<'s, 't>(
        &mut self,
        mut toks: &'t [Token<'s>],
        params: &mut ParserParams<'_, 's>,
    ) -> Result<&'t [Token<'s>], String> {
        let mut endpos = toks
            .iter()
            .take_while(|t| t.kind != TK::Semicolon && t.kind != TK::KEnd)
            .count();
        if endpos < toks.len() - 1 {
            endpos += 1;
        }
        let stmttoks = &toks[..endpos];
        let assigncnt = stmttoks
            .iter()
            .take_while(|t| t.kind != TK::AssignConc && t.kind != TK::AssignSeq)
            .count();
        let assigncnt = if assigncnt == stmttoks.len() {
            0
        } else {
            assigncnt
        };
        let (preassign, postassign) = stmttoks.split_at(assigncnt);
        if !preassign.is_empty() {
            self.on_assignment_left_side(preassign, params)?;
        }
        if !postassign.is_empty() {
            self.on_expression_read_toks(postassign, params)?;
        }
        toks = &toks[endpos..];
        self.on_post_statement(params)?;
        Ok(toks)
    }

    fn on_module_name<'s>(
        &mut self,
        id: &Token<'s>,
        params: &mut ParserParams<'_, 's>,
        instance: bool,
    ) -> PResult {
        params.output.push(id.clone());
        Ok(())
    }

    fn on_end_module<'s>(&mut self, params: &mut ParserParams<'_, 's>) -> PResult {
        Ok(())
    }

    fn on_no_module_parameters<'s>(&mut self, params: &mut ParserParams<'_, 's>) -> PResult {
        Ok(())
    }

    // module abc #(parameter a = 1, parameter b = 2 .HERE.) ...
    fn on_post_module_parameters<'s>(&mut self, params: &mut ParserParams<'_, 's>) -> PResult {
        Ok(())
    }

    // module abc #(parameter a = 1, parameter b = 2) (<START>input a, output [31:0] b <END>) ...
    fn on_module_ports<'s>(
        &mut self,
        toks: &[Token<'s>],
        params: &mut ParserParams<'_, 's>,
    ) -> PResult {
        self.push_tokens(toks, params);
        Ok(())
    }

    // module abc #(parameter a = 1, parameter b = 2) (input a, output [31:0] b .HERE.) ...
    fn on_post_module_ports<'s>(&mut self, params: &mut ParserParams<'_, 's>) -> PResult {
        Ok(())
    }

    // module abc #() (); .HERE. always... endmodule
    fn on_module_start<'s>(&mut self, params: &mut ParserParams<'_, 's>) -> PResult {
        Ok(())
    }

    fn on_no_instance_parameters<'s>(&mut self, params: &mut ParserParams<'_, 's>) -> PResult {
        Ok(())
    }

    // module abc #(parameter a = 1, parameter b = 2 .HERE.) ...
    fn on_post_instance_parameters<'s>(&mut self, params: &mut ParserParams<'_, 's>) -> PResult {
        Ok(())
    }

    // abc u_abc ( .a(*a*) );
    fn on_instance_port_assignment<'s>(
        &mut self,
        id: &Token<'s>,
        params: &mut ParserParams<'_, 's>,
    ) -> PResult {
        params.output.push(id.clone());
        Ok(())
    }

    // abc u_abc ( .a(a) .HERE. );
    fn on_post_instance_ports<'s>(&mut self, params: &mut ParserParams<'_, 's>) -> PResult {
        Ok(())
    }

    // wire [3:0] *a*;
    fn on_declaration_name<'s>(
        &mut self,
        id: &Token<'s>,
        params: &mut ParserParams<'_, 's>,
    ) -> PResult {
        params.output.push(id.clone());
        Ok(())
    }

    fn on_expression_read_toks<'s>(
        &mut self,
        mut toks: &[Token<'s>],
        params: &mut ParserParams<'_, 's>,
    ) -> PResult {
        while !toks.is_empty() {
            let tok = &toks[0];
            match tok.kind {
                TK::Identifier => {
                    let is_slice = toks
                        .iter()
                        .skip(1)
                        .find(|t| t.kind != TK::Whitespace)
                        .map_or(false, |k| k.kind == TK::LBracket);
                    if is_slice {
                        let (slice_toks, next_toks) = Self::token_split_balanced_parens(
                            &toks[1..],
                            TK::LBracket,
                            TK::RBracket,
                        )
                        .unwrap();
                        let mut bcnt = 0;
                        let mut colonpos = -1;
                        for (i, t) in slice_toks.iter().enumerate() {
                            match t.kind {
                                TK::LBracket => {
                                    bcnt += 1;
                                }
                                TK::RBracket => {
                                    bcnt -= 1;
                                }
                                TK::Colon => {
                                    if bcnt == 0 {
                                        colonpos = i as i32;
                                        break;
                                    }
                                }
                                _ => {}
                            }
                        }
                        if colonpos < 0 {
                            self.on_assignment_right_index(tok, slice_toks, params)?;
                        } else {
                            let (lsl, rsl) = slice_toks.split_at(colonpos as usize);
                            self.on_assignment_right_slice(tok, lsl, rsl, params)?;
                        }
                        toks = next_toks;
                    } else {
                        self.on_assignment_right_simple_id(tok, params)?;
                        toks = &toks[1..];
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

    // (assign/nothing) *a* = b;
    fn on_assignment_left_side<'s>(
        &mut self,
        mut toks: &[Token<'s>],
        params: &mut ParserParams<'_, 's>,
    ) -> PResult {
        while !toks.is_empty() {
            let tok = &toks[0];
            match tok.kind {
                TK::Identifier => {
                    let is_slice = toks
                        .iter()
                        .skip(1)
                        .find(|t| t.kind != TK::Whitespace)
                        .map_or(false, |k| k.kind == TK::LBracket);
                    if is_slice {
                        let (slice_toks, next_toks) = Self::token_split_balanced_parens(
                            &toks[1..],
                            TK::LBracket,
                            TK::RBracket,
                        )
                        .unwrap();
                        let mut bcnt = 0;
                        let mut colonpos = -1;
                        for (i, t) in slice_toks.iter().enumerate() {
                            match t.kind {
                                TK::LBracket => {
                                    bcnt += 1;
                                }
                                TK::RBracket => {
                                    bcnt -= 1;
                                }
                                TK::Colon => {
                                    if bcnt == 0 {
                                        colonpos = i as i32;
                                        break;
                                    }
                                }
                                _ => {}
                            }
                        }
                        if colonpos < 0 {
                            self.on_assignment_left_index(tok, slice_toks, params)?;
                        } else {
                            let (lsl, rsl) = slice_toks.split_at(colonpos as usize);
                            self.on_assignment_left_slice(tok, lsl, rsl, params)?;
                        }
                        toks = next_toks;
                    } else {
                        self.on_assignment_left_simple_id(tok, params)?;
                        toks = &toks[1..];
                    }
                }
                TK::LBracket => {
                    let (slice_toks, next_toks) =
                        Self::token_split_balanced_parens(toks, TK::LBracket, TK::RBracket)
                            .unwrap();
                    self.on_expression_read_toks(slice_toks, params)?;
                    toks = next_toks;
                }
                _ => {
                    params.output.push(tok.clone());
                    toks = &toks[1..];
                }
            }
        }
        Ok(())
    }

    fn on_assignment_left_simple_id<'s>(
        &mut self,
        id: &Token<'s>,
        params: &mut ParserParams<'_, 's>,
    ) -> PResult {
        params.output.push(id.clone());
        Ok(())
    }

    fn on_assignment_left_index<'s>(
        &mut self,
        id: &Token<'s>,
        index: &[Token<'s>],
        params: &mut ParserParams<'_, 's>,
    ) -> PResult {
        self.on_assignment_left_simple_id(id, params)?;
        self.push_tokens(index, params);
        Ok(())
    }

    fn on_assignment_left_slice<'s>(
        &mut self,
        id: &Token<'s>,
        slice_left: &[Token<'s>],
        slice_right: &[Token<'s>],
        params: &mut ParserParams<'_, 's>,
    ) -> PResult {
        self.on_assignment_left_simple_id(id, params)?;
        self.push_tokens(slice_left, params);
        self.push_tokens(slice_right, params);
        Ok(())
    }

    // (assign/nothing) a = *b*;
    fn on_assignment_right_simple_id<'s>(
        &mut self,
        id: &Token<'s>,
        params: &mut ParserParams<'_, 's>,
    ) -> PResult {
        params.output.push(id.clone());
        Ok(())
    }

    fn on_assignment_right_index<'s>(
        &mut self,
        id: &Token<'s>,
        index: &[Token<'s>],
        params: &mut ParserParams<'_, 's>,
    ) -> PResult {
        self.on_assignment_right_simple_id(id, params)?;
        self.push_tokens(index, params);
        Ok(())
    }

    fn on_assignment_right_slice<'s>(
        &mut self,
        id: &Token<'s>,
        slice_left: &[Token<'s>],
        slice_right: &[Token<'s>],
        params: &mut ParserParams<'_, 's>,
    ) -> PResult {
        self.on_assignment_right_simple_id(id, params)?;
        self.push_tokens(slice_left, params);
        self.push_tokens(slice_right, params);
        Ok(())
    }

    fn on_post_statement<'s>(&mut self, params: &mut ParserParams<'_, 's>) -> PResult {
        Ok(())
    }

    fn on_always_begin<'s>(
        &mut self,
        kind: XmlVarUsage,
        params: &mut ParserParams<'_, 's>,
    ) -> PResult {
        Ok(())
    }
}
