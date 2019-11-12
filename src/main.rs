#![deny(unused_must_use)]

use crate::transforms::inject_ff_errors::ff_error_injection;
use crate::xmlast::XmlModule;
use std::cell::RefCell;
use std::io::prelude::*;
use std::io::ErrorKind;
use std::path::{Path, PathBuf};
use structopt::StructOpt;

mod lexer;
mod transforms;
mod xmlast;

#[derive(StructOpt, Debug)]
#[structopt(name = "verinject")]
pub struct Options {
    #[structopt(name = "Verilator XML path", parse(from_os_str))]
    input_xml: PathBuf,
    #[structopt(name = "Output folder for modified modules", short, long)]
    output_folder: Option<PathBuf>,
}

impl Options {
    fn read_cmd() -> Self {
        let mut opt = Self::from_args();
        opt.generate_defaults();
        opt
    }

    fn generate_defaults(&mut self) {
        if self.output_folder.is_none() {
            self.output_folder = Some(PathBuf::from("injected/"));
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
    let xml_file = read_file(&options.input_xml)?;
    let xml = xmlast::parse_xml_metadata(&xml_file)?;

    for (mname, module) in xml.modules.iter() {
        let module: &XmlModule = &(&module as &RefCell<XmlModule>).borrow();
        let input_path = Path::new(&module.path);
        let input_file = read_file(input_path)?;
        let token_stream = lexer::lex_source(&input_file)
            .map_err(|s| std::io::Error::new(ErrorKind::InvalidInput, s))?;
        // transform
        let tf_stream = ff_error_injection(&token_stream, &xml, module)
            .map_err(|s| std::io::Error::new(ErrorKind::InvalidInput, s))?;

        // print out
        {
            let mut opath = PathBuf::from(options.output_folder.as_ref().unwrap());
            if !opath.is_dir() {
                eprintln!("Given output path is not a directory!");
                return Err(std::io::Error::new(ErrorKind::NotFound, String::new()));
            }
            opath.set_file_name(format!(
                "{}__injected.{}",
                mname,
                input_path.extension().unwrap().to_str().unwrap()
            ));
            let mut of = std::io::BufWriter::new(std::fs::File::create(&opath)?);
            for tok in tf_stream {
                write!(of, "{}", tok)?;
            }
            of.flush()?;
        }
    }
    Ok(())
}
