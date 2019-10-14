
#[derive(Copy, Clone, Debug, Eq, PartialEq, Default, Hash)]
pub struct SourceLocation {
    pub index: usize,
    pub line: usize,
    pub column: usize,
}

#[derive(Copy, Clone, Debug, Eq, PartialEq, Hash)]
pub enum TokenKind {
    Identifier,
    Number(i64),
    LParen,
    RParen,
    LBracket,
    RBracket,
    LBrace,
    RBrace,
    Dot,
    AssignSeq,
    AssignConc,
    // block headers (always, etc.)
    KAlways,
    KAlwaysComb,
    KAlwaysFF,
    KAlwaysLatch,
    KAnd,
    KAssign,
    KPosedge,
    KNegedge,
    // types
    KWire,
    KLogic, // also reg
    KIn,
    KOut,
    KInOut,
    KRef,
    // modports
    KModport,
    // assertions
    KAssume,
    KAssert,
    KProperty,
    // delimiters
    KBegin,
    KEnd,
    KInterface,
    KEndInterface,
    KModule,
    KEndModule,
}

#[derive(Copy, Clone, Debug)]
pub struct Token<'s> {
    pub kind: TokenKind,
    pub location: SourceLocation,
    pub instance: &'s str,
}

pub fn lex_source(source: &str) -> Result<Vec<Token>, String> {
    let mut v: Vec<Token> = Vec::new();
    let mut state = LexerState {
        remaining_source: source,
        loc: SourceLocation::default()
    };
    Ok(v)
}

#[derive(Copy, Clone, Debug)]
struct LexerState<'s> {
    remaining_source: &'s str,
    loc: SourceLocation,
}

type LexResult<'s> = Result<Option<Token<'s>>, String>;

fn l_identifier_or_keyword(state: &mut LexerState) -> LexResult {
    let src = state.remaining_source;
    if src.starts_with('\\') {
        // escaped_identifier
        let len = src.iter().skip(1)
            .take_while(|c| !c.is_ascii_whitespace())
            .count();
        let id = &src[1..1+len];
        let location = state.loc;
        state.loc.index += len + 1;
        state.loc.column += len + 1;
        state.remaining_source = &src[1+len..];
        return Ok(Some(Token{
            kind: TokenKind::Identifier,
            location,
            instance: id
        }));
    }
    if !(src[0].is_ascii_alphabetic() || src[0] == '_') {
        return Ok(None);
    }
    let len = src.iter()
        .take_while(|c: &char| c.is_ascii_alphanumeric() || c == '$' || c == '_')
        .count();
    let id = &src[0..len];
    let location = state.loc;
    state.loc.index += len;
    state.loc.column += len;
    state.remaining_source = &src[len..];
    return Ok(Some(Token {
        kind: keyword_kind(id),
        location,
        instance: id
    }));
    Ok(None)
}

fn l_number(state: &mut LexerState) -> LexResult {
    //
}

fn keyword_kind(id: &str) -> TokenKind {
    use TokenKind::*;
    match id {
        "always" => KAlways,
        "always_comb" => KAlwaysComb,
        "always_ff" => KAlwaysFF,
        "always_latch" => KAlwaysLatch,
        "and" => KAnd,
        "assign" => KAssign,
        "posedge" => KPosedge,
        "negedge" => KNegedge,
        //
        "wire" => KWire,
        "reg" | "logic" => KLogic,
        "in" => KIn,
        "out" => KOut,
        "inout" => KInOut,
        "ref" => KRef,
        //
        "modport" => KModport,
        //
        "assume" => KAssume,
        "assert" => KAssert,
        "property" => KProperty,
        //
        "begin" => KBegin,
        "end" => KEnd,
        "interface" => KInterface,
        "endinterface" => KEndInterface,
        "module" => KModule,
        "endmodule" => KEndModule,
        _ => TokenKind::Identifier,
    }
}
