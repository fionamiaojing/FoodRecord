//
//  RestaurantData.swift
//  FoodRecord
//
//  Created by Fiona Miao on 3/12/18.
//  Copyright © 2018 Fiona Miao. All rights reserved.
//

import Foundation
import RealmSwift

class Restaurant: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var color: String = ""
    @objc dynamic var score: Int = 0
    
    let meals = List<Meal>()
    
    var parentRegion = LinkingObjects(fromType: Region.self, property: "restaurants")
    
}
