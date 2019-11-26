use crate::lexer::VerilogType;
use crate::lexer::{Token, TokenKind, VerilogIoQualifier};
use crate::transforms::{PResult, ParserParams, RtlTransform};
use crate::xmlast::{XmlMetadata, XmlModule, XmlVarUsage, XmlVariable};
use std::collections::{HashMap, HashSet};

fn modified_ff(name: &str) -> String {
    format!("verinject_modified__{}", name)
}

fn modified_modname(name: &str) -> String {
    format!("{}__injected", name)
}

#[derive(Default)]
struct FFErrorInjectionTransform {
    dfs_order: i32,
    next_dfs_order: i32,
    mem_read_numbers: HashMap<String, i32>,
    post_statement_queue: Vec<String>,
    last_stmt_end: usize,
    last_always_pos: usize,
    handled_dowrites: HashSet<String>,
}

#[derive(Copy, Clone, Debug, Eq, PartialEq, Hash)]
enum VarInjectType {
    None,
    BodyReg,
    PortReg,
    Memory,
}

impl VarInjectType {
    pub fn from_var(var: &XmlVariable) -> Self {
        if var.xtype.is_memory() {
            assert_eq!(var.dir, VerilogIoQualifier::None);
            VarInjectType::Memory
        } else {
            if var.usage != XmlVarUsage::Clocked {
                return VarInjectType::None;
            }
            match var.dir {
                VerilogIoQualifier::None => VarInjectType::BodyReg,
                _ => VarInjectType::PortReg,
            }
        }
    }
}

impl FFErrorInjectionTransform {
    fn impl_reg_injections<'s>(
        &mut self,
        var: &XmlVariable,
        params: &mut ParserParams<'_, 's>,
        at_end: bool,
    ) -> PResult {
        let is_port = var.dir != VerilogIoQualifier::None;
        assert_eq!(var.xtype.mem1_range(), (0, 0));
        let mname = modified_ff(&var.name);
        let (left, right) = var.xtype.word_range();
        if !at_end {
            params.output.push(var.xtype.create_var(
                if is_port {
                    VerilogType::Reg
                } else {
                    VerilogType::Wire
                },
                &mname,
            ));
            params.output.push(Token::inject(format!(
                ";\nreg verinject_do_write__{vname};",
                vname = &var.name
            )));
        } else {
            let clock = params
                .xml_module
                .clock_name
                .as_ref()
                .expect("No clock signal found");
            let pstart = format!("VERINJECT_DSTART + {dstart}", dstart = self.dfs_order);
            self.dfs_order += var.xtype.bit_count();
            params.output.push(Token::inject(format!(
                r#"verinject_ff_injector #(.LEFT({left}), .RIGHT({right}), .P_START({pstart}))
 u_verinject__inj__{vname}
( .clock({clock}),
  .do_write(verinject_do_write__{vname}),
  .verinject__injector_state(verinject__injector_state),
  .unmodified({unmod}),
  .modified({ismod})
);
"#,
                vname = &var.name,
                ismod = if is_port { &var.name } else { &mname },
                unmod = if is_port { &mname } else { &var.name },
                clock = clock,
                left = left,
                right = right,
                pstart = pstart
            )));
        }
        Ok(())
    }

    fn impl_mem_injections<'s>(
        &mut self,
        var: &XmlVariable,
        params: &mut ParserParams<'_, 's>,
        at_end: bool,
    ) -> PResult {
        assert_eq!(var.dir, VerilogIoQualifier::None);
        if params.xml_module.clock_name.is_none() {
            return Err(format!(
                "Couldn't detect clock for module at `{}`",
                params.xml_module.path
            ));
        }
        let p_clock = params.xml_module.clock_name.as_ref().unwrap();
        let (lword, rword) = var.xtype.word_range();
        let (larr, rarr) = var.xtype.mem1_range();
        let (lad, rad) = var.xtype.mem1_addr_bits();
        let p_do_write = format!("verinject_do_write__{}", var.name);
        let p_wr_addr = format!("verinject_write_address__{}", var.name);
        if !at_end {
            params
                .output
                .push(Token::inject(format!("reg {};\n", p_do_write)));
            params.output.push(Token::inject(format!(
                "reg [{lad}:{rad}] {p_wr_addr};\n",
                lad = lad,
                rad = rad,
                p_wr_addr = p_wr_addr
            )));
            for i in 0..var.read_count {
                params.output.push(Token::inject(format!(
                    "reg [{lword}:{rword}] verinject_read{i}_unmodified__{vn};\n",
                    lword = lword,
                    rword = rword,
                    i = i,
                    vn = var.name
                )));
                params.output.push(Token::inject(format!(
                    "reg [{lad}:{rad}] verinject_read{i}_address__{vn};\n",
                    lad = lad,
                    rad = rad,
                    i = i,
                    vn = var.name
                )));
                params.output.push(Token::inject(format!(
                    "wire [{lword}:{rword}] verinject_read{i}_modified__{vn};\n",
                    lword = lword,
                    rword = rword,
                    i = i,
                    vn = var.name
                )));
            }
            self.mem_read_numbers.insert(var.name.clone(), 0);
        } else {
            let pstart = format!("VERINJECT_DSTART + {dstart}", dstart = self.dfs_order);
            self.dfs_order += var.xtype.bit_count();
            for i in 0..var.read_count {
                params.output.push(Token::inject(format!(
                    r#"verinject_mem1_injector #(.LEFT({lword}), .RIGHT({rword}),
 .ADDR_LEFT({lad}), .ADDR_RIGHT({rad}),
 .MEM_LEFT({larr}), .MEM_RIGHT({rarr}),
 .P_START({pstart}))
 u_verinject_mem1_rd{i}__inj__{vn}
( .verinject__injector_state(verinject__injector_state),
  .clock({p_clock}),
  .unmodified(verinject_read{i}_unmodified__{vn}),
  .read_address(verinject_read{i}_address__{vn}),
  .modified(verinject_read{i}_modified__{vn}),
  .do_write({p_do_write}),
  .write_address({p_wr_addr})
);
"#,
                    lword = lword,
                    rword = rword,
                    lad = lad,
                    rad = rad,
                    larr = larr,
                    rarr = rarr,
                    pstart = pstart,
                    vn = var.name,
                    i = i,
                    p_clock = p_clock,
                    p_do_write = p_do_write,
                    p_wr_addr = p_wr_addr,
                )));
            }
        }
        Ok(())
    }

    fn impl_regwire_injections<'s>(
        &mut self,
        params: &mut ParserParams<'_, 's>,
        at_end: bool,
    ) -> PResult {
        // put all created registers
        params.output.push(Token::inject("\n".to_owned()));
        for (_, var) in params.xml_module.variables.iter() {
            let var = var.borrow();
            match VarInjectType::from_var(&var) {
                VarInjectType::None => {}
                VarInjectType::BodyReg | VarInjectType::PortReg => {
                    self.impl_reg_injections(&var, params, at_end)?;
                }
                VarInjectType::Memory => {
                    self.impl_mem_injections(&var, params, at_end)?;
                }
            }
        }
        Ok(())
    }

    fn on_identifier_in_expr<'s, 't>(
        &mut self,
        id_tok: &'t Token<'s>,
        is_write: bool,
        params: &mut ParserParams<'_, 's>,
    ) -> PResult {
        let id = &id_tok.instance as &str;
        let mut no_print = false;
        let vitype = if is_write {
            VarInjectType::PortReg
        } else {
            VarInjectType::BodyReg
        };
        if let Some(xvar) = params.xml_module.variables.get(id) {
            let xvar = xvar.borrow();
            let vi = VarInjectType::from_var(&xvar);
            if vi != VarInjectType::None {
                if is_write && !self.handled_dowrites.contains(&xvar.name) {
                    self.handled_dowrites.insert(xvar.name.clone());
                    self.push_at_always(
                        Token::inject(format!(
                            "\nverinject_do_write__{vn} = 1'b0;\n",
                            vn = xvar.name
                        )),
                        params,
                    );
                }
                if is_write {
                    self.post_statement_queue.push(format!(
                        "\nverinject_do_write__{vn} = 1'b1;\n",
                        vn = xvar.name
                    ));
                }
            }
            if vi == vitype {
                no_print = true;
                params.output.push(Token::inject(modified_ff(id)));
            }
        }
        if !no_print {
            params.output.push(id_tok.clone());
        }
        Ok(())
    }

    fn on_memory_in_expr<'s, 't>(
        &mut self,
        id_tok: &'t Token<'s>,
        index_toks: &'t [Token<'s>],
        is_write: bool,
        params: &mut ParserParams<'_, 's>,
    ) -> PResult {
        let id = &id_tok.instance as &str;
        if let Some(xvar) = params.xml_module.variables.get(id) {
            let xvar = xvar.borrow();
            if VarInjectType::from_var(&xvar) == VarInjectType::Memory {
                let addr = {
                    let mut addr = String::new();
                    let mut found_left = false;
                    let lastpos = index_toks
                        .iter()
                        .rposition(|t| t.kind == TokenKind::RBracket)
                        .unwrap();
                    for atok in index_toks.iter().take(lastpos) {
                        if !found_left && atok.kind == TokenKind::LBracket {
                            found_left = true;
                            continue;
                        }
                        addr.push_str(&atok.instance);
                    }
                    addr
                };
                if is_write {
                    if !self.handled_dowrites.contains(&xvar.name) {
                        self.handled_dowrites.insert(xvar.name.clone());
                        self.push_at_always(
                            Token::inject(format!(
                                "\nverinject_do_write__{vn} = 1'b0;\n",
                                vn = xvar.name
                            )),
                            params,
                        );
                    }
                    params.output.push(id_tok.clone());
                    self.push_tokens(index_toks, params);
                    self.post_statement_queue.push(format!(
                        r#"
  verinject_do_write__{vn} = 1'b1;
  verinject_write_address__{vn} = ({addr});
"#,
                        vn = xvar.name,
                        addr = addr
                    ));
                } else {
                    let rdent = self.mem_read_numbers.get_mut(&xvar.name).unwrap();
                    let rdnum = *rdent as u32;
                    *rdent += 1;
                    assert!(rdnum < xvar.read_count);
                    self.push_at_last_stmt(
                        Token::inject(format!(
                            r#"
  verinject_read{rdnum}_address__{vn} = {addr};
  verinject_read{rdnum}_unmodified__{vn} = {vn}[{addr}];
"#,
                            vn = xvar.name,
                            rdnum = rdnum,
                            addr = addr
                        )),
                        params,
                    );
                    params.output.push(Token::inject(format!(
                        "verinject_read{rdnum}_modified__{vn}",
                        rdnum = rdnum,
                        vn = xvar.name
                    )));
                }
            } else {
                self.on_identifier_in_expr(id_tok, is_write, params)?;
                self.push_tokens(index_toks, params);
            }
        } else {
            params.output.push(id_tok.clone());
            self.push_tokens(index_toks, params);
        }
        Ok(())
    }

    fn push_at_last_stmt<'s>(&mut self, tok: Token<'s>, params: &mut ParserParams<'_, 's>) {
        params.output.insert(self.last_stmt_end, tok);
        if self.last_always_pos >= self.last_stmt_end {
            self.last_always_pos += 1;
        }
        self.last_stmt_end += 1;
    }

    fn push_at_always<'s>(&mut self, tok: Token<'s>, params: &mut ParserParams<'_, 's>) {
        params.output.insert(self.last_always_pos, tok);
        if self.last_stmt_end >= self.last_always_pos {
            self.last_stmt_end += 1;
        }
        self.last_always_pos += 1;
    }
}

impl RtlTransform for FFErrorInjectionTransform {
    fn on_module_name<'s>(
        &mut self,
        id: &Token<'s>,
        params: &mut ParserParams<'_, 's>,
        instance: bool,
    ) -> PResult {
        params
            .output
            .push(Token::inject(modified_modname(&id.instance)));
        if instance {
            let m = params.xml_meta.modules.get(&id.instance as &str).unwrap();
            let m = m.borrow();
            self.next_dfs_order = self.dfs_order + m.bits_used;
        }
        Ok(())
    }

    fn on_end_module<'s>(&mut self, params: &mut ParserParams<'_, 's>) -> Result<(), String> {
        self.impl_regwire_injections(params, true)
    }

    fn on_no_module_parameters<'s>(
        &mut self,
        params: &mut ParserParams<'_, 's>,
    ) -> Result<(), String> {
        params.output.push(Token::inject(String::from(
            " #(parameter VERINJECT_DSTART = 0) ",
        )));
        Ok(())
    }

    fn on_post_module_parameters<'s>(
        &mut self,
        params: &mut ParserParams<'_, 's>,
    ) -> Result<(), String> {
        params.output.push(Token::inject(String::from(
            ", parameter VERINJECT_DSTART = 0",
        )));
        Ok(())
    }

    fn on_module_ports<'s>(
        &mut self,
        toks: &[Token<'s>],
        params: &mut ParserParams<'_, 's>,
    ) -> Result<(), String> {
        toks.iter()
            .filter(|t| match t.kind {
                TokenKind::KLogic(_) => false,
                _ => true,
            })
            .for_each(|t| params.output.push(t.clone()));
        Ok(())
    }

    fn on_post_module_ports<'s>(&mut self, params: &mut ParserParams<'_, 's>) -> PResult {
        params.output.push(Token::inject(
            ", input [31:0] verinject__injector_state\n".to_owned(),
        ));
        Ok(())
    }

    fn on_module_start<'s>(&mut self, params: &mut ParserParams<'_, 's>) -> PResult {
        self.impl_regwire_injections(params, false)
    }

    fn on_no_instance_parameters<'s>(
        &mut self,
        params: &mut ParserParams<'_, 's>,
    ) -> Result<(), String> {
        params.output.push(Token::inject(format!(
            " #(.VERINJECT_DSTART({dstart})) ",
            dstart = self.dfs_order
        )));
        self.dfs_order = self.next_dfs_order;
        Ok(())
    }

    fn on_post_instance_parameters<'s>(
        &mut self,
        params: &mut ParserParams<'_, 's>,
    ) -> Result<(), String> {
        params.output.push(Token::inject(format!(
            ", .VERINJECT_DSTART({dstart})",
            dstart = self.dfs_order
        )));
        self.dfs_order = self.next_dfs_order;
        Ok(())
    }

    fn on_instance_port_assignment<'s>(
        &mut self,
        id: &Token<'s>,
        params: &mut ParserParams<'_, 's>,
    ) -> PResult {
        self.on_assignment_right_simple_id(id, params)
    }

    fn on_post_instance_ports<'s>(&mut self, params: &mut ParserParams<'_, 's>) -> PResult {
        params.output.push(Token::inject(
            ", .verinject__injector_state(verinject__injector_state)".to_owned(),
        ));
        Ok(())
    }

    fn on_assignment_left_simple_id<'s>(
        &mut self,
        id_tok: &Token<'s>,
        params: &mut ParserParams<'_, 's>,
    ) -> Result<(), String> {
        self.on_identifier_in_expr(id_tok, true, params)
    }

    fn on_assignment_left_index<'s>(
        &mut self,
        id_tok: &Token<'s>,
        index_toks: &[Token<'s>],
        params: &mut ParserParams<'_, 's>,
    ) -> Result<(), String> {
        self.on_memory_in_expr(id_tok, index_toks, true, params)
    }

    fn on_assignment_right_simple_id<'s>(
        &mut self,
        id_tok: &Token<'s>,
        params: &mut ParserParams<'_, 's>,
    ) -> PResult {
        self.on_identifier_in_expr(id_tok, false, params)
    }

    fn on_assignment_right_index<'s>(
        &mut self,
        id_tok: &Token<'s>,
        index_toks: &[Token<'s>],
        params: &mut ParserParams<'_, 's>,
    ) -> Result<(), String> {
        self.on_memory_in_expr(id_tok, index_toks, false, params)
    }

    fn on_post_statement<'s>(&mut self, params: &mut ParserParams<'_, 's>) -> Result<(), String> {
        for s in self.post_statement_queue.drain(..) {
            params.output.push(Token::inject(s));
        }
        self.last_stmt_end = params.output.len();
        Ok(())
    }

    fn on_always_begin<'s>(
        &mut self,
        _kind: XmlVarUsage,
        params: &mut ParserParams<'_, 's>,
    ) -> PResult {
        self.last_always_pos = params.output.len();
        Ok(())
    }
}

pub fn ff_error_injection<'s>(
    toks: &[Token<'s>],
    xml_meta: &'s XmlMetadata,
    xml_module: &'s XmlModule,
) -> Result<Vec<Token<'s>>, String> {
    let mut ei = FFErrorInjectionTransform::default();
    ei.full_transform(toks, xml_meta, xml_module)
}
