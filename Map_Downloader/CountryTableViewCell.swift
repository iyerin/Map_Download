//
//  CountryTableViewCell.swift
//  Map_Downloader
//
//  Created by Ihor YERIN on 11/1/19.
//  Copyright © 2019 Ihor YERIN. All rights reserved.
//

import UIKit
protocol CountryCellDelegate: AnyObject {
    func onButtonClick(country: Country, cell: CountryTableViewCell)
}

class CountryTableViewCell: UITableViewCell {

    var country: Country?
    @IBOutlet weak var mapImage: UIImageView!
    @IBOutlet weak var countryName: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var toRegionsButton: UIButton!
    @IBOutlet weak var progress: UIProgressView!
    @IBAction func toRegions(_ sender: UIButton) {
        if let country = country {
            delegate?.onButtonClick(country: country, cell: self)
        }
    }
    weak var delegate: CountryCellDelegate?
    
    override func prepareForReuse() {
        super.prepareForReuse()
        downloadButton.isHidden = false
        toRegionsButton.isHidden = false
        toRegionsButton.isEnabled = true
        
        
        country = nil
        delegate = nil
    }
}
