//
//  XPathObject.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 11.09.16.
//
//

import CLibxml2

public enum XPathObject {
    case none
    case nodeSet(XMLNodeSet)
    case bool(Bool)
    case number(Double)
    case string(String)
}

extension XPathObject {
    
    internal init(docPtr: xmlDocPtr?, object: xmlXPathObject) {
        switch object.type {
        case XPATH_NODESET:
            let nodeSet = object.nodesetval
            if nodeSet == nil || nodeSet!.pointee.nodeNr == 0 || nodeSet!.pointee.nodeTab == nil {
                self = .none
                return
            }
            
            var nodes : [XMLElement] = []
            let size = Int(nodeSet!.pointee.nodeNr)
            for i in 0 ..< size {
                let node: xmlNodePtr = nodeSet!.pointee.nodeTab[i]!
                let htmlNode = libxmlHTMLNode(docPtr: docPtr, node: node)
                nodes.append(htmlNode)
            }
            self = .nodeSet(XMLNodeSet(nodes: nodes))
            return
        case XPATH_BOOLEAN:
            self = .bool(object.boolval != 0)
            return
        case XPATH_NUMBER:
            self = .number(object.floatval)
        case XPATH_STRING:
            self = .string(String.decodeCString(object.stringval, as: UTF8.self)?.result ?? "")
            return
        default:
            self = .none
            return
        }
    }
    
    public subscript(index: Int) -> XMLElement {
        return nodeSet![index]
    }
    
    public var first: XMLElement? {
        return nodeSet?.first
    }
    
    var nodeSet: XMLNodeSet? {
        if case let .nodeSet(nodeset) = self {
            return nodeset
        }
        return nil
    }
    
    var bool: Bool? {
        if case let .bool(value) = self {
            return value
        }
        return nil
    }
    
    var number: Double? {
        if case let .number(value) = self {
            return value
        }
        return nil
    }
    
    var string: String? {
        if case let .string(value) = self {
            return value
        }
        return nil
    }
    
    var nodeSetValue: XMLNodeSet {
        return nodeSet ?? XMLNodeSet()
    }
    
    var boolValue: Bool {
        return bool ?? false
    }
    
    var numberValue: Double {
        return number ?? 0.0
    }
    
    var stringValue: String {
        return string ?? ""
    }
}

extension XPathObject: Sequence {
    public typealias Iterator = AnyIterator<XMLElement>
    public func makeIterator() -> Iterator {
        var index = 0
        return AnyIterator {
            if index < self.nodeSetValue.count {
                let obj = self.nodeSetValue[index]
                index += 1
                return obj
            }
            return nil
        }
    }
}
