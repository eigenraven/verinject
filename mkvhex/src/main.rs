use std::io::prelude::*;
use std::path::PathBuf;
use structopt::StructOpt;

#[derive(StructOpt, Debug)]
#[structopt(name = "mkvhex")]
pub struct Options {
    #[structopt(name = "Input binary file", parse(from_os_str))]
    input_path: PathBuf,
    #[structopt(name = "Output .hex file path", short = "o", long = "output")]
    output_path: PathBuf,
    #[structopt(
        name = "Width of a line in bits",
        short = "w",
        long = "width",
        default_value = "32"
    )]
    width: i32,
    #[structopt(
        name = "Minimum number of lines to generate",
        short = "h",
        long = "height",
        default_value = "64"
    )]
    height: i32,
    #[structopt(name = "Print extra information", short = "v", long = "verbose")]
    verbose: bool,
}

impl Options {
    fn read_cmd() -> Self {
        Self::from_args()
    }
}

fn main() {
    let opts = Options::read_cmd();
    let infile = std::fs::File::open(opts.input_path).expect("Couldn't open input file");
    let inread = std::io::BufReader::with_capacity(1024, infile);
    let outfile = std::fs::File::create(opts.output_path).expect("Couldn't create output file");
    let mut outwrite = std::io::BufWriter::with_capacity(1024, outfile);
    let colwidth = opts.width / 4;
    let mut lines = 0;
    let mut columns = 0;
    for byte in inread.bytes() {
        write!(&mut outwrite, "{:02x}", byte.expect("Error reading input"))
            .expect("Error writing output");
        columns += 2;
        if columns >= colwidth {
            lines += 1;
            columns = 0;
            writeln!(&mut outwrite).expect("Error writing output");
        }
    }
    while columns > 0 && columns < colwidth {
        write!(&mut outwrite, "00").expect("Error writing output");
        columns += 2;
    }
    if columns > 0 {
        lines += 1;
        writeln!(&mut outwrite).expect("Error writing output");
    }
    let zeropad = "0".repeat(colwidth as usize);
    for _ in 0..(opts.height - lines) {
        writeln!(&mut outwrite, "{}", &zeropad).expect("Error writing output");
    }
}
