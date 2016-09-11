//
//  SearchableNode.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 11.09.16.
//
//

/// Instances of conforming types represent a document object model node
/// that can be searched by an XPath or CSS selector and also provide the node's underlying data in a
/// number of ways.
///
/// In the HTML/XML DOM (Document Object Model), everything is a node:
/// - The document itself is a document node;
/// - All HTML/XML elements are element nodes;
/// - All HTML/XML attributes are attribute nodes;
/// - Text inside HTML elements are text nodes;
/// - Comments are comment nodes.
public protocol SearchableNode: Searchable {
    
    var text: String? { get }
    
    var toHTML: String? { get }
    
    var toXML: String? { get }
    
    var innerHTML: String? { get }
    
    var className: String? { get }
    
    var tagName: String? { get set }
    
    var content: String? { get set }
}
