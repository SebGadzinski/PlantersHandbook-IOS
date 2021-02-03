//
//  ProgramicVC.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-10.
//

import UIKit

class ProgramicVC: UIViewController, ProgramicVCInterface {
    internal let bgView = SUI_View(backgoundColor: .systemBackground)
    internal var frame : CGRect = CGRect()
    internal let kb = UIToolbar()
    internal let doneButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneClick))
    internal let flexibleSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    internal var keyboardMoveUpWhenTextFieldTouched : CGFloat = 150
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil);

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil);
        
        view.backgroundColor = .systemBackground
        view.addSubview(bgView)
        
        bgView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
        
        frame = bgView.safeAreaFrame
        
        keyboardSetUp()
        generateLayout()
        configureViews()
        setActions()
    }

     @objc func keyboardWillShow(sender: NSNotification) {
          self.view.frame.origin.y = -keyboardMoveUpWhenTextFieldTouched // Move view 150 points upward
     }

     @objc func keyboardWillHide(sender: NSNotification) {
          self.view.frame.origin.y = 0 // Move view to original position
     }
    
    func keyboardSetUp(){
        kb.sizeToFit()
        kb.items = [flexibleSpace, doneButton]
    }
    
    @objc func doneClick(){
        self.view.endEditing(true)
    }
    
    func generateLayout() {
        print("Generated Layout")
    }
    
    func configureViews() {
        print("Views Configured")
    }
    
    func setActions() {
        print("Actions Set")
    }
}

extension ProgramicVC : UITextFieldDelegate{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
