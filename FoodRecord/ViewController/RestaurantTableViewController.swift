//
//  RestaurantTableViewController.swift
//  FoodRecord
//
//  Created by Fiona Miao on 3/12/18.
//  Copyright © 2018 Fiona Miao. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class RestaurantTableViewController: SwipeTableViewController {
    
    let realm = try! Realm()
    
    var restaurantArray: Results<Restaurant>?
    
    var selectedRegion: Region? {
        didSet {
            loadRestaurant()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()

    }

    // MARK: - TableView Data Source Method

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return restaurantArray?.count ?? 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if let restaurant = restaurantArray?[indexPath.row] {
            cell.textLabel?.text = restaurant.name
            //
        }
        return cell
    }
    
    override func updateModel(at indexPath: IndexPath) {
        
        if let restaurantTobeDeleted = restaurantArray?[indexPath.row] {
            do {
                try self.realm.write {
                    self.realm.delete(restaurantTobeDeleted)
                }
            } catch {
                print("Error deleting restaurant \(error)")
            }
        }
    }
    
    //MARK: - TableView Data Delegate Method

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "RestaurantToFood", sender: self)
    }

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! FoodTableViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectRestaurant = restaurantArray?[indexPath.row]
            
        }
    }
    
    //MARK: Data Manipulate Method
    
    func loadRestaurant() {
        
        restaurantArray = selectedRegion?.restaurants.sorted(byKeyPath: "name", ascending: true)
        
    }
    
    //MARK: Add Button Pressed
    
    @IBAction func AddButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add new Restaurant", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Done", style: .default) { (alert) in
            
            if let currentRegion = self.selectedRegion {
                do {
                    try self.realm.write {
                        let newRestaurant = Restaurant()
                        
                        if textField.text?.isEmpty != true {
                            newRestaurant.name = textField.text!
                            currentRegion.restaurants.append(newRestaurant)
                            
                            //
                        } else {
                            print("Invalid Input")
                        }
                    }
                } catch {
                    print("Error saving data \(error)")
                }
            }
            
            self.tableView.reloadData()
        }
        
        alert.addTextField { (alertTextField) in
            textField.placeholder = "Please input"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
    }
    
}


