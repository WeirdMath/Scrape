//
//  XMLNodeSet.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 11.09.16.
//
//

/// Instances of this class represent an immutable collection of DOM nodes. An instance provides the interface similar to
/// the `Node`'s one.
public final class XMLNodeSet {
    
    fileprivate var nodes: [XMLElement] = []
    
    /// Concatenated HTML content of nodes in the collection. May be `nil` if no content is available.
    public var html: String? {
        
        let html = nodes.reduce("") {
            
            if let text = $1.html {
                return $0 + text
            }
            
            return $0
        }
        
        return html.isEmpty ? nil : html
    }
    
    /// Concatenated XML content of nodes in the collection. May be `nil` if no content is available.
    public var xml: String? {
        
        let xml = nodes.reduce("") {
            
            if let text = $1.xml {
                return $0 + text
            }
            
            return $0
        }
        
        return xml.isEmpty ? nil : xml
    }
    
    /// Concatenated inner HTML content of nodes in the collection.
    public var innerHTML: String? {
        
        let html = nodes.reduce("") {
            
            if let text = $1.innerHTML {
                return $0 + text
            }
            
            return $0
        }
        
        return html.isEmpty ? nil : html
    }
    
    /// Concatenated text content of nodes in the collection. May be `nil` if no content is available.
    public var text: String? {
        
        let html = nodes.reduce("") {
            
            if let text = $1.text {
                return $0 + text
            }
            
            return $0
        }
        
        return html
    }
    
    /// Creates an empty collection of nodes.
    public init() {}
    
    /// Creates a collection of nodes from the provided array of `XMLElement`s
    ///
    /// - parameter nodes: Nodes to create a node set from.
    public init(nodes: [XMLElement]) {
        self.nodes = nodes
    }
}

extension XMLNodeSet: Collection {
    
    /// The position of the first element in a nonempty collection.
    ///
    /// If the collection is empty, `startIndex` is equal to `endIndex`.
    public var startIndex: Int {
        return  nodes.startIndex
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
        return nodes.endIndex
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
    public subscript(position: Int) -> XMLElement {
        return nodes[position]
    }
    
    /// Returns the position immediately after the given index.
    ///
    /// - Parameter i: A valid index of the collection. `i` must be less than
    ///   `endIndex`.
    /// - Returns: The index value immediately after `i`.
    public func index(after i: Int) -> Int {
        return nodes.index(after: i)
    }
}

extension XMLNodeSet: Equatable {
    
    /// Returns a Boolean value indicating whether two values are equal.
    ///
    /// Equality is the inverse of inequality. For any values `a` and `b`,
    /// `a == b` implies that `a != b` is `false`.
    ///
    /// - Parameters:
    ///   - lhs: A value to compare.
    ///   - rhs: Another value to compare.
    public static func ==(lhs: XMLNodeSet, rhs: XMLNodeSet) -> Bool {
        return lhs.nodes.enumerated().map { (index: Int, element: XMLElement) in
            element.xml == rhs[index].xml
            }.reduce(true) { $0 && $1 }
    }
}

extension XMLNodeSet: CustomStringConvertible {
    
    /// A textual representation of this instance.
    ///
    /// Instead of accessing this property directly, convert an instance of any
    /// type to a string by using the `String(describing:)` initializer. For
    /// example:
    ///
    /// ```swift
    /// struct Point: CustomStringConvertible {
    ///     let x: Int, y: Int
    ///
    ///     var description: String {
    ///         return "(\(x), \(y))"
    ///     }
    /// }
    ///
    /// let p = Point(x: 21, y: 30)
    /// let s = String(describing: p)
    /// print(s)
    /// // Prints "(21, 30)"
    /// ```
    ///
    /// The conversion of `p` to a string in the assignment to `s` uses the
    /// `Point` type's `description` property.
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
