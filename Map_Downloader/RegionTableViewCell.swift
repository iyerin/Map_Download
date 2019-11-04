//
//  RegionTableViewCell.swift
//  Map_Downloader
//
//  Created by Ihor YERIN on 11/1/19.
//  Copyright © 2019 Ihor YERIN. All rights reserved.
//

import UIKit
protocol RegionsCellDelegate: AnyObject {
    func onRegButtonClick(country: Country, cell: RegionTableViewCell)
}

class RegionTableViewCell: UITableViewCell {
    var country: Country?
    
    @IBOutlet weak var mapIcon: UIImageView!
    @IBOutlet weak var regionName: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var progress: UIProgressView!
    @IBAction func toDownload(_ sender: UIButton) {
        print("tyt")
        if let country = country {
            print("tyt15")
            delegate?.onRegButtonClick(country: country, cell: self)
        }
    }
    weak var delegate: RegionsCellDelegate?
    
}
