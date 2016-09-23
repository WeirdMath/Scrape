//
//  XMLDocumentType.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 11.09.16.
//
//

import CLibxml2

/// Instances of conforming types represent XML documents. Since every XML document is a node,
/// this protocol inherits all the properties and methods from the `Node` protocol. Querying
/// an instance for such properties and methods is the same as querying the root node of a document.
internal protocol XMLDocumentType: Node {
    var rootNode: XMLElement { get set }
    var documentPointer: xmlDocPtr { get }
}

/// Instances of conforming types represent XML documents. Since every XML document is a node,
/// this protocol inherits all the properties and methods from the `Node` protocol. Querying
/// an instance for such properties and methods is the same as querying the root node of a document.
extension XMLDocumentType {
    
    // MARK: - Node
    
    /// HTML content of the document. May be `nil` if no content is available.
    public final var html: String? {
        
        let outputBuffer = xmlAllocOutputBuffer(nil)
        defer {
            xmlOutputBufferClose(outputBuffer)
        }
        
        htmlDocContentDumpOutput(outputBuffer, documentPointer, nil)
        
        return String.decodeCString(xmlOutputBufferGetContent(outputBuffer), as: UTF8.self)?.result
    }
    
    /// XML content of the document. May be `nil` if no content is available.
    public final var xml: String? {
        
        var buffer: UnsafeMutablePointer<xmlChar>?
        let size: UnsafeMutablePointer<Int32>? = nil
        defer {
            xmlFree(buffer)
            size?.deinitialize()
            size?.deallocate(capacity: 1)
        }
        
        xmlDocDumpMemory(documentPointer, &buffer, size)
        
        return String.decodeCString(buffer, as: UTF8.self)?.result
    }
    
    /// Text content of the document. May be `nil` if no content is available.
    public final var text: String? {
        return rootNode.text
    }
    
    /// HTML content of the document without the root tag. Only available if the `html` property is not `nil`.
    public final var innerHTML: String? {
        return rootNode.innerHTML
    }
    
    /// Value of the attribute "class" of the root node. This property is `nil` if the node does not have a
    /// "class" attribute
    public final var className: String? {
        return rootNode.className
    }
    
    /// Name of the tag for the root node.
    ///
    /// - note: Setting this property to `nil` does not make any change.
    public final var tagName: String? {
        get {
            return rootNode.tagName
        }
        set {
            rootNode.tagName = newValue
        }
    }
    
    /// Content of the document. May be `nil` if no content is available.
    public final var content: String? {
        get {
            return text
        }
        set {
            rootNode.content = newValue
        }
    }
    
    // MARK: - Searchable
    
    /// Searches for a node from a root node by provided XPath.
    ///
    /// - parameter xpath:      XPath to search by.
    /// - parameter namespaces: XML namespace to search in. Default value is `nil`.
    ///
    /// - returns: `XPathResult` enum case with an associated value.
    public final func search(byXPath xpath: String, namespaces: [String : String]?) -> XPathResult {
        return rootNode.search(byXPath: xpath, namespaces: namespaces)
    }
    
    #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
    /// Searches for a node from a root node by provided CSS selector.
    ///
    /// - parameter selector:   CSS selector to search by.
    /// - parameter namespaces: XML namespace to search in. Default value is `nil`.
    ///
    /// - returns: `XPathResult` enum case with an associated value.
    public final func search(byCSSSelector selector: String, namespaces: [String : String]?) -> XPathResult {
        return rootNode.search(byCSSSelector: selector, namespaces: namespaces)
    }
    #endif
}
