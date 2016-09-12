//
//  String.Encoding.swift
//  Scrape
//
//  Created by Sergej Jaskiewicz on 12.09.16.
//
//

#if !(os(macOS) || os(iOS) || os(watchOS) || os(tvOS))
internal extension String.Encoding {

    var ianaName: String? {
        
        let encodingIANANames: [String.Encoding : String] = [
            .ascii              : "us-ascii",
            .nextstep           : "x-nextstep",
            .japaneseEUC        : "euc-jp",
            .utf8               : "utf-8",
            .isoLatin1          : "iso-8859-1",
            .symbol             : "x-mac-symbol",
            .shiftJIS           : "cp932",
            .isoLatin2          : "iso-8859-2",
            .unicode            : "utf-16",
            .windowsCP1251      : "windows-1251",
            .windowsCP1252      : "windows-1252",
            .windowsCP1253      : "windows-1253",
            .windowsCP1254      : "windows-1254",
            .windowsCP1250      : "windows-1250",
            .iso2022JP          : "iso-2022-jp",
            .macOSRoman         : "macintosh",
            .utf16              : "utf-16",
            .utf16BigEndian     : "utf-16be",
            .utf16LittleEndian  : "utf-16le",
            .utf32              : "utf-32",
            .utf32BigEndian     : "utf-32be",
            .utf32LittleEndian  : "utf-32le"
        ]
        
        
        return encodingIANANames[self]
    }
}
#endif
