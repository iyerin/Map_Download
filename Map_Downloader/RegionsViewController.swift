//
//  RegionsViewController.swift
//  Map_Downloader
//
//  Created by Ihor YERIN on 11/1/19.
//  Copyright © 2019 Ihor YERIN. All rights reserved.
//

import UIKit

class RegionsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    var country: Country?
    var link: String?
    var regionCell = RegionTableViewCell()
    @IBOutlet weak var regionsTable: UITableView!
    
    //MARK: - Lifecycle
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(true)
        regionsTable.reloadData()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        navigationItem.title = country?.name
    }
    
    //MARK: - TableView
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if country?.map == true {
            return ((country?.regions.count ?? 0) + 1)
        }
        return (country?.regions.count) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  regionsTable.dequeueReusableCell(withIdentifier: "RegionCell") as! RegionTableViewCell
        cell.mapIcon.image = UIImage(named: "ic_custom_show_on_map")
        cell.downloadButton.setImage(UIImage(named: "ic_custom_import"), for: .normal)
        if indexPath.row == (country?.regions.count)! {
            cell.regionName.text = "Download all regions"
            cell.link = country?.link
        } else {
            cell.regionName.text = country?.regions[indexPath.row].name
            cell.link = country?.regions[indexPath.row].link
            if country?.regions[indexPath.row].map == false {
                cell.downloadButton.isHidden = true
            } else {
                cell.downloadButton.isHidden = false
            }
            let downloaded = MapsFileManager.checkFile(link: (country?.regions[indexPath.row].link) ?? "")
            country?.regions[indexPath.row].downloaded = downloaded
            if country!.regions[indexPath.row].downloaded == true {
                cell.mapIcon.image = UIImage(named: "green_map")
                cell.downloadButton.isEnabled = false
            }
            
        }
        cell.progress.isHidden = true
        cell.delegate = self
        
        return cell
    }
}

//MARK: - CellDelegate

extension RegionsViewController: RegionsCellDelegate {
    func onRegButtonClick(link: String, cell: RegionTableViewCell) {
            download(link: link, cell: cell)
        }
}

// MARK: - Download

extension RegionsViewController: URLSessionDownloadDelegate {
    
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
            for region in self.country!.regions {
                if region.name == self.regionCell.regionName.text {
                    break
                }
                i += 1
            }
            if i == (self.country?.regions.count)! {
           _ = self.navigationController?.popToRootViewController(animated: true)
            } else {
                self.country?.regions[i].downloaded = true
            }
            self.regionsTable.reloadData()
        }
    }
    
    func urlSession(_ session: URLSession, downloadTask: URLSessionDownloadTask, didWriteData bytesWritten: Int64, totalBytesWritten: Int64, totalBytesExpectedToWrite: Int64) {
        let progress = Float(totalBytesWritten)/Float(totalBytesExpectedToWrite)
        DispatchQueue.main.async() {
            self.regionCell.progress.progress = progress
        }
    }
    
    func download(link: String, cell: RegionTableViewCell) {
        guard let url = URL(string: link) else { return }
        let urlSession = URLSession(configuration: .default, delegate: self, delegateQueue: OperationQueue())
        let task = urlSession.downloadTask(with: url)
        task.resume()
        self.regionCell = cell
        self.regionCell.progress.progress = 0
        self.regionCell.progress.isHidden = false
    }
}
