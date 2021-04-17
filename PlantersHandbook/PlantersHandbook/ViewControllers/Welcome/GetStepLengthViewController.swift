//
//  GetStepLengthViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-14.
//

import UIKit
import UnderLineTextField
import JDropDownAlert

///GetStepLengthViewController.swift - Gets step distance information from user
class GetStepLengthViewController: GetStepLengthView {

    fileprivate var userData: User?
    fileprivate var rangeOfCM = [Int]()
    fileprivate var stepDistance: String? {
        get {
            return stepDistanceTextField.text
        }
    }
    
    ///Contructor that initalizes required fields
    init() {
        if let user = realmDatabase.findLocalUser(){
            userData = user
        }
        super.init(nibName: nil, bundle: nil)
        setUpRangeOfCM()
    }
    
    ///Functionality for when view will appear
    ///- Parameter animated: Boolean to decide if view will apear with anination or not
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.navigationBar.isHidden = true
        stepDistancePickerView.delegate = self
        stepDistancePickerView.dataSource = self
    }

    ///Contructor that decodes code for stroyboard
    ///- Parameter coder: Decoder for code to be translated into storyboard usage
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///Fills array of Centimeters from 10 - 200
    func setUpRangeOfCM(){
        for i in 10..<200{
            rangeOfCM.append(i)
        }
    }
    
    ///Set all actions in progrmaic view controller
    override func setActions() {
        confirmButton.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
    }

    ///Confirms that the company has been selected and sends the user to the HomeTabViewController
    @objc fileprivate func confirmAction(){
        if let stepDistance = stepDistance{
            let finalStepDistance = Int(stepDistance.deletingSuffix("cm"))!
            if stepDistance != "" && finalStepDistance > 0{
                realmDatabase.updateUser(user: userData!, _partition: nil, name: nil, company: nil, stepDistance: finalStepDistance, seasons: nil){ success, error in
                    if success{
                        print("Successfully Updated User")
                        if(userData!.company == ""){
                            self.navigationController!.pushViewController(GetCompanyViewController(), animated: true)
                            return
                        }
                        else if !userData!.name.isName(){
                            self.navigationController!.pushViewController(GetNameViewController(), animated: true)
                            return
                        }
                        else{
                            self.navigationController!.pushViewController(HomeTabViewController(), animated: true)
                        }
                    }else{
                        let alert = JDropDownAlert()
                        alert.alertWith("Could Not Update User")
                    }
                }
            }
        }else{
            let alert = JDropDownAlert()
            alert.alertWith("Please fill in fields")
        }
    }
    
    ///Action if button to close the keyboard when user presses return
    ///- Parameter sender: UITextField that was being used last
    ///- Returns: True if the text field should implement its default behavior for the return button; otherwise, false.
    override func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        stepDistanceTextField.isHidden = false
        stepDistancePickerView.isHidden = true
        self.view.endEditing(true)
        return false
    }

}

///Functionality required for using UIPickerViewDelegate, UIPickerViewDataSource, UnderLineTextFieldDelegate
extension GetStepLengthViewController: UIPickerViewDelegate, UIPickerViewDataSource, UnderLineTextFieldDelegate{
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
        return rangeOfCM.count
    }

    ///Called by the UIPickerView when it needs title for a component
    ///- Parameter pickerView: UIPickerView requesting data
    ///- Returns: Title for row
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(rangeOfCM[row])
    }

    ///Called by the UIPickerView when a row is selected
    ///- Parameter pickerView: UIPickerView requesting data
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerView.isHidden = true
        stepDistanceTextField.text = String(rangeOfCM[row]) + "cm"
    }
    
    ///Functionality for when UITextField should begin ediitng
    ///- Parameter textField: UITextField to be checked
    ///- Returns: True if editing should begin or false if it should not.
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if(textField == self.stepDistanceTextField){
            stepDistanceTextField.status = .normal
            stepDistanceTextField.text = ""
            stepDistanceTextField.placeholder = ""
            stepDistancePickerView.isHidden = false
            self.view.endEditing(true)
            return false
        }
        return true
    }

}
