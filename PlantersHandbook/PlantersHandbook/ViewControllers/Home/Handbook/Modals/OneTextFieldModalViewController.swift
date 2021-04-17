//
//  OneTextFieldModalViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-15.
//

import UIKit
import RealmSwift

///OneTextFieldModalViewController.swift - Displays text given in a text field with a title
class OneTextFieldModalViewController: OneTextFieldModalView {
    weak var delegate : OneTextFieldModalDelegate?
    
    ///Contructor that initalizes required fields
    ///- Parameter title:Title of current view controller in navigation controller
    ///- Parameter textForTextField: Text to be written in the texxtField
    required init(title: String, textForTextField: String) {
        super.init(nibName: nil, bundle: nil)
        titleLabel.text = title
        textField.text = textForTextField
        textFieldShouldReturn = true
    }
    
    ///Contructor that decodes code for stroyboard
    ///- Parameter coder: Decoder for code to be translated into storyboard usage
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///Set all actions in progrmaic view controller
    internal override func setActions(){
        confirmButton.addTarget(self, action: #selector(confirmButtonAction), for: .touchUpInside)
    }
    
    ///Functionality for when view will appear
    ///- Parameter animated: Boolean to decide if view will apear with anination or not
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.textField.delegate = self
    }

    ///Grabs name from textField and sends it to HandbookViewController, and pops this modal from navigation controller stack
    ///- Parameter sender: Confirm button
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

}

///Protocol used for a view controller that uses OneTextFieldModalViewController
protocol OneTextFieldModalDelegate:NSObjectProtocol {
    ///Tells the delegate to do something with returning text
    ///- Parameter returningText: Whatever text was written into the UITextField
    func completionHandler(returningText : String)
}
