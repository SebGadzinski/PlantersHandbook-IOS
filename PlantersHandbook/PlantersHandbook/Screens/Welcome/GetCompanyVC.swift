//
//  GetCompanyVC.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-10.
//

import UIKit
import RealmSwift
import UnderLineTextField
import JDropDownAlert

class GetCompanyVC: ProgramicVC {
    var userData: User?
    var notificationToken: NotificationToken?

    let companies = ["AkeHurst & Giltrap Reforestation", "Abderson & Yates Forest Consultants", "A&M Reforestation", "Backwoods Contracting", "Big Sky Silviculture", "Bivouac West Contracting", "Blue Collar Silviculture", "Brinkman & Associates", "Broland Enterprises", "Capstone Foresty", "Celtruc Reforestation", "Coast Range Contracting", "DJ Silviculture EnterPrises", "Dorsey Contracting", "Dynamic Reforestation", "Folklore Contracting", "Haveman Brothers Forestry Services", "Heritage Reforestation", "Hybrid 17 Contracting", "Leader Silviculture", "Little Smokey Forestry" , "Moose Creek Reforestation", "Nata Reforestation", "Nechako Reforestation Services", "Next Generation Reforestation", "New Growth Forestry", "Outland Reforestation", "Prt Frontier", "Quastuco Silviculture", "Ragen Forestry", "Rhino Reforestation Services", "SBS Forestry", "Seneca Enterprises", "Spectrum Resource Group", "Summit Reforestation & Forest Management LTD", "ThunderHouse Forest Services", "TreeLine Reforestation", "USIB Silviculture", "Wilderness Reforestation", "Wildwood Reforestation", "Windfirm Resources", "Zanzibar Holdings"]
    
    fileprivate var titleLayout : UIView!
    fileprivate var infoLayout : UIView!
    fileprivate var companyLayout : UIView!
    fileprivate var companyPickerView = UIPickerView()

    fileprivate let icon : UIImageView = UIImageView(image: UIImage(named: "icons8-oak-tree-64.png"))
    fileprivate let companyTitle = label_normal(title: "Company", fontSize: FontSize.extraLarge)
    fileprivate let companyInfoMessage = textView_multiLine(text: "Please select the company you work for", fontSize: FontSize.meduim)
    fileprivate let companyTextInput = textField_form(placeholder: "Click to choose", textType: .name)
    fileprivate let confirmButton = ph_button(title: "Confirm", fontSize: FontSize.large)
    
    init() {
        if let user = realmDatabase.getLocalUser(){
            userData = user
        }
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        notificationToken?.invalidate()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
    }
    
    var company: String? {
        get {
            return companyTextInput.text
        }
    }
    
    override func generateLayout() {
        titleLayout = generalLayout(backgoundColor: .systemBackground)
        infoLayout = generalLayout(backgoundColor: .systemBackground)
        companyLayout = generalLayout(backgoundColor: .systemBackground)
    }
    
    override func configureViews() {
        setUpOverlay()
        setUpTitleLayout()
        setUpInfoLayout()
    }
    
    override func setActions() {
        confirmButton.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
    }
    
    func setUpOverlay() {
        [titleLayout, infoLayout].forEach{bgView.addSubview($0)}
        
        print(frame.size)
        
        titleLayout.anchor(top: bgView.topAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor, size: .init(width: frame.width, height: frame.height*0.25))
        infoLayout.anchor(top: titleLayout.bottomAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor,size: .init(width: frame.width, height: frame.height*0.7))
    }
    
    func setUpTitleLayout() {
        let titleLayoutFrame = titleLayout.safeAreaFrame
        
        [icon, companyTitle, companyInfoMessage].forEach{titleLayout.addSubview($0)}
        icon.anchor(top: titleLayout.topAnchor, leading: nil, bottom: nil, trailing: nil, size: .init(width: titleLayoutFrame.height*0.4, height: titleLayoutFrame.height*0.4))
        icon.anchorCenterX(to: titleLayout)
        
        companyTitle.anchor(top: icon.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 5, left: 0, bottom: 0, right: 0),size: .init(width: titleLayoutFrame.width, height: titleLayoutFrame.height*0.4))
        companyTitle.anchorCenterX(to: titleLayout)
        
        companyInfoMessage.anchor(top: companyTitle.bottomAnchor, leading: titleLayout.leadingAnchor, bottom: titleLayout.bottomAnchor, trailing: titleLayout.trailingAnchor, padding: .init(top: 0, left: 5, bottom: 0, right: 5), size: .init(width: 0, height: titleLayoutFrame.height*0.2))
        companyInfoMessage.anchorCenterX(to: titleLayout)
        companyInfoMessage.textAlignment = .center
        
    }
    
    func setUpInfoLayout() {
        let infoLayoutFrame = infoLayout.safeAreaFrame
        let textFieldBoundarySpace = CGFloat(20)
        
        [companyLayout, confirmButton].forEach{infoLayout.addSubview($0)}
        
        companyLayout.anchor(top: infoLayout.topAnchor, leading: infoLayout.leadingAnchor, bottom: confirmButton.topAnchor, trailing: infoLayout.trailingAnchor)
        
        [companyTextInput, companyPickerView].forEach{companyLayout.addSubview($0)}
        
        companyTextInput.anchor(top: nil, leading: infoLayout.leadingAnchor, bottom: nil, trailing: infoLayout.trailingAnchor, padding: .init(top: 0, left: textFieldBoundarySpace, bottom: 0, right: textFieldBoundarySpace))
        companyTextInput.delegate = self
        companyTextInput.anchorCenterY(to: companyLayout)
        
        companyPickerView.delegate = self
        companyPickerView.dataSource = self
        companyPickerView.anchor(top: companyLayout.topAnchor, leading: infoLayout.leadingAnchor, bottom: companyLayout.bottomAnchor, trailing: infoLayout.trailingAnchor, padding: .init(top: 10, left: 0, bottom: 10, right: 0))
        companyPickerView.isHidden = true
        
        confirmButton.anchor(top: nil, leading: infoLayout.leadingAnchor, bottom: infoLayout.bottomAnchor, trailing: infoLayout.trailingAnchor, padding: .init(top: 0, left: infoLayoutFrame.width*0.3, bottom: infoLayoutFrame.height*0.2, right: infoLayoutFrame.width*0.3),size: .init(width: 0, height: infoLayoutFrame.height*0.1))
    }

    @objc func confirmAction(){
        if companyTextInput.text != "" && "Success" == companyValidator(companyName: companyTextInput.text!){
            realmDatabase.updateUser(user: userData!, _partition: nil, name: nil, company: company, seasons: nil)
            self.navigationController!.pushViewController(HomeTBC(), animated: true)
        }
        else{
            let alert = JDropDownAlert()
            alert.alertWith("Please select a company")
        }
    }

}

extension GetCompanyVC: UIPickerViewDelegate, UIPickerViewDataSource, UnderLineTextFieldDelegate{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return companies.count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return companies[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        companyPickerView.isHidden = true;
        companyTextInput.text = companies[row];
    }
    
    func textFieldValidate(underLineTextField: UnderLineTextField) throws {
        let result : String = companyValidator(companyName: companyTextInput.text!)
        if result != "Success"{
            throw UnderLineTextFieldErrors
                .error(message: result)
        }
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        if(textField == self.companyTextInput){
            companyTextInput.status = .normal
            companyTextInput.text = ""
            companyTextInput.placeholder = ""
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
