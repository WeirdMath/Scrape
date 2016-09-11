//
//  XMLNodeSet.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 11.09.16.
//
//

public final class XMLNodeSet {
    
    fileprivate var nodes: [XMLElement] = []
    
    public var html: String? {
        
        let html = nodes.reduce("") {
            
            if let text = $1.toHTML {
                return $0 + text
            }
            
            return $0
        }
        
        return html.isEmpty ? nil : html
    }
    
    public var innerHTML: String? {
        
        let html = nodes.reduce("") {
            
            if let text = $1.innerHTML {
                return $0 + text
            }
            
            return $0
        }
        
        return html.isEmpty ? nil : html
    }
    
    public var text: String? {
        
        let html = nodes.reduce("") {
            
            if let text = $1.text {
                return $0 + text
            }
            
            return $0
        }
        
        return html
    }
    
    public init() {}
    
    public init(nodes: [XMLElement]) {
        self.nodes = nodes
    }
}

extension XMLNodeSet: Collection {
    
    public var startIndex: Int {
        return  nodes.startIndex
    }
    
    public var endIndex: Int {
        return nodes.endIndex
    }
    
    public subscript(position: Int) -> XMLElement {
        return nodes[position]
    }
    
    public func index(after i: Int) -> Int {
        return nodes.index(after: i)
    }
}
