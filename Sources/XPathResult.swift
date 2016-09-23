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
    
    internal init(documentPointer: xmlDocPtr, object: xmlXPathObject) {
        
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
    
    internal var nodeSetValue: XMLNodeSet {
        if case let .nodeSet(nodeset) = self {
            return nodeset
        } else {
            return XMLNodeSet()
        }
    }
    
    internal var boolValue: Bool {
        if case let .bool(value) = self {
            return value
        } else {
            return false
        }
    }
    
    internal var numberValue: Double {
        if case let .number(value) = self {
            return value
        } else {
            return 0.0
        }
    }
    
    internal var stringValue: String {
        if case let .string(value) = self {
            return value
        } else {
            return ""
        }
    }
}

extension XPathResult: Collection {
    
    /// The position of the first element in a nonempty collection.
    ///
    /// If the collection is empty, `startIndex` is equal to `endIndex`.
    public var startIndex: Int {
        return nodeSetValue.startIndex
    }
    
    /// The collection's "past the end" position---that is, the position one
    /// greater than the last valid subscript argument.
    ///
    /// When you need a range that includes the last element of a collection, use
    /// the half-open range operator (`..<`) with `endIndex`. The `..<` operator
    /// creates a range that doesn't include the upper bound, so it's always
    /// safe to use with `endIndex`. For example:
    ///
    /// ```swift
    /// let numbers = [10, 20, 30, 40, 50]
    /// if let index = numbers.index(of: 30) {
    ///     print(numbers[index ..< numbers.endIndex])
    /// }
    /// // Prints "[30, 40, 50]"
    /// ```
    ///
    /// If the collection is empty, `endIndex` is equal to `startIndex`.
    public var endIndex: Int {
        return nodeSetValue.endIndex
    }
    
    /// Accesses the element at the specified position.
    ///
    /// The following example accesses an element of an array through its
    /// subscript to print its value:
    ///
    /// ```swift
    /// var streets = ["Adams", "Bryant", "Channing", "Douglas", "Evarts"]
    /// print(streets[1])
    /// // Prints "Bryant"
    /// ```
    ///
    /// You can subscript a collection with any valid index other than the
    /// collection's end index. The end index refers to the position one past
    /// the last element of a collection, so it doesn't correspond with an
    /// element.
    ///
    /// - Parameter position: The position of the element to access. `position`
    ///   must be a valid index of the collection that is not equal to the
    ///   `endIndex` property.
    public subscript(index: Int) -> XMLElement {
        return nodeSetValue[index]
    }
    
    /// Returns the position immediately after the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    /// - Returns: The index value immediately after `i`.
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
