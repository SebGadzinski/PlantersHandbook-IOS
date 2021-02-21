//
//  GetCompanyVC.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-10.
//

import RealmSwift
import UnderLineTextField
import JDropDownAlert

class GetCompanyViewController: GetCompanyView {
    fileprivate var userData: User?
    fileprivate let companies = ["AkeHurst & Giltrap Reforestation", "Abderson & Yates Forest Consultants", "A&M Reforestation", "Backwoods Contracting", "Big Sky Silviculture", "Bivouac West Contracting", "Blue Collar Silviculture", "Brinkman & Associates", "Broland Enterprises", "Capstone Foresty", "Celtruc Reforestation", "Coast Range Contracting", "DJ Silviculture EnterPrises", "Dorsey Contracting", "Dynamic Reforestation", "Folklore Contracting", "Haveman Brothers Forestry Services", "Heritage Reforestation", "Hybrid 17 Contracting", "Leader Silviculture", "Little Smokey Forestry" , "Moose Creek Reforestation", "Nata Reforestation", "Nechako Reforestation Services", "Next Generation Reforestation", "New Growth Forestry", "Outland Reforestation", "Prt Frontier", "Quastuco Silviculture", "Ragen Forestry", "Rhino Reforestation Services", "SBS Forestry", "Seneca Enterprises", "Spectrum Resource Group", "Summit Reforestation & Forest Management LTD", "ThunderHouse Forest Services", "TreeLine Reforestation", "USIB Silviculture", "Wilderness Reforestation", "Wildwood Reforestation", "Windfirm Resources", "Zanzibar Holdings"]
    fileprivate var company: String? {
        get {
            return companyTextField.text
        }
    }
    
    init() {
        if let user = realmDatabase.getLocalUser(){
            userData = user
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.navigationBar.isHidden = true
        companyPickerView.delegate = self
        companyPickerView.dataSource = self
    }

    override func setActions() {
        confirmButton.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
    }

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
            else{
                self.navigationController!.pushViewController(HomeTabViewController(), animated: false)
            }
        }
        else{
            let alert = JDropDownAlert()
            alert.alertWith("Please select a company")
        }
    }
}

extension GetCompanyViewController: UIPickerViewDelegate, UIPickerViewDataSource, UnderLineTextFieldDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return companies.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return companies[row]
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        companyPickerView.isHidden = true;
        companyTextField.text = companies[row];
    }
    
    func textFieldValidate(underLineTextField: UnderLineTextField) throws {
        let result : String = Validation.companyValidator(companyName: companyTextField.text!)
        if result != "Success"{
            throw UnderLineTextFieldErrors
                .error(message: result)
        }
    }
    
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        companyPickerView.isHidden = true
        self.view.endEditing(true)
        return false
    }
}
