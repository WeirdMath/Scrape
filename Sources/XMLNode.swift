//
//  XMLNode.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 11.09.16.
//
//

import CLibxml2

public final class XMLNode: XMLElement {
    
    private var documentPointer: xmlDocPtr
    private var nodePointer: xmlNodePtr
    private var isRoot: Bool = false
    
    init?(documentPointer: xmlDocPtr) {
        
        self.documentPointer = documentPointer
        
        if let nodePointer = xmlDocGetRootElement(documentPointer) {
            self.nodePointer = nodePointer
        } else {
            return nil
        }
        
        isRoot = true
    }
    
    init(documentPointer: xmlDocPtr, nodePointer: xmlNodePtr) {
        self.documentPointer = documentPointer
        self.nodePointer = nodePointer
    }
    
    /// Wrapping method for libxml2's `xmlNodeGetContens(const xmlNode * cur)` function
    ///
    /// Reads the value of a node, this can be either the text carried directly by this node if it's a TEXT node
    /// or the aggregate string of the values carried by this node child's (TEXT and ENTITY_REF).
    /// Entity references are substituted.
    ///
    /// - parameter nodePtr: Pointer to the node being read
    ///
    /// - returns: A value of the node, or `nil` if no content is available.
    private func libxmlGetNodeContent(_ nodePointer: xmlNodePtr) -> String? {
        
        guard let content = xmlNodeGetContent(nodePointer) else { return nil }
        defer {
            content.deallocate(capacity: 1)
        }
        
        return String.decodeCString(content, as: UTF8.self)?.result
    }
    
    private func escape(_ string: String) -> String {
        
        let escapingRules = [
            ("&", "&amp;"),
            ("<", "&lt;"),
            (">", "&gt;"),
            ("\"", "&quot;"),
            ("'", "&apos;")
        ]
        
        return escapingRules.reduce(string) { (string, escapingRule) in
            string.replacingOccurrences(of: escapingRule.0, with: escapingRule.1, options: .regularExpression)
        }
    }
    
    // MARK: - Node
    
    /// Text content of the node. May be `nil` if no content is available.
    public var text: String? {
        return libxmlGetNodeContent(nodePointer)
    }
    
    /// HTML content of the node. It is different from `xml` property, because the value can be formatted.
    /// May be `nil` if no content is available.
    public var html: String? {
        
        let outputBuffer = xmlAllocOutputBuffer(nil)
        defer {
            xmlOutputBufferClose(outputBuffer)
        }
        
        htmlNodeDumpOutput(outputBuffer, documentPointer, nodePointer, nil)
        
        return String.decodeCString(xmlOutputBufferGetContent(outputBuffer), as: UTF8.self)?.result
    }
    
    /// XML content of the node, i. e. content as it has been loaded.
    /// May be `nil` if no content is available.
    public var xml: String? {
        
        let outputBuffer = xmlAllocOutputBuffer(nil)
        defer {
            xmlOutputBufferClose(outputBuffer)
        }
        
        xmlNodeDumpOutput(outputBuffer,
                          documentPointer,
                          nodePointer,
                          0,
                          0,
                          nil)
        
        return String.decodeCString(xmlOutputBufferGetContent(outputBuffer), as: UTF8.self)?.result
    }
    
    /// HTML content of the node without outermost tags. Only available if the `html` property is not `nil`.
    public var innerHTML: String? {
        
        return html?
            .replacingOccurrences(of: "</[^>]*>$", with: "", options: .regularExpression)
            .replacingOccurrences(of: "^<[^>]*>",  with: "", options: .regularExpression)
    }
    
    /// Value of the attribute "class" of the node. This property is `nil` if the node does not have
    /// "class" attribute
    public var className: String? {
        return self["class"]
    }
    
    /// Name of the corresponding tag for this node.
    ///
    /// - note: Setting this property to `nil` does not make any change.
    public var tagName: String? {
        get {
            return String.decodeCString(nodePointer.pointee.name, as: UTF8.self)?.result
        }
        set {
            if let newValue = newValue {
                xmlNodeSetName(nodePointer,
                               newValue.replacingOccurrences(of: "[^a-zA-Z0-9]",
                                                             with: "",
                                                             options: .regularExpression))
            }
        }
    }
    
    /// Content of the node. May be `nil` if no content is available.
    public var content: String? {
        get {
            return text
        }
        set {
            if let newValue = newValue {
                xmlNodeSetContent(nodePointer, escape(newValue))
            } else {
                xmlNodeSetContent(nodePointer, "")
            }
        }
    }
    
    // MARK: - XMLElement
    
    /// Parent node of `self` in the DOM.
    ///
    /// In the following example "foo" is a parent for nodes "bar" and "baz":
    ///
    /// ```xml
    /// <foo>
    ///   <bar>Hello</bar>
    ///   <baz>World</baz>
    /// </foo>
    /// ```
    ///
    /// If we now set "baz" to be a parent of "bar", then we get the following:
    ///
    /// ```xml
    /// <foo>
    ///   <baz>
    ///     World
    ///     <bar>Hello</bar>
    ///   </baz>
    /// </foo>
    /// ```
    public var parent: XMLElement? {
        get {
            return XMLNode(documentPointer: documentPointer, nodePointer: nodePointer.pointee.parent)
        }
        set {
            if let node = newValue as? XMLNode {
                node.addChild(self)
            }
        }
    }
    
    /// Returns a value of a specified `attribute` of `self`.
    ///
    /// In the following example let's assume that `foo` is of type `XMLNode` and
    /// represents the "foo" tag. In this case the value of `foo["class"]` is `"top-header"`.
    ///
    /// ```xml
    /// <foo class="top-header">Hello, World!</foo>
    /// ```
    ///
    /// Attribute value can also be set. If initially there were no attibute with
    /// the specified name, it will be created, otherwise its value will be rewritten.
    /// For example, if we use `foo["class"] = "subheader"`,
    /// then we get the following:
    ///
    /// ```xml
    /// <foo class="subheader">Hello, World!</foo>
    /// ```
    ///
    /// If the value we set is `nil`, the attribute will be removed:
    ///
    /// ```xml
    /// <foo>Hello, World!</foo>
    /// ```
    ///
    /// - complexity: O(n), where n is the number of attributes.
    ///
    /// - parameter attribute: The name of an attribute.
    ///
    /// - returns: A value of a specified `attribute` of `self`, or `nil` if no such attribute exist.
    public subscript(attributeName: String) -> String? {
        get {
            var attributes = nodePointer.pointee.properties
            
            while attributes != nil {
                let attribute = attributes!.pointee
                if let tagName = String.decodeCString(attribute.name, as: UTF8.self)?.result,
                    attributeName == tagName {
                    return libxmlGetNodeContent(attribute.children)
                }
                attributes = attributes!.pointee.next
            }
            
            return nil
        }
        set(newValue) {
            if let newValue = newValue {
                xmlSetProp(nodePointer, attributeName, escape(newValue))
            } else {
                xmlUnsetProp(nodePointer, attributeName)
            }
        }
    }
    
    /// Adds a new `node` as the previous sibling of `self`. If the new node was already inserted
    /// in a document, it is first unlinked from its existing context.
    ///
    /// Suppose we have the following:
    ///
    /// ```xml
    /// <foo>
    ///   <baz>
    ///     World
    ///     <bar>Hello</bar>
    ///   </baz>
    /// </foo>
    /// ```
    ///
    /// Let `self` represents the tag "baz" and `bar` represents the tag "bar".
    /// After calling `addPreviousSibling(bar)` on `self`, here will be the result:
    ///
    /// ```xml
    /// <foo>
    ///   <bar>Hello</bar>
    ///   <baz>World</baz>
    /// </foo>
    /// ```
    ///
    /// - parameter node: A node to add as a previous sibling of `self`.
    public func addPreviousSibling(_ node: XMLElement) {
        guard let node = node as? XMLNode else {
            return
        }
        xmlAddPrevSibling(nodePointer, node.nodePointer)
    }
    
    /// Adds a new `node` as the next sibling of `self`. If the new node was already inserted
    /// in a document, it is first unlinked from its existing context.
    ///
    /// Suppose we have the following:
    ///
    /// ```xml
    /// <foo>
    ///   <baz>
    ///     Hello
    ///     <bar>World</bar>
    ///   </baz>
    /// </foo>
    /// ```
    ///
    /// Let `self` represents the tag "baz" and `bar` represents the tag "bar".
    /// After calling `addNextSibling(bar)` on `self`, here will be the result:
    ///
    /// ```xml
    /// <foo>
    ///   <baz>Hello</baz>
    ///   <bar>World</bar>
    /// </foo>
    /// ```
    ///
    /// - parameter node: A node to add as a next sibling of `self`.
    public func addNextSibling(_ node: XMLElement) {
        guard let node = node as? XMLNode else {
            return
        }
        xmlAddNextSibling(nodePointer, node.nodePointer)
    }
    
    func addChild(_ node: XMLElement) {
        guard let node = node as? XMLNode else {
            return
        }
        xmlUnlinkNode(node.nodePointer)
        xmlAddChild(nodePointer, node.nodePointer)
    }
    
    /// Removes a child node of `self`.
    ///
    /// In the example below let "foo" tag is representet by `self`, whereas "bar" tag is represented
    /// by `bar`.
    ///
    /// ```xml
    /// <foo>
    ///   Hello
    ///   <bar>World</bar>
    /// </foo>
    /// ```
    ///
    /// Calling `foo.removeChild(bar)` results in the following:
    /// ```xml
    /// <foo>
    ///   Hello
    /// </foo>
    /// ```
    ///
    /// - parameter node: A node to remove. `self` must be the parent of the `node.`
    public func removeChild(_ node: XMLElement) {
        
        guard let node = node as? XMLNode,
            (node.parent as? XMLNode)?.nodePointer == self.nodePointer else {
                return
        }
        xmlUnlinkNode(node.nodePointer)
        xmlFree(node.nodePointer)
    }
    
    // MARK: - Searchable
    
    /// Searches for a node from a current node by provided XPath.
    ///
    /// - parameter xpath:      XPath to search by.
    /// - parameter namespaces: XML namespace to search in. Default value is `nil`.
    ///
    /// - returns: `XPath` enum case with an associated value.
    public func search(byXPath xpath: String, namespaces: [String : String]?) -> XPathResult {
        
        let xPathContextPointer = xmlXPathNewContext(documentPointer)
        defer {
            xmlXPathFreeContext(xPathContextPointer)
        }
        
        guard let contextPointer = xPathContextPointer else {
            return .none
        }
        
        contextPointer.pointee.node = nodePointer
        
        if let namespaces = namespaces {
            for (prefix, name) in namespaces {
                xmlXPathRegisterNs(contextPointer, prefix, name)
            }
        }
        
        let result = xmlXPathEvalExpression(xpath, contextPointer)
        defer {
            xmlXPathFreeObject(result)
        }
        
        guard let xPathObjectPointer = result else {
            return .none
        }
        
        return XPathResult(documentPointer: documentPointer, object: xPathObjectPointer.pointee)
    }
    
    #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
    /// Searches for a node from a current node by provided CSS selector.
    ///
    /// - parameter selector:   CSS selector to search by.
    /// - parameter namespaces: XML namespace to search in. Default value is `nil`.
    ///
    /// - returns: `XPath` enum case with an associated value.
    public func search(byCSSSelector selector: String, namespaces: [String : String]?) -> XPathResult {
        if let xpath = CSSSelector(selector)?.xpath {
            if isRoot {
                return search(byXPath: xpath, namespaces: namespaces)
            } else {
                return search(byXPath: "." + xpath, namespaces: namespaces)
            }
        }
        return .none
    }
    #endif
}
