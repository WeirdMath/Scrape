//
//  HTMLParserOptions.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 10.09.16.
//
//

import CLibxml2

/// This is the set of HTML parser options that can be passed down
/// to the `htmlReadDoc(_:_:_:_:)` and similar calls.
public struct HTMLParserOptions: OptionSet {
    
    public var rawValue: UInt = 0
    
    private init(_ opt: htmlParserOption) {
        rawValue = UInt(opt.rawValue)
    }
    
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    /// Creates a new instance of `XMLParserOptions` initialized with zero raw value.
    public static var allZeros: HTMLParserOptions {
        return .init(rawValue: 0)
    }
    
    /// Strict parsing Equivalent to `.allZeros`.
    public static let strict = HTMLParserOptions.allZeros
    /// Relaxed parsing.
    ///
    /// **Corresponding libxml2 enum case**: `HTML_PARSE_RECOVER`
    public static let relaxedParsing = HTMLParserOptions(HTML_PARSE_RECOVER)
    /// Do not default a doctype if not found.
    ///
    /// **Corresponding libxml2 enum case**: `HTML_PARSE_NODEFDTD`
    public static let noDefaultDTD = HTMLParserOptions(HTML_PARSE_NODEFDTD)
    /// Suppress error reports.
    ///
    /// **Corresponding libxml2 enum case**: `HTML_PARSE_NOERROR`
    public static let noError = HTMLParserOptions(HTML_PARSE_NOERROR)
    /// Suppress warning reports.
    ///
    /// **Corresponding libxml2 enum case**: `HTML_PARSE_NOWARNING`
    public static let noWarning = HTMLParserOptions(HTML_PARSE_NOWARNING)
    /// Pedantic error reporting.
    ///
    /// **Corresponding libxml2 enum case**: `HTML_PARSE_PEDANTIC`
    public static let pedantic = HTMLParserOptions(HTML_PARSE_PEDANTIC)
    /// Remove blank nodes.
    ///
    /// **Corresponding libxml2 enum case**: `HTML_PARSE_NOBLANKS`
    public static let noBlankNodes = HTMLParserOptions(HTML_PARSE_NOBLANKS)
    /// Forbid network access.
    ///
    /// **Corresponding libxml2 enum case**: `HTML_PARSE_NONET`
    public static let forbidNetworkAccess = HTMLParserOptions(HTML_PARSE_NONET)
    /// Do not add implied html/body... elements.
    ///
    /// **Corresponding libxml2 enum case**: `HTML_PARSE_NOIMPLIED`
    public static let noImpliedElements = HTMLParserOptions(HTML_PARSE_NOIMPLIED)
    /// Compact small text nodes.
    ///
    /// **Corresponding libxml2 enum case**: `HTML_PARSE_COMPACT`
    public static let compact = HTMLParserOptions(HTML_PARSE_COMPACT)
    /// Ignore internal document encoding hint.
    ///
    /// **Corresponding libxml2 enum case**: `HTML_PARSE_IGNORE_ENC`
    public static let ignoreEncoding = HTMLParserOptions(HTML_PARSE_IGNORE_ENC)
}
