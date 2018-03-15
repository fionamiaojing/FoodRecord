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
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var mealArray: Results<Meal>?
    
    var selectRestaurant: Restaurant? {
        didSet {
            loadMeal()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        tableView.rowHeight = 90.0
        
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        return mealArray?.count ?? 1
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath) as! MealTableViewCell
        
        if let meal = mealArray?[indexPath.row], let currentRestaurant = selectRestaurant {
            cell.nameLabel.text = meal.name
            cell.ratingControl.rating = meal.rating
            //change 5
            let photokey = currentRestaurant.name + meal.name
            cell.photoImageView.image = getImage(key: photokey)
            
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
            if let selectedMeal = mealArray?[indexPath.row], let currentRestaurant = selectRestaurant {
                let name = selectedMeal.name
                let rating = selectedMeal.rating
                let des = selectedMeal.des

                let photoKey = currentRestaurant.name + selectedMeal.name
                let photo = getImage(key: photoKey)
                destinationVC.meal = MealDetail(name: name, des: des, photo: photo, rating: rating)
                
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
                            mealArray![selectedIndexPath.row].des = sourceMeal.des
                            if let photo = sourceMeal.photo, let currentRestaurant = selectRestaurant {
                                print(photo)
                                //change 3
                                let photokey = currentRestaurant.name + sourceMeal.name
                                saveImage(image: photo, key: photokey)
                                mealArray![selectedIndexPath.row].photoKey = photokey
                            }
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
                                newMeal.des = sourceMeal.des
                                if sourceMeal.photo != nil {
                                    //change 2
                                    newMeal.photoKey = currentRestaurant.name + newMeal.name
                                    saveImage(image: sourceMeal.photo!, key: newMeal.photoKey!)
                                    print("photo saved")
                                    
                                }
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
    
    //change 1
    //MARK: save Image and load Image
    
    func getDocumentsDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]
    }
    
    func saveImage(image: UIImage, key: String) {
        if let data = UIImagePNGRepresentation(image) {
            let fileName = getDocumentsDirectory().appendingPathComponent("\(key).png")
            print(fileName)
            try? data.write(to: fileName)
        } else {
            print("saving error")
        }
    }
    
    func getImage(key: String) -> UIImage? {
        let fileManager = FileManager.default
        let fileName = getDocumentsDirectory().appendingPathComponent("\(key).png")
        if fileManager.fileExists(atPath: fileName.path) {
            return UIImage(contentsOfFile: fileName.path)!
        }
        return nil
    }
    

    
    //MARK: Data Manipulate Method
    func loadMeal() {
        mealArray = selectRestaurant?.meals.sorted(byKeyPath: "rating", ascending: false)
        tableView.reloadData()
    }

}

extension FoodTableViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        mealArray = mealArray?.filter("name CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "rating", ascending: false)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadMeal()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}
