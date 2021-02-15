//
//  OneTextFieldModalViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-15.
//

import UIKit
import RealmSwift

class OneTextFieldModalViewController: OneTextFieldModalView {
    weak var delegate : OneTextFieldModalDelegate?
    
    required init(title: String, textForTextField: String) {
        super.init(nibName: nil, bundle: nil)
        titleLabel.text = title
        textField.text = textForTextField
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    internal override func setActions(){
        confirmButton.addTarget(self, action: #selector(confirmButtonAction), for: .touchUpInside)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textField.delegate = self
    }

    @objc fileprivate func confirmButtonAction(_ sender: Any) {
        if(textField.text != ""){
            if let delegate = delegate{
                delegate.completionHandler(returningText: textField.text!)
            }
            self.dismiss(animated: true, completion: nil)
            // Dismiss current Viewcontroller and back to Original
            self.navigationController?.popViewController(animated: true)
        }
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }

}

protocol OneTextFieldModalDelegate:NSObjectProtocol {
    func completionHandler(returningText : String)
}
