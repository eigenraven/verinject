use crate::lexer::Token;
use crate::xmlast::XmlMetadata;

pub trait VerilogTransform {
    fn transform(&self, toks: &mut Vec<Token>, xml_meta: &XmlMetadata) -> Result<(), String>;

    fn chain<T2: VerilogTransform + Sized>(self, other: T2) -> ChainTransform<Self, T2>
    where
        Self: Sized,
    {
        ChainTransform {
            transform_a: self,
            transform_b: other,
        }
    }
}

pub struct ChainTransform<A: VerilogTransform + Sized, B: VerilogTransform + Sized> {
    transform_a: A,
    transform_b: B,
}

impl<A: VerilogTransform + Sized, B: VerilogTransform + Sized> VerilogTransform
    for ChainTransform<A, B>
{
    fn transform(&self, toks: &mut Vec<Token>, xml_meta: &XmlMetadata) -> Result<(), String> {
        self.transform_a.transform(toks, xml_meta)?;
        self.transform_b.transform(toks, xml_meta)
    }
}
