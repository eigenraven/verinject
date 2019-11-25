use std::borrow::Cow;
use std::fmt::{Display, Error, Formatter};

#[derive(Copy, Clone, Debug, Eq, PartialEq, Default, Hash)]
pub struct SourceLocation {
    pub index: usize,
    pub line: usize,
    pub column: usize,
}

#[derive(Copy, Clone, Debug, Eq, PartialEq, Hash)]
pub enum TokenKind {
    ArbitraryInjected,
    Whitespace,
    Identifier,
    Number,
    Symbol,
    StringLiteral,
    Hash,
    LParen,
    RParen,
    LBracket,
    RBracket,
    LBrace,
    RBrace,
    Dot,
    Comma,
    Colon,
    At, // @
    Star,
    Semicolon,
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
    KIf,
    KCase,
    KCasex,
    KCasez,
    KFor,
    // types
    KWire,
    KLogic(bool), // also reg, arg: is logic(true) or reg(false)
    KInput,
    KOutput,
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

#[derive(Copy, Clone, Debug, Hash, Eq, PartialEq)]
#[allow(dead_code)]
pub enum VerilogType {
    Wire,
    Reg,
}

#[derive(Copy, Clone, Debug, Hash, Eq, PartialEq)]
pub enum VerilogIoQualifier {
    None,
    Input,
    Output,
    InOut,
}

#[derive(Clone, Debug, Hash)]
pub struct Token<'s> {
    pub kind: TokenKind,
    /// None for generated tokens
    pub location: Option<SourceLocation>,
    pub instance: Cow<'s, str>,
}

impl Token<'_> {
    pub fn inject(s: String) -> Self {
        Self {
            kind: TokenKind::ArbitraryInjected,
            location: None,
            instance: Cow::from(s),
        }
    }
}

/// Printing tokens back into source form
impl Display for Token<'_> {
    fn fmt(&self, f: &mut Formatter<'_>) -> Result<(), Error> {
        f.write_str(&self.instance)
    }
}

pub fn lex_source(source: &str) -> Result<Vec<Token>, String> {
    let mut v: Vec<Token> = Vec::new();
    let mut state = LexerState {
        remaining_source: source,
        loc: SourceLocation::default(),
    };
    loop {
        if let Some(t) = l_whitespace(&mut state)? {
            v.push(t);
        }
        if state.remaining_source.is_empty() {
            break;
        }
        if let Some(t) = l_number(&mut state)? {
            v.push(t);
        } else if let Some(t) = l_identifier_or_keyword(&mut state)? {
            v.push(t);
        } else if let Some(t) = l_string(&mut state)? {
            v.push(t);
        } else if let Some(t) = l_symbol(&mut state)? {
            v.push(t);
        }
    }
    Ok(v)
}

#[derive(Copy, Clone, Debug)]
struct LexerState<'s> {
    remaining_source: &'s str,
    loc: SourceLocation,
}

type LexResult<'s> = Result<Option<Token<'s>>, String>;

fn l_whitespace<'s>(state: &mut LexerState<'s>) -> LexResult<'s> {
    let orig_src = state.remaining_source;
    let orig_loc = state.loc;
    while !state.remaining_source.is_empty() {
        let src = state.remaining_source;
        if src.starts_with("//") {
            let len = src.chars().skip(2).take_while(|c| *c != '\n').count();
            state.loc.index += len + 3;
            state.loc.column = 0;
            state.loc.line += 1;
            state.remaining_source = &src[len + 3..];
        } else if src.starts_with("/*") {
            let len = src
                .find("*/")
                .ok_or_else(|| format!("/* comment not terminated at {:?}", state.loc))?;
            state.loc.index += len + 2;
            for c in src[0..len].chars() {
                if c == '\n' {
                    state.loc.column = 0;
                    state.loc.line += 1;
                } else {
                    state.loc.column += 1;
                }
            }
            state.remaining_source = &src[len + 2..];
        } else if src.chars().nth(0).unwrap().is_ascii_whitespace() {
            state.loc.index += 1;
            if state.remaining_source.chars().nth(0).unwrap() == '\n' {
                state.loc.column = 0;
                state.loc.line += 1;
            } else {
                state.loc.column += 1;
            }
            state.remaining_source = &src[1..];
        } else {
            break;
        }
    }
    if state.loc.index != orig_loc.index {
        let len = state.loc.index - orig_loc.index;
        Ok(Some(Token {
            kind: TokenKind::Whitespace,
            instance: Cow::from(&orig_src[0..len]),
            location: Some(orig_loc),
        }))
    } else {
        Ok(None)
    }
}

fn l_string<'s>(state: &mut LexerState<'s>) -> LexResult<'s> {
    let src = state.remaining_source;
    if !src.starts_with('"') {
        return Ok(None);
    }
    let len = src.chars().skip(1).take_while(|c| *c != '"').count();
    let sstr = &src[1..=len];
    let location = state.loc;
    state.loc.index += len + 2;
    state.loc.column += len + 2;
    state.remaining_source = &src[len + 2..];
    Ok(Some(Token {
        kind: TokenKind::StringLiteral,
        location: Some(location),
        instance: Cow::from(sstr),
    }))
}

fn l_identifier_or_keyword<'s>(state: &mut LexerState<'s>) -> LexResult<'s> {
    let src = state.remaining_source;
    if src.starts_with('\\') {
        // escaped_identifier
        let len = src
            .chars()
            .skip(1)
            .take_while(|c| !c.is_ascii_whitespace())
            .count();
        let id = &src[1..=len];
        let location = state.loc;
        state.loc.index += len + 1;
        state.loc.column += len + 1;
        state.remaining_source = &src[1 + len..];
        return Ok(Some(Token {
            kind: TokenKind::Identifier,
            location: Some(location),
            instance: Cow::from(id),
        }));
    }
    if !(src.chars().nth(0).unwrap().is_ascii_alphabetic() || src.chars().nth(0).unwrap() == '_') {
        return Ok(None);
    }
    let len = src
        .chars()
        .take_while(|c: &char| c.is_ascii_alphanumeric() || *c == '$' || *c == '_')
        .count();
    let id = &src[0..len];
    let location = state.loc;
    state.loc.index += len;
    state.loc.column += len;
    state.remaining_source = &src[len..];
    Ok(Some(Token {
        kind: keyword_kind(id),
        location: Some(location),
        instance: Cow::from(id),
    }))
}

fn l_number<'s>(state: &mut LexerState<'s>) -> LexResult<'s> {
    let src = state.remaining_source;
    if !src.chars().nth(0).unwrap().is_ascii_digit() {
        return Ok(None);
    }
    let len = src
        .chars()
        .take_while(|c| c.is_ascii_alphanumeric() || *c == '\'' || *c == '_' || *c == '?')
        .count();
    let nstr = &src[0..len];
    let location = state.loc;
    state.loc.index += len;
    state.loc.column += len;
    state.remaining_source = &src[len..];
    Ok(Some(Token {
        kind: TokenKind::Number,
        location: Some(location),
        instance: Cow::from(nstr),
    }))
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
        "case" => KCase,
        "casex" => KCasex,
        "casez" => KCasez,
        "if" => KIf,
        "for" => KFor,
        //
        "wire" => KWire,
        "reg" => KLogic(false),
        "logic" => KLogic(true),
        "input" => KInput,
        "output" => KOutput,
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

fn l_symbol<'s>(state: &mut LexerState<'s>) -> LexResult<'s> {
    if !state
        .remaining_source
        .chars()
        .nth(0)
        .unwrap()
        .is_ascii_punctuation()
    {
        return Ok(None);
    }
    let t = match state.remaining_source.chars().nth(0).unwrap() {
        '#' => Some(TokenKind::Hash),
        '(' => Some(TokenKind::LParen),
        ')' => Some(TokenKind::RParen),
        '[' => Some(TokenKind::LBracket),
        ']' => Some(TokenKind::RBracket),
        '{' => Some(TokenKind::LBrace),
        '}' => Some(TokenKind::RBrace),
        '.' => Some(TokenKind::Dot),
        ',' => Some(TokenKind::Comma),
        ':' => Some(TokenKind::Colon),
        ';' => Some(TokenKind::Semicolon),
        '@' => Some(TokenKind::At),
        '*' => Some(TokenKind::Star),
        _ => None,
    };
    if let Some(kind) = t {
        let location = state.loc;
        let instance = &state.remaining_source[0..1];
        state.remaining_source = &state.remaining_source[1..];
        state.loc.index += 1;
        state.loc.column += 1;
        return Ok(Some(Token {
            kind,
            instance: Cow::from(instance),
            location: Some(location),
        }));
    }
    let symlen = state
        .remaining_source
        .chars()
        .take_while(|c| c.is_ascii_punctuation())
        .count();
    let symstr = &state.remaining_source[0..symlen];
    let location = state.loc;
    state.loc.index += symlen;
    state.loc.column += symlen;
    state.remaining_source = &state.remaining_source[symlen..];
    let mut kind = TokenKind::Symbol;
    if symstr.starts_with("<=") {
        kind = TokenKind::AssignConc;
    } else if symstr.starts_with('=') && !symstr.starts_with("==") {
        kind = TokenKind::AssignSeq;
    }
    Ok(Some(Token {
        kind,
        instance: Cow::from(symstr),
        location: Some(location),
    }))
}
