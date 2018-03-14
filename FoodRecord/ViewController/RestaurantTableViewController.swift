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
    
    @IBOutlet weak var searchBar: UISearchBar!
    
    var restaurantArray: Results<Restaurant>?
    
    var selectedRegion: Region? {
        didSet {
            loadRestaurant()
        }
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadRestaurant()
    }
    

    // MARK: - TableView Data Source Method

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return restaurantArray?.count ?? 1
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = super.tableView(tableView, cellForRowAt: indexPath)

        if let restaurant = restaurantArray?[indexPath.row] {
            let mealCount = restaurant.meals.count
            print(mealCount)
            cell.textLabel?.text = restaurant.name + " (\(mealCount))"
            
            if let color = UIColor.flatSand.darken(byPercentage: CGFloat(indexPath.row) / CGFloat((restaurantArray?.count)!)) {
                cell.backgroundColor = color
                cell.textLabel?.textColor = ContrastColorOf(color, returnFlat: true)
            }
            
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
        tableView.reloadData()
        
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

extension RestaurantTableViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        restaurantArray = restaurantArray?.filter("name CONTAINS[cd] %@", searchBar.text!).sorted(byKeyPath: "name", ascending: true)
        tableView.reloadData()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text?.count == 0 {
            loadRestaurant()
            
            DispatchQueue.main.async {
                searchBar.resignFirstResponder()
            }
        }
    }
}


