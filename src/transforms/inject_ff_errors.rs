use crate::lexer::VerilogType;
use crate::lexer::{Token, TokenKind, VerilogIoQualifier};
use crate::transforms::{PResult, ParserParams, RtlTransform};
use crate::xmlast::{XmlMetadata, XmlModule, XmlVarUsage, XmlVariable};

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
        assert_eq!(var.dir, VerilogIoQualifier::None);
        assert_eq!(var.xtype.mem1_range(), (0, 0));
        let mname = modified_ff(&var.name);
        let (left, right) = var.xtype.word_range();
        if !at_end {
            params
                .output
                .push(var.xtype.create_var(VerilogType::Wire, &mname));
            params.output.push(Token::inject(";\n".to_owned()));
        } else {
            let pstart = format!("VERINJECT_DSTART + {dstart}", dstart = self.dfs_order);
            self.dfs_order += var.xtype.bit_count();
            params.output.push(Token::inject(format!(
                r#"verinject_ff_injector #(.LEFT({left}), .RIGHT({right}), .P_START({pstart}))
 u_verinject__inj__{vname}
( .verinject__injector_state(verinject__injector_state),
  .unmodified({vname}),
  .modified({mname})
);
"#,
                vname = &var.name,
                mname = &mname,
                left = left,
                right = right,
                pstart = pstart
            )));
        }
        Ok(())
    }

    fn impl_port_injections<'s>(
        &mut self,
        var: &XmlVariable,
        params: &mut ParserParams<'_, 's>,
        at_end: bool,
    ) -> PResult {
        assert_ne!(var.dir, VerilogIoQualifier::None);
        assert_eq!(var.xtype.mem1_range(), (0, 0));
        let mname = modified_ff(&var.name);
        let (left, right) = var.xtype.word_range();
        if !at_end {
            params
                .output
                .push(var.xtype.create_var(VerilogType::Reg, &mname));
            params.output.push(Token::inject(";\n".to_owned()));
        } else {
            let pstart = format!("VERINJECT_DSTART + {dstart}", dstart = self.dfs_order);
            self.dfs_order += var.xtype.bit_count();
            params.output.push(Token::inject(format!(
                r#"verinject_ff_injector #(.LEFT({left}), .RIGHT({right}), .P_START({pstart}))
 u_verinject__inj__{vname}
( .verinject__injector_state(verinject__injector_state),
  .unmodified({mname}),
  .modified({vname})
);
"#,
                vname = &var.name,
                mname = &mname,
                left = left,
                right = right,
                pstart = pstart
            )));
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
                VarInjectType::BodyReg => {
                    self.impl_reg_injections(&var, params, at_end)?;
                }
                VarInjectType::PortReg => {
                    self.impl_port_injections(&var, params, at_end)?;
                }
                VarInjectType::Memory => { /*TODO*/ }
            }
        }
        Ok(())
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
        self.on_assignment_right_name(id, params)
    }

    fn on_post_instance_ports<'s>(&mut self, params: &mut ParserParams<'_, 's>) -> PResult {
        params.output.push(Token::inject(
            ", .verinject__injector_state(verinject__injector_state)".to_owned(),
        ));
        Ok(())
    }

    fn on_assignment_left_name<'s>(
        &mut self,
        id_tok: &Token<'s>,
        params: &mut ParserParams<'_, 's>,
    ) -> Result<(), String> {
        let id = &id_tok.instance as &str;
        let mut no_print = false;
        if let Some(xvar) = params.xml_module.variables.get(id) {
            let xvar = xvar.borrow();
            if VarInjectType::from_var(&xvar) == VarInjectType::PortReg {
                no_print = true;
                params.output.push(Token::inject(modified_ff(id)));
            }
        }
        if !no_print {
            params.output.push(id_tok.clone());
        }
        Ok(())
    }

    fn on_assignment_right_name<'s>(
        &mut self,
        id_tok: &Token<'s>,
        params: &mut ParserParams<'_, 's>,
    ) -> PResult {
        let id = &id_tok.instance as &str;
        let mut no_print = false;
        if let Some(xvar) = params.xml_module.variables.get(id) {
            let xvar = xvar.borrow();
            if VarInjectType::from_var(&xvar) == VarInjectType::BodyReg {
                no_print = true;
                params.output.push(Token::inject(modified_ff(id)));
            }
        }
        if !no_print {
            params.output.push(id_tok.clone());
        }
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
