//
//  Country.swift
//  Map_Downloader
//
//  Created by Ihor YERIN on 11/6/19.
//  Copyright © 2019 Ihor YERIN. All rights reserved.
//

import Foundation

struct Country {
    var name: String
    var regions: [Region]
    var map: Bool
    var link: String
    var downloaded: Bool
    var continent: String
}
