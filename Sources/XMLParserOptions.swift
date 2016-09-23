//
//  XMLParserOptions.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 10.09.16.
//
//

import CLibxml2

/// This is the set of XML parser options that can be passed down
/// to the `XMLDocument` initializers.
public struct XMLParserOptions: OptionSet {
    
    /// The corresponding value of the raw type.
    ///
    /// A new instance initialized with `rawValue` will be equivalent to this
    /// instance. For example:
    ///
    /// ```swift
    /// enum PaperSize: String {
    ///     case A4, A5, Letter, Legal
    /// }
    ///
    /// let selectedSize = PaperSize.Letter
    /// print(selectedSize.rawValue)
    /// // Prints "Letter"
    ///
    /// print(selectedSize == PaperSize(rawValue: selectedSize.rawValue)!)
    /// // Prints "true"
    /// ```
    public var rawValue: UInt = 0
    
    /// Creates a new option set from the given raw value.
    ///
    /// This initializer always succeeds, even if the value passed as `rawValue`
    /// exceeds the static properties declared as part of the option set. This
    /// example creates an instance of `ShippingOptions` with a raw value beyond
    /// the highest element, with a bit mask that effectively contains all the
    /// declared static members.
    ///
    /// ```swift
    /// let extraOptions = ShippingOptions(rawValue: 255)
    /// print(extraOptions.isStrictSuperset(of: .all))
    /// // Prints "true"
    /// ```
    ///
    /// - Parameter rawValue: The raw value of the option set to create. Each bit
    ///   of `rawValue` potentially represents an element of the option set,
    ///   though raw values may include bits that are not defined as distinct
    ///   values of the `OptionSet` type.
    public init(rawValue: UInt) {
        self.rawValue = rawValue
    }
    
    private init(_ opt: xmlParserOption) {
        rawValue = UInt(opt.rawValue)
    }
    
    /// Default parsing option.
    ///
    /// Equivalent to `[.recoverOnErrors, .noError, .noWarning]`.
    public static let `default`: XMLParserOptions = [.recoverOnErrors, .noError, .noWarning]
    
    /// Creates a new instance of `XMLParserOptions` initialized with zero raw value.
    public static var allZeros: XMLParserOptions {
        return .init(rawValue: 0)
    }
    
    /// Strict parsing. Equivalent to `.allZeros`.
    public static let strict = XMLParserOptions.allZeros
    
    /// Recover on errors.
    ///
    /// **Corresponding libxml2 enum case**: `XML_PARSE_RECOVER`
    public static let recoverOnErrors = XMLParserOptions(XML_PARSE_RECOVER)
    
    /// Substitute entities.
    ///
    /// **Corresponding libxml2 enum case**: `XML_PARSE_NOENT`
    public static let substituteEntities = XMLParserOptions(XML_PARSE_NOENT)
    
    /// Load the external subset.
    ///
    /// **Corresponding libxml2 enum case**: `XML_PARSE_DTDLOAD`
    public static let loadExternalSubset = XMLParserOptions(XML_PARSE_DTDLOAD)
    
    /// Default DTD attributes.
    ///
    /// **Corresponding libxml2 enum case**: `XML_PARSE_DTDATTR`
    public static let defaultDTDAttributes = XMLParserOptions(XML_PARSE_DTDATTR)
    
    /// Validate with the DTD.
    ///
    /// **Corresponding libxml2 enum case**: `XML_PARSE_DTDVALID`
    public static let validateWithDTD = XMLParserOptions(XML_PARSE_DTDVALID)
    
    /// Suppress error reports.
    ///
    /// **Corresponding libxml2 enum case**: `XML_PARSE_NOERROR`
    public static let noError = XMLParserOptions(XML_PARSE_NOERROR)
    
    /// Suppress warning reports.
    ///
    /// **Corresponding libxml2 enum case**: `XML_PARSE_NOWARNING`
    public static let noWarning = XMLParserOptions(XML_PARSE_NOWARNING)
    
    /// Pedantic error reporting.
    ///
    /// **Corresponding libxml2 enum case**: `XML_PARSE_PEDANTIC`
    public static let pedantic = XMLParserOptions(XML_PARSE_PEDANTIC)
    
    /// Remove blank nodes.
    ///
    /// **Corresponding libxml2 enum case**: `XML_PARSE_NOBLANKS`
    public static let noBlankNodes = XMLParserOptions(XML_PARSE_NOBLANKS)
    
    /// Use the SAX1 interface internally.
    ///
    /// **Corresponding libxml2 enum case**: `XML_PARSE_SAX1`
    public static let useSAX1 = XMLParserOptions(XML_PARSE_SAX1)
    
    /// Implement XInclude substitition.
    ///
    /// **Corresponding libxml2 enum case**: `XML_PARSE_XINCLUDE`
    public static let xInclude = XMLParserOptions(XML_PARSE_XINCLUDE)
    
    /// Forbid network access.
    ///
    /// **Corresponding libxml2 enum case**: `XML_PARSE_NONET`
    public static let forbidNetworkAccess = XMLParserOptions(XML_PARSE_NONET)
    
    /// Do not reuse the context dictionary.
    ///
    /// **Corresponding libxml2 enum case**: `XML_PARSE_NODICT`
    public static let noContextDictionary = XMLParserOptions(XML_PARSE_NODICT)
    
    /// Remove redundant namespaces declarations.
    ///
    /// **Corresponding libxml2 enum case**: `XML_PARSE_NSCLEAN`
    public static let cleanNamespace = XMLParserOptions(XML_PARSE_NSCLEAN)
    
    /// Merge CDATA as text nodes.
    ///
    /// **Corresponding libxml2 enum case**: `XML_PARSE_NOCDATA`
    public static let noCDATA = XMLParserOptions(XML_PARSE_NOCDATA)
    
    /// Do not generate XINCLUDE START/END nodes.
    ///
    /// **Corresponding libxml2 enum case**: `XML_PARSE_NOXINCNODE`
    public static let noXIncludeNodes = XMLParserOptions(XML_PARSE_NOXINCNODE)
    
    /// Compact small text nodes; no modification of the tree allowed afterwards
    /// (will possibly crash if you try to modify the tree).
    ///
    /// **Corresponding libxml2 enum case**: `XML_PARSE_COMPACT`
    public static let compact = XMLParserOptions(XML_PARSE_COMPACT)
    
    /// Parse using XML-1.0 before update 5.
    ///
    /// **Corresponding libxml2 enum case**: `XML_PARSE_OLD10`
    public static let old10 = XMLParserOptions(XML_PARSE_OLD10)
    
    /// Do not fixup XINCLUDE xml:base uris.
    ///
    /// **Corresponding libxml2 enum case**: `XML_PARSE_NOBASEFIX`
    public static let noBasefix = XMLParserOptions(XML_PARSE_NOBASEFIX)
    
    /// Relax any hardcoded limit from the parser.
    ///
    /// **Corresponding libxml2 enum case**: `XML_PARSE_HUGE`
    public static let huge = XMLParserOptions(XML_PARSE_HUGE)
    
    /// Parse using SAX2 interface before 2.7.0.
    ///
    /// **Corresponding libxml2 enum case**: `XML_PARSE_OLDSAX`
    public static let oldSAX = XMLParserOptions(XML_PARSE_OLDSAX)
    
    /// Ignore internal document encoding hint.
    ///
    /// **Corresponding libxml2 enum case**: `XML_PARSE_IGNORE_ENC`
    public static let ignoreEncoding = XMLParserOptions(XML_PARSE_IGNORE_ENC)
    
    /// Store big lines numbers in text PSVI field.
    ///
    /// **Corresponding libxml2 enum case**: `XML_PARSE_BIG_LINES`
    public static let bigLines = XMLParserOptions(XML_PARSE_BIG_LINES)
}

