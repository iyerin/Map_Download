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
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if country?.map == true {
            return ((country?.regions.count)! + 1)
        }
        return (country?.regions.count) ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell =  regionsTable.dequeueReusableCell(withIdentifier: "RegionCell") as! RegionTableViewCell
        cell.mapIcon.image = UIImage(named: "ic_custom_show_on_map")
        
        cell.downloadButton.setImage(UIImage(named: "ic_custom_import"), for: .normal)
        //print (country?.regions[indexPath.row].name as Any)

        if indexPath.row == (country?.regions.count)! {
            cell.regionName.text = "Download all regions"
        } else {
            cell.regionName.text = country?.regions[indexPath.row].name
            if country?.regions[indexPath.row].map == false {
                cell.downloadButton.isHidden = true
            } else {
                cell.downloadButton.isHidden = false
            }
        }
        //print(indexPath)
        return cell
    }
    

    @IBOutlet weak var regionsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

 

}
