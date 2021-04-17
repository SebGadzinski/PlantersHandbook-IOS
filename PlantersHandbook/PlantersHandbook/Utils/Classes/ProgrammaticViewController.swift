//
//  ProgramicVC.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-10.
//

import UIKit

///ProgramicVC.swift - Progrmic View Controller
class ProgrammaticViewController: ProgrammaticView, ProgrammaticViewControllerInterface {
    internal var keyboardMoveWhenTextFieldTouched : CGFloat = 0
    internal let userDefaults = UserDefaults.standard
    internal var firstTimerKey = "key"
    internal var textFieldShouldReturn = false
    
    ///Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        setActions()
    }
    
    ///Set all actions in progrmaic view controller
    internal func setActions() {
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(sender:)), name: UIResponder.keyboardWillShowNotification, object: nil);
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(sender:)), name: UIResponder.keyboardWillHideNotification, object: nil);
    }
    
     ///Raise the view by the number in  for the keyboard not to block the text field
     ///- Parameter sender: Notification that came in
     @objc internal func keyboardWillShow(sender: NSNotification) {
        self.view.frame.origin.y = -keyboardMoveWhenTextFieldTouched
     }
    
    ///Set view back to normal y location
    ///- Parameter sender: Notification that came in
    @objc internal func keyboardWillHide(sender: NSNotification) {
        self.view.frame.origin.y = 0
    }
    
    ///Save a key used to know if it is the first time a user has opened this application since login
    ///- Parameter finishedFirstTime: value to save in as first timer key
    internal func saveFirstTimer(finishedFirstTime: Bool){
        let input = (finishedFirstTime ? "1" : "0")
        userDefaults.set(input, forKey:firstTimerKey)
    }
    
    ///Checks to see if this is users first time on this programic view
    internal func isFirstTimer() -> Bool{
        if let bool = userDefaults.object(forKey: firstTimerKey){
            let isTrue = bool as! NSString
            return (isTrue != "1")
        }
        return true
    }
    
    ///Action if button to close the keyboard when user presses return
    ///- Parameter sender: UITextField that was being used last
    ///- Returns: True if the text field should implement its default behavior for the return button; otherwise, false.
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(textFieldShouldReturn)
        return false
    }
    
    func setUpUIPopUpController(barButtonItem: UIBarButtonItem?, sourceView: UIView?){
        popoverPresentationController?.barButtonItem = barButtonItem
        popoverPresentationController?.sourceView = sourceView
    }
    
}

extension ProgrammaticViewController : UITextFieldDelegate{
    ///Tells this object that one or more new touches occurred in a view or window.
    ///- Parameter touches: A set of UITouch instances that represent the touches for the starting phase of the event, which is represented by event. For touches in a view, this set contains only one touch by default. To receive multiple touches, you must set the view's isMultipleTouchEnabled property to true.
    ///- Parameter event: The event to which the touches belong.
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
