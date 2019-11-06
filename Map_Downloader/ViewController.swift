//
//  ViewController.swift
//  Map_Downloader
//
//  Created by Ihor YERIN on 10/31/19.
//  Copyright © 2019 Ihor YERIN. All rights reserved.
//

import UIKit

class ViewController: UIViewController, XMLParserDelegate, UITableViewDelegate,  UITableViewDataSource {
    
    @IBOutlet weak var countriesTable: UITableView!
    @IBOutlet weak var freeSpace: UILabel!
    @IBOutlet weak var storage: UIProgressView!
    var countryCell: CountryTableViewCell?
    let myparser = Parser()
    var countries: [Country] = []
    
    //MARK: - Lifecycle
    
    override func viewDidLoad() {
        super.viewDidLoad()
        countries = myparser.myparser()
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
    
    //MARK: - TableView
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return (countries[0].continent)
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
        countries[indexPath.row].downloaded = MapsFileManager.checkFile(link: countries[indexPath.row].link)
        if countries[indexPath.row].downloaded == true {
            cell.mapImage.image = UIImage(named: "green_map")
            cell.toRegionsButton.isEnabled = false
        }
        
        return cell
    }
    
}

// MARK: - Download

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
                if country.name == self.countryCell?.countryName.text {
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
            self.countryCell?.progress.progress = progress
        }
    }

    func download(country: Country, cell: CountryTableViewCell) {
        guard let url = URL(string: country.link) else { return }
        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        let task = urlSession.downloadTask(with: url)
        task.resume()
        self.countryCell = cell
        self.countryCell?.progress.progress = 0
        self.countryCell?.progress.isHidden = false
    }
}

//MARK: - CellDelegate

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

//MARK: - StorageSize

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


