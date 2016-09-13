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
            
            if let text = $1.html {
                return $0 + text
            }
            
            return $0
        }
        
        return html.isEmpty ? nil : html
    }
    
    public var xml: String? {
        
        let xml = nodes.reduce("") {
            
            if let text = $1.xml {
                return $0 + text
            }
            
            return $0
        }
        
        return xml.isEmpty ? nil : xml
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

extension XMLNodeSet: CustomStringConvertible {
    
    public var description: String {
        
        let nodesDescription = nodes.map { node -> String in
            let rows = String(describing: node).characters.split(separator: "\n").map(String.init)
            let indentedRows = rows.map { row -> String in
                return row.isEmpty ? "" : "\n    " + row
            }
            return indentedRows.joined()
        }.joined(separator: ",")
        
        return "[" + nodesDescription + "\n]"
    }
}
