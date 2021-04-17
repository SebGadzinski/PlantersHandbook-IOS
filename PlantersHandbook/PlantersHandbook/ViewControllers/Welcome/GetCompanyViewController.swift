//
//  GetCompanyVC.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-10.
//

import RealmSwift
import UnderLineTextField
import JDropDownAlert

///GetCompanyViewController.swift - Gets company name where user works
class GetCompanyViewController: GetCompanyView {
    fileprivate var userData: User?
    fileprivate let companies = ["AkeHurst & Giltrap Reforestation", "Abderson & Yates Forest Consultants", "A&M Reforestation", "Backwoods Contracting", "Big Sky Silviculture", "Bivouac West Contracting", "Blue Collar Silviculture", "Brinkman & Associates", "Broland Enterprises", "Capstone Foresty", "Celtruc Reforestation", "Coast Range Contracting", "DJ Silviculture EnterPrises", "Dorsey Contracting", "Dynamic Reforestation", "Folklore Contracting", "Haveman Brothers Forestry Services", "Heritage Reforestation", "Hybrid 17 Contracting", "Leader Silviculture", "Little Smokey Forestry" , "Moose Creek Reforestation", "Nata Reforestation", "Nechako Reforestation Services", "Next Generation Reforestation", "New Growth Forestry", "Outland Reforestation", "Prt Frontier", "Quastuco Silviculture", "Ragen Forestry", "Rhino Reforestation Services", "SBS Forestry", "Seneca Enterprises", "Spectrum Resource Group", "Summit Reforestation & Forest Management LTD", "ThunderHouse Forest Services", "TreeLine Reforestation", "USIB Silviculture", "Wilderness Reforestation", "Wildwood Reforestation", "Windfirm Resources", "Zanzibar Holdings"]
    fileprivate var company: String? {
        get {
            return companyTextField.text
        }
    }
    ///Contructor that initalizes required fields
    init() {
        if let user = realmDatabase.findLocalUser(){
            userData = user
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    ///Contructor that decodes code for stroyboard
    ///- Parameter coder: Decoder for code to be translated into storyboard usage
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///Functionality for when view will appear
    ///- Parameter animated: Boolean to decide if view will apear with anination or not
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.navigationBar.isHidden = true
        companyPickerView.delegate = self
        companyPickerView.dataSource = self
    }

    ///Set all actions in progrmaic view controller
    override func setActions() {
        confirmButton.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
    }
    
    ///Confirms that the company has been selected and sends the user to the next view controller
    @objc fileprivate func confirmAction(){
        if companyTextField.text != "" && "Success" == Validation.companyValidator(companyName: companyTextField.text!){
            realmDatabase.updateUser(user: userData!, _partition: nil, name: nil, company: company, stepDistance: nil, seasons: nil){ success, error in
                if success{
                    print("User company updated")
                }
            }
            if userData!.stepDistance == 0{
                self.navigationController!.pushViewController(GetStepLengthViewController(), animated: true)
            }
            else if !userData!.name.isName(){
                self.navigationController!.pushViewController(GetNameViewController(), animated: true)
                return
            }
            else{
                self.navigationController!.pushViewController(HomeTabViewController(), animated: true)
            }
        }
        else{
            let alert = JDropDownAlert()
            alert.alertWith("Please select a company")
        }
    }
    
    ///Action if button to close the keyboard when user presses return
    ///- Parameter sender: TheUITextField whose return button was pressed.
    ///- Returns: True if the text field should implement its default behavior for the return button; otherwise, false.
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        companyPickerView.isHidden = true
        self.view.endEditing(true)
        return false
    }
    
}

///Functionality required for using UIPickerViewDelegate, UIPickerViewDataSource, UnderLineTextFieldDelegate
extension GetCompanyViewController: UIPickerViewDelegate, UIPickerViewDataSource, UnderLineTextFieldDelegate{
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
        return companies.count
    }

    ///Called by the UIPickerView when it needs title for a component
    ///- Parameter pickerView: UIPickerView requesting data
    ///- Returns: Title for row
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return companies[row]
    }

    ///Called by the UIPickerView when a row is selected
    ///- Parameter pickerView: UIPickerView requesting data
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        companyPickerView.isHidden = true;
        companyTextField.text = companies[row];
    }
    
    ///Validates input given into UnderLineTextField
    ///- Parameter underLineTextField: UnderLineTextField to be validated
    func textFieldValidate(underLineTextField: UnderLineTextField) throws {
        let result : String = Validation.companyValidator(companyName: companyTextField.text!)
        if result != "Success"{
            throw UnderLineTextFieldErrors
                .error(message: result)
        }
    }
    
    ///Functionality for when UITextField should begin ediitng
    ///- Parameter textField: UITextField to be checked
    ///- Returns: True if editing should begin or false if it should not.
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if(textField == self.companyTextField){
            companyTextField.status = .normal
            companyTextField.text = ""
            companyTextField.placeholder = ""
            companyPickerView.isHidden = false
            self.view.endEditing(true)
            return false
        }
        return true
    }
}
