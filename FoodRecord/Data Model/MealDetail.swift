//
//  MealDetail.swift
//  FoodRecord
//
//  Created by Fiona Miao on 3/13/18.
//  Copyright © 2018 Fiona Miao. All rights reserved.
//

import UIKit
import os.log

class MealDetail: NSObject {
    
    //MARK: Properties
    var name: String
    var des: String
    var photo: UIImage?
    var rating: Int
    
    //MARK: Initialization
    init?(name: String, des: String, photo: UIImage?, rating: Int) {
        // The name must not be empty
        guard !name.isEmpty else {
            return nil
        }
        // The rating must be between 0 and 5 inclusively
        guard (rating >= 0) && (rating <= 5) else {
            return nil
        }
        
        // Initialize stored properties.
        self.name = name
        self.des = des
        self.photo = photo
        self.rating = rating
    }
    

    
}
