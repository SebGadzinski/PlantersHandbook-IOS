//
//  GetStepLengthViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-14.
//

import UIKit
import UnderLineTextField
import JDropDownAlert

class GetStepLengthViewController: GetStepLengthView {

    fileprivate var userData: User?
    fileprivate var rangeOfCM = [Int]()
    fileprivate var stepDistance: String? {
        get {
            return stepDistanceTextField.text
        }
    }
    
    init() {
        if let user = realmDatabase.getLocalUser(){
            userData = user
        }
        super.init(nibName: nil, bundle: nil)
        setUpRangeOfCM()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.navigationBar.isHidden = true
        stepDistancePickerView.delegate = self
        stepDistancePickerView.dataSource = self
    }

    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setUpRangeOfCM(){
        for i in 10..<200{
            rangeOfCM.append(i)
        }
    }
    
    override func setActions() {
        confirmButton.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
    }

    @objc fileprivate func confirmAction(){
        if let stepDistance = stepDistance{
            let finalStepDistance = Int(stepDistance.deletingSuffix("cm"))!
            if stepDistance != "" && finalStepDistance > 0{
                realmDatabase.updateUser(user: userData!, _partition: nil, name: nil, company: nil, stepDistance: finalStepDistance, seasons: nil){ success, error in
                    if success{
                        print("Successfully Updated User")
                        self.navigationController!.pushViewController(HomeTabViewController(), animated: true)
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

}

extension GetStepLengthViewController: UIPickerViewDelegate, UIPickerViewDataSource, UnderLineTextFieldDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }

    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int{
        return rangeOfCM.count
    }

    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return String(rangeOfCM[row])
    }

    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerView.isHidden = true
        stepDistanceTextField.text = String(rangeOfCM[row]) + "cm"
    }
    
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        stepDistanceTextField.isHidden = false
        stepDistancePickerView.isHidden = true
        self.view.endEditing(true)
        return false
    }
}
