//
//  ParseOption.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 11.09.16.
//
//

public enum ParseOption {
    case xml(XMLParserOptions)
    case html(HTMLParserOptions)
    
    public static var defaultXML: ParseOption {
        return .xml([.recoverOnErrors, .noError, .noWarning])
    }
    
    public static var defaultHTML: ParseOption {
        return .html([.relaxedParsing, .noError, .noWarning])
    }
}
