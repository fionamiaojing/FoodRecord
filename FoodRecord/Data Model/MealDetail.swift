//
//  MealDetail.swift
//  FoodRecord
//
//  Created by Fiona Miao on 3/13/18.
//  Copyright © 2018 Fiona Miao. All rights reserved.
//

import UIKit

class MealDetail: NSObject {
    
    //MARK: Properties
    var name: String
    var photo: UIImage?
    var rating: Int
    
//    //MARK: Archiving Paths
//
//    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
//    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("meals")
    
    //MARK: Types
    
    struct PropertyKey {
        static let name = "name"
        static let photo = "photo"
        static let rating = "rating"
    }
    
    //MARK: Initialization
    init?(name: String, photo: UIImage?, rating: Int) {
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
        self.photo = photo
        self.rating = rating
    }
    
}
