use std::fmt::Write as FmtWrite;
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
    #[structopt(name = "Swap endianness", short = "e", long = "endian")]
    endian: bool,
}

impl Options {
    fn read_cmd() -> Self {
        Self::from_args()
    }
}

fn str_endian_swap(s: &str) -> String {
    let mut o = String::with_capacity(s.len());
    let sb = s.as_bytes();
    for i in (0..s.len() - 1).step_by(2).rev() {
        o.push(sb[i] as char);
        o.push(sb[i + 1] as char);
    }
    o
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
    let mut line = String::with_capacity(colwidth as usize + 2);
    for byte in inread.bytes() {
        write!(&mut line, "{:02x}", byte.expect("Error reading input"))
            .expect("Error writing output");
        columns += 2;
        if columns >= colwidth {
            lines += 1;
            columns = 0;
            if opts.endian {
                line = str_endian_swap(&line);
            }
            writeln!(&mut outwrite, "{}", &line).expect("Error writing output");
            line.clear();
        }
    }
    while columns > 0 && columns < colwidth {
        write!(&mut line, "00").expect("Error writing output");
        columns += 2;
    }
    if columns > 0 {
        lines += 1;
        if opts.endian {
            line = str_endian_swap(&line);
        }
        writeln!(&mut outwrite, "{}", &line).expect("Error writing output");
    }
    let zeropad = "0".repeat(colwidth as usize);
    for _ in 0..(opts.height - lines) {
        writeln!(&mut outwrite, "{}", &zeropad).expect("Error writing output");
    }
}
