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
     return country?.regions.count ?? 0
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell =  regionsTable.dequeueReusableCell(withIdentifier: "RegionCell") as! RegionTableViewCell
        print (country?.regions[indexPath.row].name)
        return cell
    }
    

    @IBOutlet weak var regionsTable: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()

    }

 

}
