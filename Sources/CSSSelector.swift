//
//  CSSSelector.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 16.09.16.
//
//

import Foundation

public struct CSSSelector {
    
    public let selector: String
    public let xpath: String
    
    public init?(_ selector: String) {
        
        // MARK: - Parse loop
        
        func cssSelectorToXPath(_ selector: String) -> String? {
            
            var xpath = "//"
            var string = selector
            var previousString = string
            
            while string.utf16.count > 0 {
                
                var attributes = [String]()
                var combinator = ""
                
                string = string.trimmingCharacters(in: .whitespacesAndNewlines)
                
                // If the next character sequence represents an element
                let element = getElement(&string) ?? "*"
                
                // If the next character sequence represents a class or an id of an element
                while let attribute = getClassId(&string) {
                    attributes.append(attribute)
                }
                
                // If the next character sequence represents an argument of an element
                while let attribute = getAttribute(&string) {
                    attributes.append(attribute)
                }
                
                // If the next character represents a CSS combinator
                if let combi = getCombinator(&string) {
                    combinator = combi
                }
                
                // Generate XPath phrase
                let attr = attributes.reduce("") { $0.isEmpty ? $1 : $0 + " and " + $1 }
                if attr.isEmpty {
                    xpath += "\(element)\(combinator)"
                } else {
                    xpath += "\(element)[\(attr)]\(combinator)"
                }
                
                // If nothing matches, then a selector syntax is incorrect, nothing to do here
                if string == previousString { return nil }
                
                previousString = string
            }
            
            return xpath
        }
        
        // MARK: - Token recognizers
        
        func getElement(_ string: inout String, cutMatchedSubstring: Bool = true) -> String? {
            
            /// ^([a-z0-9\*_-]+)((\|)([a-z0-9\*_-]+))?
            guard let result = firstMatch("^([a-z0-9\\*_-]+)((\\|)([a-z0-9\\*_-]+))?")(string) else { return nil }
            
            let text = substring(of: string, for: result, atIndex: 1)
            let text2 = substring(of: string, for: result, atIndex: 4)
            
            if cutMatchedSubstring {
                string = string.substring(from: result.range.length)
            }
            
            // tag with namespace
            if !text.isEmpty && !text2.isEmpty {
                return "\(text):\(text2)"
            }
            
            // tag
            if !text.isEmpty {
                return text
            }
            
            return nil
        }
        
        func getClassId(_ string: inout String, cutMatchedSubstring: Bool = true) -> String? {
            
            // ^([#.])([a-z0-9\*_-]+)
            guard let result = firstMatch("^([#.])([a-z0-9\\*_-]+)")(string) else { return nil }
            
            let attribute = substring(of: string, for: result, atIndex: 1)
            let text = substring(of: string, for: result, atIndex: 2)
            
            if cutMatchedSubstring {
                string = string.substring(from: result.range.length)
            }
            
            if attribute.hasPrefix("#") {
                return "@id = '\(text)'"
            } else if attribute.hasPrefix(".") {
                return "contains(concat(' ', normalize-space(@class), ' '), ' \(text) ')"
            }
            
            return nil
        }
        
        func getAttribute(_ string: inout String, cutMatchedSubstring: Bool = true) -> String? {
            
            if let attributeWithExpression = getAttributeWithExpression(&string,
                                                                        cutMatchedSubstring: cutMatchedSubstring) {
                return attributeWithExpression
                
            } else if let attribute = getAttributeExists(&string, cutMatchedSubstring: cutMatchedSubstring) {
                
                return attribute
                
            } else if string.hasPrefix("[") {
                
                // bad syntax attribute
                return nil
                
            } else if let attribute = getArgumentNot(&string) {
                
                return "not(\(attribute))"
                
            } else if let pseudoclass = getPseudoclass(&string, cutMatchedSubstring: cutMatchedSubstring) {
                
                return pseudoclass
            }
            
            return nil
        }
        
        func getAttributeWithExpression(_ string: inout String, cutMatchedSubstring: Bool = true) -> String? {
            
            // ^\[\s*([^~\|\^\$\*=\s]+)\s*([~\|\^\$\*]?=)\s*["']([^"]*)["']\s*\]
            guard let result = firstMatch("^\\[\\s*([^~\\|\\^\\$\\*=\\s]+)\\s*([~\\|\\^\\$\\*]?=)\\s*[\"" +
                "\']([^\"]*)[\"\']\\s*\\]")(string) else { return nil }
            
            let attribute = substring(of: string, for: result, atIndex: 1)
            let expression = substring(of: string, for: result, atIndex: 2)
            let text = substring(of: string, for: result, atIndex: 3)
            
            if cutMatchedSubstring {
                string = string.substring(from: result.range.length)
            }
            
            switch expression {
            case "!=":
                return "@\(attribute) != \(text)"
            case "~=":
                return "contains(concat(' ', @\(attribute), ' '),concat(' ', '\(text)', ' '))"
            case "|=":
                return "@\(attribute) = '\(text)' or starts-with(@\(attribute),concat('\(text)', '-'))"
            case "^=":
                return "starts-with(@\(attribute), '\(text)')"
            case "$=":
                return "substring(@\(attribute), string-length(@\(attribute)) - " +
                "string-length('\(text)') + 1, string-length('\(text)')) = '\(text)'"
            case "*=":
                return "contains(@\(attribute), '\(text)')"
            default:
                return "@\(attribute) = '\(text)'"
            }
            
        }
        
        func getAttributeExists(_ string: inout String, cutMatchedSubstring: Bool = true) -> String? {
            
            // ^\[([^\]]*)\]
            guard let result = firstMatch("^\\[([^\\]]*)\\]")(string) else { return nil }
            
            let attribute = substring(of: string, for: result, atIndex: 1)
            
            if cutMatchedSubstring {
                string = string.substring(from: result.range.length)
            }
            
            return "@\(attribute)"
        }
        
        func getArgumentNot(_ string: inout String, cutMatchedSubstring: Bool = true) -> String? {
            
            // ^:not\((.*?\)?)\)
            guard let result = firstMatch("^:not\\((.*?\\)?)\\)")(string) else { return nil }
            
            var argument = substring(of: string, for: result, atIndex: 1)
            
            if cutMatchedSubstring {
                string = string.substring(from: result.range.length)
            }
            
            if let attribute = getAttribute(&argument, cutMatchedSubstring: false) {
                return attribute
            } else if let element = getElement(&argument, cutMatchedSubstring: false) {
                return "self::\(element)"
            } else if let attribute = getClassId(&argument) {
                return attribute
            }
            
            return nil
        }
        
        func getPseudoclass(_ string: inout String, cutMatchedSubstring: Bool = true) -> String? {
            
            func nth(prefix: String, a: Int, b: Int) -> String {
                
                let sibling = "\(prefix)-sibling::*"
                
                if a == 0 {
                    return "count(\(sibling)) = \(b - 1)"
                } else if a > 0 {
                    
                    if b != 0 {
                        return "((count(\(sibling)) + 1) >= \(b)) and ((((count(\(sibling)) + 1)-\(b)) mod" +
                        " \(a)) = 0)"
                    }
                    
                    return "((count(\(sibling)) + 1) mod \(a)) = 0"
                }
                
                let a = abs(a)
                
                return "(count(\(sibling)) + 1) <= \(b)" +
                    ((a != 1) ? " and ((((count(\(sibling)) + 1)-\(b)) mod \(a) = 0)" : "")
            }
            
            // a(n) + b | a(n) - b
            func nthChild(a: Int, b: Int) -> String {
                return nth(prefix: "preceding", a: a, b: b)
            }
            
            func nthLastChild(a: Int, b: Int) -> String {
                return nth(prefix: "following", a: a, b: b)
            }
            
            // ^:(['()a-z0-9_+-]+)
            guard let result = firstMatch("^:([\'()a-z0-9_+-]+)")(string) else { return nil }
            
            let pseudoclass = substring(of: string, for: result, atIndex: 1)
            
            if cutMatchedSubstring {
                string = string.substring(from: result.range.length)
            }
            
            switch pseudoclass {
            case "first-child":
                return "count(preceding-sibling::*) = 0"
            case "last-child":
                return "count(following-sibling::*) = 0"
            case "only-child":
                return "count(preceding-sibling::*) = 0 and count(following-sibling::*) = 0"
            case "first-of-type":
                return "position() = 1"
            case "last-of-type":
                return "position() = last()"
            case "only-of-type":
                return "last() = 1"
            case "empty":
                return "not(node())"
            case "root":
                return "not(parent::*)"
            default:
                
                // ^(nth-child|nth-last-child)\(\s*(odd|even|\d+)\s*\)
                if let preudoclassWithArgument = firstMatch("^(nth-child|nth-last-child)\\(\\s*(odd|" +
                    "even|\\d+)\\s*\\)")(pseudoclass) {
                    
                    // nth-child or nth-last-child
                    let nth = substring(of: pseudoclass, for: preudoclassWithArgument, atIndex: 1)
                    
                    let argument = substring(of: pseudoclass, for: preudoclassWithArgument, atIndex: 2)
                    
                    let nthFunction = (nth == "nth-child") ? nthChild : nthLastChild
                    
                    if argument == "odd" {
                        return nthFunction(2, 1)
                    } else if argument == "even" {
                        return nthFunction(2, 0)
                    } else {
                        // Force unwrap since regexp matches only `odd`, `even` or an integer number
                        return nthFunction(0, Int(argument)!)
                    }
                    
                    // ^(nth-child|nth-last-child)\(\s*(-?\d*)n(\+\d+)?\s*\)
                } else if let pseudoclassWithArgument = firstMatch("^(nth-child|nth-last-child)\\(\\s*" +
                    "(-?\\d*)n(\\+\\d+)?\\s*\\)")(pseudoclass) {
                    
                    let nth = substring(of: pseudoclass, for: pseudoclassWithArgument, atIndex: 1)
                    let start = substring(of: pseudoclass, for: pseudoclassWithArgument, atIndex: 2)
                    let end = substring(of: pseudoclass, for: pseudoclassWithArgument, atIndex: 3)
                    
                    let nthFunc = (nth == "nth-child") ? nthChild : nthLastChild
                    
                    // Force unwrap since regexp matches only an integer number
                    let a: Int = (start == "-") ? -1 : Int(start)!
                    let b: Int = (end.isEmpty) ? 0 : Int(end)!
                    
                    return nthFunc(a, b)
                    
                    // nth-of-type\((odd|even|\d+)\)
                } else if let pseudoclassWithArgument =
                    firstMatch("nth-of-type\\((odd|even|\\d+)\\)")(pseudoclass) {
                    
                    let argument = substring(of: pseudoclass, for: pseudoclassWithArgument, atIndex: 1)
                    
                    if argument == "odd" {
                        return "(position() >= 1) and (((position()-1) mod 2) = 0)"
                    } else if argument == "even" {
                        return "(position() mod 2) = 0"
                    } else {
                        return "position() = \(argument)"
                    }
                    
                    // contains\(["'](.*?)["']\)
                } else if let sub = firstMatch("contains\\([\"\'](.*?)[\"\']\\)")(pseudoclass) {
                    
                    let text = substring(of: pseudoclass, for: sub, atIndex: 1)
                    
                    return "contains(., '\(text)')"
                    
                } else {
                    return nil
                }
            }
        }
        
        func getCombinator(_ string: inout String, cutMatchedSubstring: Bool = true) -> String? {
            
            // ^\s*([\s>+~,])\s*
            guard let result = firstMatch("^\\s*([\\s>+~,])\\s*")(string) else { return nil }
            
            let one = substring(of: string, for: result, atIndex: 1)
            
            if cutMatchedSubstring {
                string = string.substring(from: result.range.length)
            }
            
            switch one {
            case ">":
                return "/"
            case "+":
                return "/following-sibling::*[1]/self::"
            case "~":
                return "/following-sibling::"
            default:
                // ^\s*$
                if let _ = firstMatch("^\\s*$")(one) {
                    return "//"
                } else {
                    return " | //"
                }
            }
        }
        
        // MARK: - Helper methods for regular expressions
        
        func firstMatch(_ pattern: String) -> (String) -> NSTextCheckingResult? {
            
            return { string in
                
                guard let regex = try? NSRegularExpression(pattern: pattern, options: .caseInsensitive) else {
                    return nil
                }
                
                return regex.firstMatch(in: string, range: NSRange(location: 0, length: string.utf16.count))
                
            }
        }
        
        func substring(of string: String, for result: NSTextCheckingResult, atIndex index: Int) -> String {
            
            guard index < result.numberOfRanges else { return "" }
            
            let range = result.rangeAt(index)
            
            guard range.length > 0 else { return "" }
            
            return (string as NSString).substring(with: range)
        }
        
        self.selector = selector
        
        if let xpath = cssSelectorToXPath(selector) {
            self.xpath = xpath
        } else {
            return nil
        }
    }
}
