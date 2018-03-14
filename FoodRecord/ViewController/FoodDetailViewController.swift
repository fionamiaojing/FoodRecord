//
//  FoodDetailViewController.swift
//  FoodRecord
//
//  Created by Fiona Miao on 3/12/18.
//  Copyright © 2018 Fiona Miao. All rights reserved.
//

import UIKit
import os.log
import RealmSwift
import ChameleonFramework

class FoodDetailViewController: UIViewController, UITextFieldDelegate, UITextViewDelegate, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var mealTextField: UITextField!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var mealDescriptionText: UITextView!
    @IBOutlet weak var ratingControl: RatingControl!
    @IBOutlet weak var saveButton: UIBarButtonItem!
    
    var meal: MealDetail?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        mealTextField.delegate = self
        mealDescriptionText.delegate = self
        
        // Set up views if editing an existing Meal.
        if let currentMeal = meal {
            navigationItem.title = currentMeal.name
            mealTextField.text = currentMeal.name
            //photoImageView.image = meal.photo
            ratingControl.rating = currentMeal.rating
        }
        
        updateSaveButtonStates()

    }

    //MARK: - text field Delegate
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    func textFieldDidBeginEditing(_ textField: UITextField) {
        saveButton.isEnabled = false
    }
    
    func textFieldDidEndEditing(_ textField: UITextField) {
        updateSaveButtonStates()
        navigationItem.title = mealTextField.text
    }
    
    //MARK: - text View Delegate
    
    func textViewDidEndEditing(_ textView: UITextView) {
        mealDescriptionText.resignFirstResponder()
    }

    //MARK: - Navigation

    @IBAction func cancel(_ sender: UIBarButtonItem) {
        // Depending on style of presentation (modal or push presentation), this view controller needs to be dismissed in two different ways.
        let isPresentingInAddMealMode = presentingViewController is UINavigationController
        if isPresentingInAddMealMode {
            dismiss(animated: true, completion: nil)
        } else if let owningNavigationController = navigationController {
            owningNavigationController.popViewController(animated: true)
        } else {
            fatalError("The MealViewController is not inside a navigation controller.")
        }
        
    }
    
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // Configure the destination view controller only when the save button is pressed.
        guard let button = sender as? UIBarButtonItem, button === saveButton else {
            os_log("The save button was not pressed, cancelling", log: OSLog.default, type: .debug)
            return
        }
        
        let name = mealTextField.text ?? ""
        let rating = ratingControl.rating
        let photo = photoImageView.image
        
        meal = MealDetail(name: name, photo: photo, rating: rating)
    }
    
    
    //MARK: - Image Actions
    @IBAction func selectImageFromPhotoLibrary(_ sender: UITapGestureRecognizer) {
        mealTextField.resignFirstResponder()
        mealDescriptionText.resignFirstResponder()
        
        let imagePickerController = UIImagePickerController()
        //define image source
        imagePickerController.sourceType = .photoLibrary
        
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        guard let selectedImage = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            fatalError("Expected a dictionary containing an image, but was provided the following: \(info)")
        }
        
        photoImageView.image = selectedImage
        dismiss(animated: true, completion: nil)
        
    }
    
    //MARK: - Private Methods
    private func updateSaveButtonStates() {
        // Disable the Save button if the text field is empty.
        let text = mealTextField.text
        saveButton.isEnabled = !(text?.isEmpty)!
    }
    
}
