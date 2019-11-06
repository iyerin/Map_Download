//
//  MapsFileManager.swift
//  Map_Downloader
//
//  Created by Ihor YERIN on 11/6/19.
//  Copyright © 2019 Ihor YERIN. All rights reserved.
//

import Foundation

class MapsFileManager {
    static func checkFile(link: String) -> Bool {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        var startIndex = link.index(of: ":")!
        let upperCase = CharacterSet.uppercaseLetters
        for currentCharacter in link.unicodeScalars {
            if upperCase.contains(currentCharacter) {
                startIndex = link.index(of: Character(currentCharacter))!
                break
            }
        }
        let name = String(link[startIndex...])
        let destinationURL = documentsPath.appendingPathComponent(name)
        let filePath = destinationURL.path
        if FileManager.default.fileExists(atPath: filePath) {
            return true
        }
        return false
    }
}
