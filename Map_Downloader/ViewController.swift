//
//  ViewController.swift
//  Map_Downloader
//
//  Created by Ihor YERIN on 10/31/19.
//  Copyright © 2019 Ihor YERIN. All rights reserved.
//

import UIKit

class ViewController: UIViewController, XMLParserDelegate {

    struct Book {
        var bookTitle: String
        var bookAuthor: String
    }
    struct Country {
        var name: String
        var type: String
        var regions: [String]
    }
    struct Region {
        var name: String
    }
    
    var books: [Book] = []
    var countries: [Country] = []
    
    var elementName: String = String()
    
    var bookTitle = String()
    var bookAuthor = String()
    
    var countryName = String()
    var countryType = String()
    
    var level = 0
    //var countryParent = String()


    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
//        if elementName == "book" {
//            if let nm = attributeDict["id"] {
//                self.nm = nm;
//            }
//            bookTitle = String()
//            bookAuthor = String()
//            print (self.nm)
//
//        }
        
        if elementName == "region" {
            level += 1
            if level == 2 {
                if let name = attributeDict["name"] {
                    countryName = name;
                    //print(name)
                }
                if let type = attributeDict["type"] {
                    countryType = type
                }
                let country = Country(name: countryName, type: countryType, regions: [])
                countries.append(country)
                //print(countryName)
            }
            if level == 3 {
                if let name = attributeDict["name"] {
                    countries[countries.count - 1].regions.append(name)
                }
                //print(countries[countries.count - 1])
            }
        }
        //self.elementName = elementName
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "region" {
            level -= 1
            //print(1)
//            let book = Book(bookTitle: bookTitle, bookAuthor: bookAuthor)
//            books.append(book)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
       // print(data)
//        if (!data.isEmpty) {
//            if self.elementName == "title" {
//                bookTitle += data
//            } else if self.elementName == "author" {
//                bookAuthor += data
//            }
//        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        if let path = Bundle.main.url(forResource: "Books", withExtension: "xml") {
//            if let parser = XMLParser(contentsOf: path) {
//                parser.delegate = self
//                parser.parse()
//            }
//        }
        if let path = Bundle.main.url(forResource: "regions", withExtension: "xml") {
            if let parser = XMLParser(contentsOf: path) {
                parser.delegate = self
                parser.parse()
            }
        }
        for country in countries {
            print(country.name)
            print(country.regions)
            print("")
        }
    }
}

