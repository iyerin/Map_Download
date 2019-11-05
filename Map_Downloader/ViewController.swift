//
//  ViewController.swift
//  Map_Downloader
//
//  Created by Ihor YERIN on 10/31/19.
//  Copyright © 2019 Ihor YERIN. All rights reserved.
//



/* TODO
- download all regions
 */
 import UIKit

struct Country {
    var name: String
    var regions: [Region]
    var map: Bool
    var link: String
    var downloaded: Bool
}

struct Region {
    var name: String
    var map: Bool
    var link: String
    var downloaded: Bool
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
    var countryCell = CountryTableViewCell()
    var downloaded = false
    var continent = String()
    
    private func checkFile(link: String) -> Bool {
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let str = link
        var startIndex = str.index(of: ":")!
        let upperCase = CharacterSet.uppercaseLetters
        for currentCharacter in str.unicodeScalars {
            if upperCase.contains(currentCharacter) {
                startIndex = str.index(of: Character(currentCharacter))!
                break
            }
        }
        let name = String(str[startIndex...])
        let destinationURL = documentsPath.appendingPathComponent(name)
        let filePath = destinationURL.path
        if FileManager.default.fileExists(atPath: filePath) {
            return (true)
        }
        return(false)
    }
    func parseRegion() {
        
    }
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
                downloaded = checkFile(link: link)
                let country = Country(name: countryName, regions: [], map: countryMap, link: link, downloaded: downloaded)
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
                let downloaded = checkFile(link: link)
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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let path = Bundle.main.url(forResource: "regions", withExtension: "xml") {
            if let parser = XMLParser(contentsOf: path) {
                parser.delegate = self
                parser.parse()
            }
        }
        navigationController?.navigationBar.barTintColor = UIColor(red: 255/255, green: 136/255, blue: 0, alpha: 1)
        navigationController?.navigationBar.titleTextAttributes = [.foregroundColor: UIColor.white]
        let freeeSpace = Float(UIDevice.current.systemFreeSize!)/1024/1024/1024
        let totalSpace = Float(UIDevice.current.systemSize!)/1024/1024/1024
        storage.progress = (totalSpace - freeeSpace)/totalSpace
        freeSpace.text = "Free " + "\(freeeSpace)" + " GB"
        storage.tintColor = UIColor(red: 255/255, green: 136/255, blue: 0, alpha: 1)
        storage.trackTintColor = UIColor(red: 242/255, green: 242/255, blue: 243/255, alpha: 1.0)
        countries = countries.sorted { $0.name < $1.name }
    }

    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (continent)
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return (countries.count)
    }
    override func viewWillAppear(_ animated: Bool) {
        countriesTable.reloadData()
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
        cell.delegate = self
        cell.country = countries[indexPath.row]
        cell.progress.isHidden = true
        countries[indexPath.row].downloaded = checkFile(link: countries[indexPath.row].link)
        if countries[indexPath.row].downloaded == true {
            cell.mapImage.image = UIImage(named: "green_map")
            cell.toRegionsButton.isEnabled = false
        }
        
        return cell
    }
}

extension UIDevice {
    var systemSize: Int64? {
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
            let totalSize = (systemAttributes[.systemSize] as? NSNumber)?.int64Value else { return nil }
        return totalSize
    }
    var systemFreeSize: Int64? {
        guard let systemAttributes = try? FileManager.default.attributesOfFileSystem(forPath: NSHomeDirectory() as String),
            let freeSize = (systemAttributes[.systemFreeSize] as? NSNumber)?.int64Value else { return nil }
        return freeSize
    }
}

extension ViewController: URLSessionDownloadDelegate {
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didFinishDownloadingTo location: URL) {
        guard let url = downloadTask.originalRequest?.url else { return }
        let documentsPath = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let str:String = url.absoluteString
        var startIndex = str.index(of: ":")!
        let upperCase = CharacterSet.uppercaseLetters
        for currentCharacter in str.unicodeScalars {
            if upperCase.contains(currentCharacter) {
                startIndex = str.index(of: Character(currentCharacter))!
                break
            }
        }
        let name = String(str[startIndex...])
        let destinationURL = documentsPath.appendingPathComponent(name)
        try? FileManager.default.removeItem(at: destinationURL)
        do {
            try FileManager.default.copyItem(at: location, to: destinationURL)
        } catch let error {
            print("Copy Error: \(error.localizedDescription)")
        }
         DispatchQueue.main.async() {
            var i = 0
            for country in self.countries {
                if country.name == self.countryCell.countryName.text {
                    break
                }
                i += 1
            }
            self.countries[i].downloaded = true
            self.countriesTable .reloadData()
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
        DispatchQueue.main.async() {
            self.countryCell.progress.progress = progress
        }
    }

    func download(country: Country, cell: CountryTableViewCell) {
        guard let url = URL(string: country.link) else { return }
        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        let task = urlSession.downloadTask(with: url)
        task.resume()
        self.countryCell = cell
        self.countryCell.progress.progress = 0
        self.countryCell.progress.isHidden = false
    }
}

extension ViewController: CountryCellDelegate {

    func onButtonClick(country: Country, cell: CountryTableViewCell) {
        if !country.regions.isEmpty {
            let storyBoard = UIStoryboard(name: "Main", bundle:nil)
            let regionsViewController = storyBoard.instantiateViewController(withIdentifier: "RegionsViewController") as! RegionsViewController
            regionsViewController.country = country
            self.navigationController?.pushViewController(regionsViewController, animated:true)
        } else {
            download(country: country, cell: cell)
        }
    }
}


