//
//  ProgramicVC.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-10.
//

import UIKit

class ProgramicVC: UIViewController, ProgramicVCInterface {
    internal let backgroundView = SUI_View(backgoundColor: .systemBackground)
    internal var frame : CGRect = CGRect()
    internal let toolBar = UIToolbar()
    internal let doneBarButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneClick))
    internal let flexibleBarSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    internal var keyboardMoveUpWhenTextFieldTouched : CGFloat = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil);

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil);
        
        view.backgroundColor = .systemBackground
        view.addSubview(backgroundView)
        
        backgroundView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
        
        frame = backgroundView.safeAreaFrame
        
        keyboardSetUp()
        setUpOverlay()
        configureViews()
        setActions()
    }

     @objc internal func keyboardWillShow(sender: NSNotification) {
          self.view.frame.origin.y = -keyboardMoveUpWhenTextFieldTouched // Move view 150 points upward
     }

     @objc internal func keyboardWillHide(sender: NSNotification) {
          self.view.frame.origin.y = 0 // Move view to original position
     }
    
    internal func keyboardSetUp(){
        toolBar.sizeToFit()
        toolBar.items = [flexibleBarSpace, doneBarButton]
    }
    
    @objc internal func doneClick(){
        self.view.endEditing(true)
    }
    
    internal func setUpOverlay() {
        print("Overlay")
    }
    
    internal func configureViews() {
        print("Views Configured")
    }
    
    internal func setActions() {
        print("Actions Set")
    }
}

extension ProgramicVC : UITextFieldDelegate{
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
