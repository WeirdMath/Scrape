//
//  String.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 12.09.16.
//
//

import Foundation

internal extension String {
    
    func substring(from: Int) -> String {
        return String(characters[(index(startIndex,
                                        offsetBy: from,
                                        limitedBy: endIndex) ?? startIndex) ..< endIndex])
    }
}
