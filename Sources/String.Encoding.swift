//
//  String.Encoding.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 12.09.16.
//
//

import Foundation

#if !(os(macOS) || os(iOS) || os(watchOS) || os(tvOS))
internal extension String.Encoding {

    var ianaName: String? {
        
        let encodingIANANames = [
            String.Encoding.ascii.rawValue              : "us-ascii",
            String.Encoding.nextstep.rawValue           : "x-nextstep",
            String.Encoding.japaneseEUC.rawValue        : "euc-jp",
            String.Encoding.utf8.rawValue               : "utf-8",
            String.Encoding.isoLatin1.rawValue          : "iso-8859-1",
            String.Encoding.symbol.rawValue             : "x-mac-symbol",
            String.Encoding.shiftJIS.rawValue           : "cp932",
            String.Encoding.isoLatin2.rawValue          : "iso-8859-2",
            String.Encoding.windowsCP1251.rawValue      : "windows-1251",
            String.Encoding.windowsCP1252.rawValue      : "windows-1252",
            String.Encoding.windowsCP1253.rawValue      : "windows-1253",
            String.Encoding.windowsCP1254.rawValue      : "windows-1254",
            String.Encoding.windowsCP1250.rawValue      : "windows-1250",
            String.Encoding.iso2022JP.rawValue          : "iso-2022-jp",
            String.Encoding.macOSRoman.rawValue         : "macintosh",
            String.Encoding.utf16.rawValue              : "utf-16",
            String.Encoding.utf16BigEndian.rawValue     : "utf-16be",
            String.Encoding.utf16LittleEndian.rawValue  : "utf-16le",
            String.Encoding.utf32.rawValue              : "utf-32",
            String.Encoding.utf32BigEndian.rawValue     : "utf-32be",
            String.Encoding.utf32LittleEndian.rawValue  : "utf-32le"
        ]
        
        
        return encodingIANANames[rawValue]
    }
}
#endif
