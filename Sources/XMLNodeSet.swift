//
//  XMLNodeSet.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 11.09.16.
//
//

public final class XMLNodeSet {
    
    fileprivate var nodes: [XMLElement] = []
    
    public var toHTML: String? {
        let html = nodes.reduce("") {
            if let text = $1.toHTML {
                return $0 + text
            }
            return $0
        }
        return html.isEmpty == false ? html : nil
    }
    
    public var innerHTML: String? {
        let html = nodes.reduce("") {
            if let text = $1.innerHTML {
                return $0 + text
            }
            return $0
        }
        return html.isEmpty == false ? html : nil
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
    
    public subscript(index: Int) -> XMLElement {
        return nodes[index]
    }
    
    public var count: Int {
        return nodes.count
    }
    
    internal init() {
    }
    
    internal init(nodes: [XMLElement]) {
        self.nodes = nodes
    }
    
    public func at(_ index: Int) -> XMLElement? {
        return count > index ? nodes[index] : nil
    }
    
    public var first: XMLElement? {
        return at(0)
    }
    
    public var last: XMLElement? {
        return at(count-1)
    }
}

extension XMLNodeSet: Sequence {
    public typealias Iterator = AnyIterator<XMLElement>
    public func makeIterator() -> Iterator {
        var index = 0
        return AnyIterator {
            if index < self.nodes.count {
                let n = self.nodes[index]
                index += 1
                return n
            }
            return nil
        }
    }
}
