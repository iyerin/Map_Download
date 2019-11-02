//
//  ViewController.swift
//  Map_Downloader
//
//  Created by Ihor YERIN on 10/31/19.
//  Copyright © 2019 Ihor YERIN. All rights reserved.
//



/* TODO
- optimize code in parsing
- delete download button
 
 */
 import UIKit

struct Country {
    var name: String
    var regions: [Region]
    var map: Bool
    var link: String
}

struct Region {
    var name: String
    var map: Bool
    var link: String
}

class ViewController: UIViewController, XMLParserDelegate, UITableViewDelegate,  UITableViewDataSource {

    @IBOutlet weak var countriesTable: UITableView!
    @IBOutlet weak var freeSpace: UILabel!
    @IBOutlet weak var storage: UIProgressView!
    
    var countries: [Country] = []
    var countryName = String()
    var countryType = String()
    var countryLink = String()
    var countryMap = true
    var regionName = String()
    var regionMap = true
    var regionLink = String()
    var level = 0
    
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        if elementName == "region" {
            countryMap = true
            regionMap = true
            level += 1
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
                let country = Country(name: countryName, regions: [], map: countryMap, link: link)
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
                let region = Region(name: regionName, map: regionMap, link: link)
                countries[countries.count - 1].regions.append(region)
            }
        }
    }
    
    func parser(_ parser: XMLParser, didEndElement elementName: String, namespaceURI: String?, qualifiedName qName: String?) {
        if elementName == "region" {
            level -= 1
        }
    }
    
    func parser(_ parser: XMLParser, foundCharacters string: String) {
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let path = Bundle.main.url(forResource: "regions", withExtension: "xml") {
            if let parser = XMLParser(contentsOf: path) {
                parser.delegate = self
                parser.parse()
            }
        }
//        for country in countries {
//            print(country.link)
////            if country.map == false {
////                print(country.name)
////            }
//            for region in country.regions {
////                if region.map == false {
////                    print(region.name)
////                }
//                print(region.link)
//            }
//        }
        
        let freeeSpace = Float(UIDevice.current.systemFreeSize!)/1024/1024/1024
        let totalSpace = Float(UIDevice.current.systemSize!)/1024/1024/1024
        storage.progress = (totalSpace - freeeSpace)/totalSpace
        freeSpace.text = "Free " + "\(freeeSpace)" + " GB"
       // print(freeSpace, "GB")
       // print(totalSpace, "GB")
        countries = countries.sorted { $0.name < $1.name }
        //print(countries)
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (countries.count)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = countriesTable.dequeueReusableCell(withIdentifier: "CountryCell") as! CountryTableViewCell
        cell.mapImage.image = UIImage(named: "ic_custom_show_on_map")
        cell.countryName.text = countries[indexPath.row].name
        if countries[indexPath.row].regions.isEmpty {
            cell.toRegionsButton.setImage(UIImage(named: "ic_custom_import"), for: .normal)
        } else {
             cell.toRegionsButton.setImage(UIImage(named: "right_arrow"), for: .normal)
        }
        cell.downloadButton.isHidden = true
        cell.delegate = self
        cell.country = countries[indexPath.row]
        
        return cell
    }

}

extension UIDevice {
    var systemSize: Int64? {
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
            let totalSize = (systemAttributes[.systemSize] as? NSNumber)?.int64Value else {
                return nil
        }
        
        return totalSize
    }
    
    var systemFreeSize: Int64? {
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
            let freeSize = (systemAttributes[.systemFreeSize] as? NSNumber)?.int64Value else {
                return nil
        }
        
        return freeSize
    }
}

extension ViewController: CountryCellDelegate {
    func onButtonClick(country: Country) {
        //print(country.regions)
        if !country.regions.isEmpty {
            let storyBoard = UIStoryboard(name: "Main", bundle:nil)
            let regionsViewController = storyBoard.instantiateViewController(withIdentifier: "RegionsViewController") as! RegionsViewController
            regionsViewController.country = country
            self.navigationController?.pushViewController(regionsViewController, animated:true)
        } else {
//            if let url = URL(string: country.link) {
//                let urlSession = URLSession(configuration: URLSessionConfiguration.default)
//                let dataTask = urlSession.dataTask(with: url, completionHandler: { (data, response, error) in
//                    if let data = data {
//                        print("~~~> Downloaded")
//                    }
//                }).resume()
//            }
            guard let url = URL(string: country.link) else { return }
            
            let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
            
            let downloadTask = urlSession.downloadTask(with: url)
            downloadTask.resume()
        }
        
    }
}

extension ViewController:  URLSessionDownloadDelegate {
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        print("downloadLocation:", location)
    }
}

