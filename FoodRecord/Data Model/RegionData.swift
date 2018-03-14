//
//  RegionData.swift
//  FoodRecord
//
//  Created by Fiona Miao on 3/12/18.
//  Copyright © 2018 Fiona Miao. All rights reserved.
//

import Foundation
import RealmSwift

class Region: Object {
    @objc dynamic var title: String = ""
    
    let restaurants = List<Restaurant>()
}
