//
//  XPathResult.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 11.09.16.
//
//

import CLibxml2

/// This enum represents a result of a search by an XPath.
///
/// - none:    The result value is undefined
/// - nodeSet: The result value is a node set
/// - bool:    The result value is a boolean
/// - number:  The result value is a number
/// - string:  The result value is a string
public enum XPathResult {
    
    /// The result value is undefined
    case none
    
    /// The result value is a node set
    case nodeSet(XMLNodeSet)
    
    /// The result value is a boolean
    case bool(Bool)
    
    /// The result value is a number
    case number(Double)
    
    /// The result value is a string
    case string(String)
}

internal extension XPathResult {
    
    init(documentPointer: xmlDocPtr, object: xmlXPathObject) {
        
        switch object.type {
        case XPATH_NODESET:
            
            guard let nodeSet = object.nodesetval,
                nodeSet.pointee.nodeNr != 0 || nodeSet.pointee.nodeTab != nil else {
                    
                    self = .none
                    return
            }

            /// Number of nodes in the `nodeSet`
            let size = Int(nodeSet.pointee.nodeNr)
            
            let nodes: [XMLElement] = (0 ..< size).map { i in
                
                // `nodeTab` is an array of nodes with no particular order
                let node = nodeSet.pointee.nodeTab[i]!
                return XMLNode(documentPointer: documentPointer, nodePointer: node)
            }

            self = .nodeSet(XMLNodeSet(nodes: nodes))
            
        case XPATH_BOOLEAN:
            self = .bool(object.boolval != 0)
            
        case XPATH_NUMBER:
            self = .number(object.floatval)
            
        case XPATH_STRING:
            self = .string(String.decodeCString(object.stringval, as: UTF8.self)?.result ?? "")
            
        default:
            self = .none
        }
    }
    
    var nodeSetValue: XMLNodeSet {
        if case let .nodeSet(nodeset) = self {
            return nodeset
        } else {
            return XMLNodeSet()
        }
    }
    
    var boolValue: Bool {
        if case let .bool(value) = self {
            return value
        } else {
            return false
        }
    }
    
    var numberValue: Double {
        if case let .number(value) = self {
            return value
        } else {
            return 0.0
        }
    }
    
    var stringValue: String {
        if case let .string(value) = self {
            return value
        } else {
            return ""
        }
    }
}

extension XPathResult: Collection {
    
    public var startIndex: Int {
        return nodeSetValue.startIndex
    }
    
    public var endIndex: Int {
        return nodeSetValue.endIndex
    }
    
    public subscript(index: Int) -> XMLElement {
        return nodeSetValue[index]
    }
    
    public func index(after i: Int) -> Int {
        return nodeSetValue.index(after: i)
    }
}

extension XPathResult: Equatable {
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: XPathResult, rhs: XPathResult) -> Bool {
        switch (lhs, rhs) {
        case (.none, .none):
            return true
        case (.nodeSet(let value0), .nodeSet(let value1)):
            return value0 == value1
        case (.bool(let value0), .bool(let value1)):
            return value0 == value1
        case (.number(let value0), .number(let value1)):
            return value0 == value1
        case (.string(let value0), .string(let value1)):
            return value0 == value1
        default:
            return false
        }
    }

    
}
