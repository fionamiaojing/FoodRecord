//
//  RegionTableViewController.swift
//  FoodRecord
//
//  Created by Fiona Miao on 3/12/18.
//  Copyright © 2018 Fiona Miao. All rights reserved.
//

import UIKit
import RealmSwift
import ChameleonFramework

class RegionTableViewController: SwipeTableViewController {
    
    var regionArray: Results<Region>?
    
    let realm = try! Realm()
    
    var colorArray : [UIColor] = [UIColor.flatWatermelon, UIColor.flatPowderBlue, UIColor.flatYellow]

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.separatorStyle = .none
        loadRegion()
    }
    
    //load view when region View appears
    override func viewWillAppear(_ animated: Bool) {
        loadRegion()
    }
    
    
    //MARK: - Tableview Data Source Method

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return regionArray?.count ?? 1
    }
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = super.tableView(tableView, cellForRowAt: indexPath)
        
        if let region = regionArray?[indexPath.row] {
            let restaurantCount = region.restaurants.count
            cell.textLabel?.text = region.title + " (\(restaurantCount))"
            
            let regionColor = colorArray[indexPath.row % colorArray.count]
            cell.backgroundColor = regionColor
            cell.textLabel?.textColor = ContrastColorOf(regionColor, returnFlat: true)
        }
        return cell
    }

    //MARK: - Tableview Data Delegate Method
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        performSegue(withIdentifier: "RegionToRestaurant", sender: self)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        
        let destinationVC = segue.destination as! RestaurantTableViewController
        
        if let indexPath = tableView.indexPathForSelectedRow {
            destinationVC.selectedRegion = regionArray?[indexPath.row]
        }
        
    }
    
    override func updateModel(at indexPath: IndexPath) {
        if let regionToBeDeleted = regionArray?[indexPath.row] {
            do {
                try realm.write {
                    realm.delete(regionToBeDeleted)
                }
            } catch {
                print("Error deleting region \(error)")
            }
        }
    }
    
    //MARK: Data Manipulate Method
    
    func save(region: Region) {
        do {
            try realm.write {
                realm.add(region)
            }
        } catch {
            print("Error in saving context \(error)")
        }
        
        tableView.reloadData()
    }
    
    func loadRegion() {
        regionArray = realm.objects(Region.self)
        tableView.reloadData()
    }
    
    //MARK: AddButton Function
    
    @IBAction func AddButtonPressed(_ sender: UIBarButtonItem) {
        
        var textField = UITextField()
        
        let alert = UIAlertController(title: "Add New Region", message: "", preferredStyle: .alert)
        
        let action = UIAlertAction(title: "Done", style: .default) { (alert) in
            
            let newRegion = Region()
            if textField.text?.isEmpty != true {
                newRegion.title = textField.text!
                
            } else {
                print("Invalid Input")
            }
            self.save(region: newRegion)
            
        }
        
        alert.addTextField { (alertTextField) in
            textField.placeholder = "please input"
            textField = alertTextField
        }
        
        alert.addAction(action)
        
        present(alert, animated: true, completion: nil)
        
    }
    
}







