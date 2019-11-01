#![deny(unused_must_use)]

use crate::transforms::inject_ff_errors::ff_error_injection;
use std::io::prelude::*;
use std::io::ErrorKind;
use std::path::{Path, PathBuf};
use structopt::StructOpt;

mod ast;
mod lexer;
mod parser;
mod transforms;
mod xmlast;

#[derive(StructOpt, Debug)]
#[structopt(name = "verinject")]
pub struct Options {
    #[structopt(name = "Verilog file", parse(from_os_str))]
    input_file: PathBuf,
    #[structopt(name = "Verilator XML file", parse(from_os_str))]
    input_xml: PathBuf,
    #[structopt(name = "output", short, long)]
    output_file: Option<PathBuf>,
}

impl Options {
    fn read_cmd() -> Self {
        let mut opt = Self::from_args();
        opt.generate_defaults();
        opt
    }

    fn generate_defaults(&mut self) {
        if self.output_file.is_none() {
            let mut name = self
                .input_file
                .file_name()
                .unwrap_or_default()
                .to_os_string();
            name.push("_injected");
            self.output_file = Some(self.input_file.with_file_name(&name));
        }
    }
}

fn read_file(path: &Path) -> std::io::Result<String> {
    match std::fs::read_to_string(path) {
        Ok(f) => Ok(f),
        Err(e) => match e.kind() {
            ErrorKind::NotFound => {
                eprintln!("Could not find file `{}`", path.display());
                Err(e)
            }
            _ => {
                eprintln!("Could not read file `{}`: {:?}", path.display(), e);
                Err(e)
            }
        },
    }
}

fn main() -> std::io::Result<()> {
    let options = Options::read_cmd();
    let input_file = read_file(&options.input_file)?;
    let xml_file = read_file(&options.input_xml)?;
    let xml = xmlast::parse_xml_metadata(&xml_file)?;
    let token_stream = lexer::lex_source(&input_file)
        .map_err(|s| std::io::Error::new(ErrorKind::InvalidInput, s))?;
    // print lexer
    /*let mut pline = 0;
    for t in &lexed {
        while pline != t.location.unwrap().line {
            pline += 1;
            println!();
        }
        print!("{:?}({}) ", t.kind, t.instance);
    }
    println!();*/

    // transform
    let tf_stream = ff_error_injection(&token_stream, &xml)
        .map_err(|s| std::io::Error::new(ErrorKind::InvalidInput, s))?;

    // print out
    {
        let mut of = std::io::BufWriter::new(std::fs::File::create(
            options.output_file.as_ref().unwrap(),
        )?);
        for tok in tf_stream {
            write!(of, "{}", tok)?;
        }
        of.flush()?;
    }

    Ok(())
}
