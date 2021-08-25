//
//  AddTreeTypeViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-06-21.
//

import UIKit
import JDropDownAlert

class AddTreeTypeModalViewController: AddTreeTypeModalView {
    weak var delegate : AddTreeTypeModalDelegate?
    let columnOnTally : Int
    var treeTypes = ["PL", "SX", "Other"]
    var requestKeyLocation : CGFloat = 0
    
    ///Contructor that initalizes required fields
    ///- Parameter title:Title of current view controller in navigation controller
    ///- Parameter textForTextField: Text to be written in the texxtField
    required init(curTreeType: String, columnOnTally: Int) {
        self.columnOnTally = columnOnTally
        super.init(nibName: nil, bundle: nil)
        // curTreeType is split into 2 strings from the dash '-' (PL - 123)
        if curTreeType != ""{
            var hasDashInTreeType = false
            for char in curTreeType{
                if char == "-"{
                    hasDashInTreeType = true
                }
            }
            if hasDashInTreeType{
                let treeTypes = curTreeType.split(separator: "-")
                typeTextField.text = String(treeTypes[0])
                requestTextField.text = String(treeTypes[1])
            }else{
                typeTextField.text = curTreeType
            }
        }
        otherTypeTextField.autocapitalizationType = .allCharacters
        treeTypes = getTreeTypes()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///Set all actions in progrmaic view controller
    internal override func setActions(){
        confirmButton.addTarget(self, action: #selector(confirmButtonAction), for: .touchUpInside)
        requestTextField.addTarget(self, action: #selector(requestKeyBeginAction), for: .editingDidBegin)
        requestTextField.addTarget(self, action: #selector(requestKeyFinishAction), for: .editingDidEnd)
        otherTypeTextField.addTarget(self, action: #selector(otherTypeFinishAction), for: .editingDidEnd)
    }
    
    @objc func requestKeyBeginAction(){
        requestKeyLocation = self.requestTextField.frame.origin.y
        typeTextField.isHidden = true
        otherTypeTextField.isHidden = true
        self.requestTextField.frame.origin.y = 0
    }
    
    @objc func requestKeyFinishAction(){
        typeTextField.isHidden = false
        if typeTextField.text == "Other"{
            otherTypeTextField.isHidden = false
        }
        requestTextField.text = requestTextField.text!.uppercased()
        self.requestTextField.frame.origin.y = requestKeyLocation
    }
    
    @objc func otherTypeFinishAction(){
        otherTypeTextField.text = otherTypeTextField.text!.uppercased()
    }
    
    ///Functionality for when view will appear
    ///- Parameter animated: Boolean to decide if view will apear with anination or not
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        typePickerView.delegate = self
        typePickerView.dataSource = self
        typeTextField.delegate = self
        typeTextField.autocapitalizationType = .allCharacters
    }

    ///Grabs name from textField and sends it to HandbookViewController, and pops this modal from navigation controller stack
    ///- Parameter sender: Confirm button
    @objc fileprivate func confirmButtonAction(_ sender: Any) {
        
        var finalTreeType = typeTextField.text! + "-" + requestTextField.text!
        
        if(typeTextField.text != "" && requestTextField.text != ""){
            if typeTextField.text == "Other" {
                if otherTypeTextField.text != ""{
                    if(treeTypes.contains(otherTypeTextField.text!)){
                        let alert = JDropDownAlert()
                        alert.alertWith(otherTypeTextField.text! + "is already inside the list")
                    }else{
                        finalTreeType = otherTypeTextField.text! + "-" + requestTextField.text!
                        if let delegate = delegate{
                            treeTypes.insert(otherTypeTextField.text!, at: 0)
                            saveTreeTypes()
                            delegate.addTreeType(treeType: finalTreeType, columnOnTally: columnOnTally)
                        }
                        self.dismiss(animated: true, completion: nil)
                        // Dismiss current Viewcontroller and back to Original
                        self.navigationController?.popViewController(animated: true)
                    }
                }
            }else{
                if let delegate = delegate{
                    saveTreeTypes()
                    delegate.addTreeType(treeType: finalTreeType, columnOnTally: columnOnTally)
                }
                self.dismiss(animated: true, completion: nil)
                // Dismiss current Viewcontroller and back to Original
                self.navigationController?.popViewController(animated: true)
            }
        }
    }

    ///Gets the order of cards that was saved in user personal storage
    fileprivate func getTreeTypes() -> [String]{
        if let tempItems = userDefaults.object(forKey: "treeTypes"){
            let items = tempItems as! NSArray
            return items as! [String]
        }
        return ["PL", "SX", "Other"]
    }
    
    ///Save all the cards in the UICollectionView
    fileprivate func saveTreeTypes(){
        userDefaults.set(treeTypes, forKey:"treeTypes")
    }
    
    ///Action if button to close the keyboard when user presses return
    ///- Parameter sender: TheUITextField whose return button was pressed.
    ///- Returns: True if the text field should implement its default behavior for the return button; otherwise, false.
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        typePickerView.isHidden = true
        self.view.endEditing(true)
        return false
    }

}

///Functionality required for using UIPickerViewDelegate, UIPickerViewDataSource, UnderLineTextFieldDelegate
extension AddTreeTypeModalViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    ///Called by the UIPickerView when it needs the number of compenets
    ///- Parameter pickerView: UIPickerView requesting data
    ///- Returns: Number of compenents required
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    ///Called by the UIPickerView when it needs number of rows in each component
    ///- Parameter pickerView: UIPickerView requesting data
    ///- Returns: Number of rows in components required
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return treeTypes.count
    }

    ///Called by the UIPickerView when it needs title for a component
    ///- Parameter pickerView: UIPickerView requesting data
    ///- Returns: Title for row
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return treeTypes[row]
    }

    ///Called by the UIPickerView when a row is selected
    ///- Parameter pickerView: UIPickerView requesting data
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        typePickerView.isHidden = true;
        typeTextField.placeholder = "Type"
        typeTextField.text = treeTypes[row]
        if treeTypes[row] == "Other"{
            otherTypeTextField.isHidden = false
        }else{
            otherTypeTextField.isHidden = true
            otherTypeTextField.text = ""
        }
    }
    
    ///Functionality for when UITextField should begin ediitng
    ///- Parameter textField: UITextField to be checked
    ///- Returns: True if editing should begin or false if it should not.
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if(textField == self.typeTextField){
            typeTextField.status = .normal
            typeTextField.text = ""
            typeTextField.placeholder = ""
            typeTextField.isHidden = false
            typePickerView.isHidden = false
            self.view.endEditing(true)
            return false
        }
        return true
    }
}


///Protocol used for a view controller that uses AddSeasonModalVIewController
protocol AddTreeTypeModalDelegate:NSObjectProtocol {
    ///Tells the delegate to create a season
    ///- Parameter season: Season to be created
    func addTreeType(treeType : String, columnOnTally: Int)
}



