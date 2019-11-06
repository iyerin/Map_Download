//
//  Parser.swift
//  Map_Downloader
//
//  Created by Ihor YERIN on 11/6/19.
//  Copyright © 2019 Ihor YERIN. All rights reserved.
//

import Foundation

class Parser:  NSObject, XMLParserDelegate {
    
    var countries: [Country] = []
    var countryName = String()
    var countryType = String()
    var countryLink = String()
    var countryMap = true
    var regionName = String()
    var regionMap = true
    var regionLink = String()
    var level = 0
    var downloaded = false
    var continent = String()
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "region" {
            countryMap = true
            regionMap = true
            downloaded = false
            level += 1
            if level == 1 {
                if let type = attributeDict["type"] {
                    if type == "continent" {
                        if let name = attributeDict["name"] {
                            continent = name.capitalized
                        }
                    }
                }
            }
            if level == 2 {
                if let name = attributeDict["name"] {
                    countryName = name
                    let first = name.startIndex
                    let rest = String(name.dropFirst())
                    countryLink = name[first...first].uppercased() + rest
                    if let str = attributeDict["translate"] {
                        var startIndex = str.index(of: ";")!
                        let stopIndex = str.index(of: ";")!
                        let upperCase = CharacterSet.uppercaseLetters
                        for currentCharacter in str.unicodeScalars {
                            if upperCase.contains(currentCharacter) {
                                startIndex = str.index(of: Character(currentCharacter))!
                                break
                            }
                        }
                        countryName = String(str[startIndex..<stopIndex])
                    } else {
                        countryName = countryName.capitalized
                    }
                }
                if let type = attributeDict["type"] {
                    countryType = type
                    if type == "srtm" || type == "hillshade" || type == "continent" {
                        countryMap = false
                    }
                }
                
                if let mapIs = attributeDict["map"] {
                    if mapIs == "no" {
                        countryMap = false
                    }
                }
                let link = "http://download.osmand.net/download.php?standard=yes&file=" + countryLink + "_europe_2.obf.zip"
                let downloaded = false
                let country = Country(name: countryName, regions: [], map: countryMap, link: link, downloaded: downloaded, continent: continent)
                countries.append(country)
            }
            if level == 3 {
                if let name = attributeDict["name"] {
                    regionName = name
                    regionLink = name
                    if let str = attributeDict["translate"] {
                        var startIndex = str.index(of: ";")!
                        let stopIndex = str.index(of: ";")!
                        let upperCase = CharacterSet.uppercaseLetters
                        for currentCharacter in str.unicodeScalars {
                            if upperCase.contains(currentCharacter) {
                                startIndex = str.index(of: Character(currentCharacter))!
                                break
                            }
                        }
                        regionName = String(str[startIndex..<stopIndex])
                    } else {
                        regionName = regionName.capitalized
                    }
                }
                
                if let type = attributeDict["type"] {
                    if type == "srtm" || type == "hillshade" || type == "continent" {
                        regionMap = false
                    }
                }
                if let mapIs = attributeDict["map"] {
                    if mapIs == "no" {
                        regionMap = false
                    }
                }
                let link = "http://download.osmand.net/download.php?standard=yes&file=" + countryLink + "_" + regionLink + "_europe_2.obf.zip"
                let downloaded = false
                let region = Region(name: regionName, map: regionMap, link: link, downloaded: downloaded)
                countries[countries.count - 1].regions.append(region)
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "region" {
            level -= 1
        }
    }
    
    func myparser() -> [Country] {
        if let path = Bundle.main.url(forResource: "regions", withExtension: "xml") {
            if let parser = XMLParser(contentsOf: path) {
                parser.delegate = self
                parser.parse()
            }
        }
        return(countries)
    }
}
