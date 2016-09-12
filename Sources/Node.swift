//
//  Node.swift
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
public protocol Node: Searchable {
    
    /// Text content of the node. May be `nil` if no content is available.
    var text: String? { get }
    
    /// HTML content of the node. May be `nil` if no content is available.
    var html: String? { get }
    
    /// XML content of the node. May be `nil` if no content is available.
    var xml: String? { get }
    
    /// HTML content of the node without outermost tags. Only available if the `html` property is not `nil`.
    var innerHTML: String? { get }
    
    /// Value of the attribute "class" of the node. This property is `nil` if the node does not have
    /// "class" attribute
    var className: String? { get }
    
    /// Name of the corresponding tag for this node.
    ///
    /// - note: Setting this property to `nil` does not make any change.
    var tagName: String? { get set }
    
    /// Content of the node. May be `nil` if no content is available.
    var content: String? { get set }
}
