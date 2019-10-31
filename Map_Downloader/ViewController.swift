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
    }
    
    var books: [Book] = []
    var countries: [Country] = []
    
    var elementName: String = String()
    var bookTitle = String()
    var bookAuthor = String()
    
    
    var nm: String = ""

    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        
        if elementName == "book" {
            if let nm = attributeDict["id"] {
                self.nm = nm;
            }
            bookTitle = String()
            bookAuthor = String()
            print (self.nm)
        }
        
        self.elementName = elementName
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "book" {
            let book = Book(bookTitle: bookTitle, bookAuthor: bookAuthor)
            books.append(book)
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
        let data = string.trimmingCharacters(in: CharacterSet.whitespacesAndNewlines)
        
        if (!data.isEmpty) {
            if self.elementName == "title" {
                bookTitle += data
            } else if self.elementName == "author" {
                bookAuthor += data
            }
        }
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let path = Bundle.main.url(forResource: "Books", withExtension: "xml") {
            if let parser = XMLParser(contentsOf: path) {
                parser.delegate = self
                parser.parse()
            }
        }
        print(books)
    }
}

