//
//  ProgrammaticView.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-04-01.
//

import UIKit

///ProgramicVC.swift - Progrmic View Controller
class ProgrammaticView: UIViewController, ProgramicViewInterface {
    internal let backgroundView = SUI.view(backgoundColor: .systemBackground)
    internal var frame : CGRect = CGRect()
    internal let toolBar = UIToolbar()
    internal let doneBarButton = UIBarButtonItem(title: "Done", style: .done, target: self, action: #selector(doneClick))
    internal let flexibleBarSpace = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
    
    ///Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        keyboardSetUp()
        setUpOverlay()
        configureViews()
    }
    
    ///Sets up toolbar for keyboard
    internal func keyboardSetUp(){
        toolBar.sizeToFit()
        toolBar.items = [flexibleBarSpace, doneBarButton]
    }
    
    ///When pressed done on kayboard, exit keyboard
    @objc internal func doneClick(){
        self.view.endEditing(true)
    }
    
    ///Set up overlay of view for all views in programic view controller - "Layouts"
    internal func setUpOverlay() {
        self.preferredContentSize = CGSize(width: view.frame.width, height: view.frame.height-100)
        popoverPresentationController?.permittedArrowDirections = .any
        popoverPresentationController?.delegate = self
        view.backgroundColor = .systemBackground
        view.addSubview(backgroundView)
        backgroundView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.safeAreaLayoutGuide.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.safeAreaLayoutGuide.trailingAnchor)
        frame = backgroundView.safeAreaFrame
    }
    
    ///Configuire all views in programic view controller - "Views In Layouts"
    internal func configureViews() {
        
    }

}

///Functionality required for using CLLocationManagerDelegate
extension ProgrammaticView: UIPopoverPresentationControllerDelegate {
    
}
