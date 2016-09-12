//
//  LibxmlHTMLNode.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 11.09.16.
//
//

import CLibxml2

internal final class LibxmlHTMLNode: XMLElement {
    
    private var documentPointer: htmlDocPtr
    private var nodePointer: xmlNodePtr
    private var isRoot: Bool = false
    
    init(documentPointer: xmlDocPtr) {
        
        self.documentPointer  = documentPointer
        
        nodePointer = xmlDocGetRootElement(documentPointer)
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
            (">", "&gt;")
        ]
        
        return escapingRules.reduce(string) { (string, escapingRule) in
            string.replacingOccurrences(of: escapingRule.0, with: escapingRule.1, options: .regularExpression)
        }
    }
    
    // MARK: - SearchableNode
    
    var text: String? {
        return libxmlGetNodeContent(nodePointer)
    }
    
    var html: String? {
        
        let outputBuffer = xmlAllocOutputBuffer(nil)
        defer {
            xmlOutputBufferClose(outputBuffer)
        }
        
        htmlNodeDumpOutput(outputBuffer, documentPointer, nodePointer, nil)
        
        return String.decodeCString(xmlOutputBufferGetContent(outputBuffer), as: UTF8.self)?.result
    }
    
    var xml: String? {
        
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
    
    var innerHTML: String? {
        
        guard let html = html else {
            return nil
        }
        
        return html
            .replacingOccurrences(of: "</[^>]*>$", with: "", options: .regularExpression)
            .replacingOccurrences(of: "^<[^>]*>",  with: "", options: .regularExpression)
    }
    
    var className: String? {
        return self["class"]
    }
    
    var tagName: String? {
        get {
            return String.decodeCString(nodePointer.pointee.name, as: UTF8.self)?.result
        }
        set {
            if let newValue = newValue {
                xmlNodeSetName(nodePointer, newValue)
            }
        }
    }
    
    var content: String? {
        get {
            return text
        }
        set {
            if let newValue = newValue {
                xmlNodeSetContent(nodePointer, escape(newValue))
            }
        }
    }
    
    // MARK: - XMLElement
    
    var parent: XMLElement? {
        get {
            return LibxmlHTMLNode(documentPointer: documentPointer, nodePointer: nodePointer.pointee.parent)
        }
        set {
            if let node = newValue as? LibxmlHTMLNode {
                node.addChild(self)
            }
        }
    }
    
    subscript(attributeName: String) -> String? {
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
                xmlSetProp(nodePointer, attributeName, newValue)
            } else {
                xmlUnsetProp(nodePointer, attributeName)
            }
        }
    }
    
    func addPreviousSibling(_ node: XMLElement) {
        guard let node = node as? LibxmlHTMLNode else {
            return
        }
        xmlAddPrevSibling(nodePointer, node.nodePointer)
    }
    
    func addNextSibling(_ node: XMLElement) {
        guard let node = node as? LibxmlHTMLNode else {
            return
        }
        xmlAddNextSibling(nodePointer, node.nodePointer)
    }
    
    func addChild(_ node: XMLElement) {
        guard let node = node as? LibxmlHTMLNode else {
            return
        }
        xmlUnlinkNode(node.nodePointer)
        xmlAddChild(nodePointer, node.nodePointer)
    }
    
    func removeChild(_ node: XMLElement) {
        
        guard let node = node as? LibxmlHTMLNode else {
            return
        }
        xmlUnlinkNode(node.nodePointer)
        xmlFree(node.nodePointer)
    }
    
    // MARK: - Searchable
    
    func search(byXPath xpath: String, namespaces: [String : String]?) -> XPath {
        
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
        
        return XPath(documentPointer: documentPointer, object: xPathObjectPointer.pointee)
    }
    
    func search(byCSSSelector selector: String, namespaces: [String : String]?) -> XPath {
        if let xpath = CSS.toXPath(selector) {
            if isRoot {
                return search(byXPath: xpath, namespaces: namespaces)
            } else {
                return search(byXPath: "." + xpath, namespaces: namespaces)
            }
        }
        return .none
    }
}
