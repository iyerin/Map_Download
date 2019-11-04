//
//  RegionTableViewCell.swift
//  Map_Downloader
//
//  Created by Ihor YERIN on 11/1/19.
//  Copyright © 2019 Ihor YERIN. All rights reserved.
//

import UIKit
protocol RegionsCellDelegate: AnyObject {
    func onRegButtonClick(link: String, cell: RegionTableViewCell)
}

class RegionTableViewCell: UITableViewCell {
    var link: String?
    weak var delegate: RegionsCellDelegate?
    
    @IBOutlet weak var mapIcon: UIImageView!
    @IBOutlet weak var regionName: UILabel!
    @IBOutlet weak var downloadButton: UIButton!
    @IBOutlet weak var progress: UIProgressView!
    @IBAction func toDownload(_ sender: UIButton) {
        if let link = link {
            delegate?.onRegButtonClick(link: link, cell: self)
        }
    }

    
    override func prepareForReuse() {
        super.prepareForReuse()
        downloadButton.isEnabled = true
        link = nil
        delegate = nil
    }
    
}
