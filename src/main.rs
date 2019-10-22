use std::io::ErrorKind;
use std::path::PathBuf;
use structopt::StructOpt;

mod ast;
mod lexer;
mod parser;

#[derive(StructOpt, Debug)]
#[structopt(name = "verinject")]
pub struct Options {
    #[structopt(name = "FILE", parse(from_os_str))]
    input_file: PathBuf,
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

fn main() -> std::io::Result<()> {
    let options = Options::read_cmd();
    let input_file = match std::fs::read_to_string(&options.input_file) {
        Ok(f) => f,
        Err(e) => match e.kind() {
            ErrorKind::NotFound => {
                eprintln!("Could not find file `{}`", options.input_file.display());
                return Err(e);
            }
            _ => {
                eprintln!(
                    "Could not read file `{}`: {:?}",
                    options.input_file.display(),
                    e
                );
                return Err(e);
            }
        },
    };
    let lexed = lexer::lex_source(&input_file)
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

    let parsed =
        parser::parse(&lexed).map_err(|s| std::io::Error::new(ErrorKind::InvalidInput, s))?;
    // print parser
    println!("{:#?}", parsed);
    Ok(())
}
