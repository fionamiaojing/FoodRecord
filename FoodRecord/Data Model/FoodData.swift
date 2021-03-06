//
//  FoodData.swift
//  FoodRecord
//
//  Created by Fiona Miao on 3/12/18.
//  Copyright © 2018 Fiona Miao. All rights reserved.
//

import Foundation
import RealmSwift

class Meal: Object {
    @objc dynamic var name: String = ""
    @objc dynamic var photoKey: String?
    @objc dynamic var des: String = ""
    @objc dynamic var rating: Int = 0
    
    var parentRestarurant = LinkingObjects(fromType: Restaurant.self, property: "meals")
}
