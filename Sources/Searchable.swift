//
//  Searchable.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 10.09.16.
//
//

public protocol Searchable {
    
    /// Search for node from current node by XPath.
    func search(byXPath xpath: String, namespaces: [String : String]?) -> XPath
    
    func at_xpath(_ xpath: String, namespaces: [String : String]?) -> XMLElement?
    
    /// Search for node from current node by CSS selector.
    ///
    /// - parameter selector:   a CSS selector
    func search(byCSSSelector selector: String, namespaces: [String : String]?) -> XPath
    
    func at_css(_ selector: String, namespaces: [String : String]?) -> XMLElement?
}

public extension Searchable {
    
    public func search(byXPath xpath: String) -> XPath {
        return search(byXPath: xpath, namespaces: nil)
    }
    
    public func at_xpath(_ xpath: String) -> XMLElement? {
        return at_xpath(xpath, namespaces: nil)
    }
    
    public func search(byCSSSelector selector: String) -> XPath {
        return search(byCSSSelector: selector, namespaces: nil)
    }
    
    public func at_css(_ selector: String) -> XMLElement? {
        return at_css(selector, namespaces: nil)
    }
}
