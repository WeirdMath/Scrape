//
//  XMLElement.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 11.09.16.
//
//

public protocol XMLElement: Node {
    
    var parent: XMLElement? { get set }
    
    subscript(attribute: String) -> String? { get set }
    
    func addPreviousSibling(_ node: XMLElement)
    
    func addNextSibling(_ node: XMLElement)
    
    func removeChild(_ node: XMLElement)
}
