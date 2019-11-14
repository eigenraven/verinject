use crate::lexer::Token;
use crate::lexer::VerilogType;
use crate::transforms::{PResult, ParserParams, RtlTransform};
use crate::xmlast::{XmlMetadata, XmlModule, XmlVarUsage};

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

    fn on_no_module_parameters<'s>(
        &mut self,
        params: &mut ParserParams<'_, 's>,
    ) -> Result<(), String> {
        params.output.push(Token::inject(String::from(
            "#(parameter VERINJECT_DSTART = 0)",
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

    fn on_post_module_ports<'s>(&mut self, params: &mut ParserParams<'_, 's>) -> PResult {
        params.output.push(Token::inject(
            ", input [31:0] verinject__injector_state\n".to_owned(),
        ));
        Ok(())
    }

    fn on_module_start<'s>(&mut self, params: &mut ParserParams<'_, 's>) -> PResult {
        // put all created registers
        params.output.push(Token::inject("\n".to_owned()));
        for (_, var) in params.xml_module.variables.iter() {
            let var = var.borrow();
            if var.usage != XmlVarUsage::Clocked {
                continue;
            }
            // create a verinject_modified__ff for each ff
            let mname = modified_ff(&var.name);
            let (left, right) = var.xtype.bit_range();
            let pstart = format!("VERINJECT_DSTART + {dstart}", dstart = self.dfs_order);
            self.dfs_order += var.xtype.bit_count();
            params
                .output
                .push(var.xtype.create_var(VerilogType::Reg, &mname));
            params.output.push(Token::inject(";\n".to_owned()));
            params.output.push(Token::inject(format!(
                r#"verinject_ff_injector u_verinject__inj__{vname}
  #(.LEFT({left}), .RIGHT({right}), .P_START({pstart}))
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

    fn on_no_instance_parameters<'s>(
        &mut self,
        params: &mut ParserParams<'_, 's>,
    ) -> Result<(), String> {
        params.output.push(Token::inject(format!(
            "#(.VERINJECT_DSTART({dstart}))",
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

    fn on_assignment_right_name<'s>(
        &mut self,
        id_tok: &Token<'s>,
        params: &mut ParserParams<'_, 's>,
    ) -> PResult {
        let id = &id_tok.instance as &str;
        let mut no_print = false;
        if let Some(xvar) = params.xml_module.variables.get(id) {
            if xvar.borrow().usage == XmlVarUsage::Clocked {
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
