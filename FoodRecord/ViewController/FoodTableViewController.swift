//
//  FoodTableViewController.swift
//  FoodRecord
//
//  Created by Fiona Miao on 3/12/18.
//  Copyright © 2018 Fiona Miao. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework
import os.log

class FoodTableViewController: UITableViewController {
    
    let realm = try! Realm()
    
    var mealArray: Results<Meal>?
    
    var selectRestaurant: Restaurant? {
        didSet {
            loadMeal()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.rowHeight = 90.0
        
    }


    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return mealArray?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MealTableViewCell
        
        if let meal = mealArray?[indexPath.row] {
            cell.nameLabel.text = meal.name
            cell.ratingControl.rating = meal.rating
            //cell.photoImageView.image = meal.photo (convert string to UIImage)
            
        }

        return cell
    }

    //MARK: - TableView Data Delegate Method
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .destructive, title: "Delete") { (action, indexPath) in
            // delete item at indexPath
            if let mealTobeDeleted = self.mealArray?[indexPath.row] {
                do {
                    try self.realm.write {
                        self.realm.delete(mealTobeDeleted)
                    }
                } catch {
                    print("Error deleting meal \(error)")
                }
            }
            self.tableView.reloadData()
        }
        
        return [delete]
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        switch (segue.identifier ?? "") {
        case "AddItem":
            os_log("Adding a new meal.", log: OSLog.default, type: .debug)
            
        case "ShowDetail":
            guard let destinationVC = segue.destination as? FoodDetailViewController else {
                fatalError("Unexpected destination: \(segue.destination)")
            }
            
            guard let indexPath = tableView.indexPathForSelectedRow else {
                fatalError("The selected cell is not being displayed by the table")
            }
            if let selectedMeal = mealArray?[indexPath.row] {
                let name = selectedMeal.name
                let rating = selectedMeal.rating
                //let photo = selectedMeal.photo
                destinationVC.meal = MealDetail(name: name, photo: UIImage(named: "defaultphoto"), rating: rating)
            }

        default:
             fatalError("Unexpected Segue Identifier; \(segue.identifier)")
        }
    }
    
    
    //MARK: - Action
    @IBAction func unwindToMealList(sender: UIStoryboardSegue) {
        
        if let sourceVC = sender.source as? FoodDetailViewController {
            
            if let selectedIndexPath = tableView.indexPathForSelectedRow {
                do {
                    try self.realm.write {
                        if let sourceMeal = sourceVC.meal {
                            mealArray![selectedIndexPath.row].name = sourceMeal.name
                            mealArray![selectedIndexPath.row].rating = sourceMeal.rating
                            //currentRestaurant.meals[selectedIndexPath.row].photo = sourceMeal.photo
                        }
                    }
                } catch {
                    print("Error updating newMeal \(error)")
                }

            } else {
                if let currentRestaurant = selectRestaurant {
                    do {
                        try self.realm.write {
                            let newMeal = Meal()

                            if let sourceMeal = sourceVC.meal {
                                newMeal.name = sourceMeal.name
                                newMeal.rating = sourceMeal.rating
                                //newMeal.photo = meal?.photo
                                currentRestaurant.meals.append(newMeal)
                            }
                        }
                    } catch {
                        print("Error saving newMeal \(error)")
                    }
                }
            }
        }
        tableView.reloadData()
        
    }

    //MARK: Data Manipulate Method
    func loadMeal() {
        mealArray = selectRestaurant?.meals.sorted(byKeyPath: "name", ascending: true)
    }
    
    

}


