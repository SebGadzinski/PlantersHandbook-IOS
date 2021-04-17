//
//  GetNameViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-04-09.
//

import UIKit
import JDropDownAlert

class GetNameViewController: GetNameView {

    fileprivate var userData: User?
    fileprivate var rangeOfCM = [Int]()
    fileprivate var name: String? {
        get {
            return nameTextField.text
        }
    }
    
    ///Contructor that initalizes required fields
    init() {
        if let user = realmDatabase.findLocalUser(){
            userData = user
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    ///Functionality for when view will appear
    ///- Parameter animated: Boolean to decide if view will apear with anination or not
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.interactivePopGestureRecognizer?.isEnabled = false
        self.navigationController?.navigationBar.isHidden = true
    }

    ///Contructor that decodes code for stroyboard
    ///- Parameter coder: Decoder for code to be translated into storyboard usage
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    ///Set all actions in progrmaic view controller
    override func setActions() {
        confirmButton.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
    }

    ///Confirms that the company has been selected and sends the user to the HomeTabViewController
    @objc fileprivate func confirmAction(){
        if let name = name{
            if name != ""{
                realmDatabase.updateUser(user: userData!, _partition: nil, name: name, company: nil, stepDistance: nil, seasons: nil){ success, error in
                    if success{
                        print("Successfully Updated User")
                        if(userData!.company == ""){
                            self.navigationController!.pushViewController(GetCompanyViewController(), animated: true)
                            return
                        }
                        else if userData!.stepDistance == 0{
                            self.navigationController!.pushViewController(GetStepLengthViewController(), animated: true)
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
    
}
