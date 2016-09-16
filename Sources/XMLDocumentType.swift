//
//  XMLDocumentType.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 11.09.16.
//
//

import CLibxml2

internal protocol XMLDocumentType: Node {
    var rootNode: XMLElement { get set }
    var documentPointer: xmlDocPtr { get }
}

extension XMLDocumentType {
    
    // MARK: - Node
    
    public final var html: String? {
        
        let outputBuffer = xmlAllocOutputBuffer(nil)
        defer {
            xmlOutputBufferClose(outputBuffer)
        }
        
        htmlDocContentDumpOutput(outputBuffer, documentPointer, nil)
        
        return String.decodeCString(xmlOutputBufferGetContent(outputBuffer), as: UTF8.self)?.result
    }
    
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
    
    public final var text: String? {
        return rootNode.text
    }
    
    public final var innerHTML: String? {
        return rootNode.innerHTML
    }
    
    public final var className: String? {
        return rootNode.className
    }
    
    public final var tagName: String? {
        get {
            return rootNode.tagName
        }
        set {
            rootNode.tagName = newValue
        }
    }
    
    public final var content: String? {
        get {
            return text
        }
        set {
            rootNode.content = newValue
        }
    }
    
    // MARK: - Searchable
    
    public final func search(byXPath xpath: String, namespaces: [String : String]?) -> XPathResult {
        return rootNode.search(byXPath: xpath, namespaces: namespaces)
    }
    
    #if os(macOS) || os(iOS) || os(watchOS) || os(tvOS)
    public final func search(byCSSSelector selector: String, namespaces: [String : String]?) -> XPathResult {
        return rootNode.search(byCSSSelector: selector, namespaces: namespaces)
    }
    #endif
}
