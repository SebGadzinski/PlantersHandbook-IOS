//
//  NotesModalViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-15.
//

import UIKit

class NotesModalViewController: NotesModalView {
    weak var delegate : NotesModalViewDelegate?
    fileprivate let initalText : String
    fileprivate let motivationArray = ["Every strawberry you eat is a tree you could have planted", "Jeez your using notes, must of been a bad block", "Stop crying about the block and get back to pounding!!", "Fun fact about tree planting is that nobody actually likes it, but they still love it", "Today was the day that I decided to get a pb ... in amount of berries I can eat", "Why did I choose this job", "You think the bears would be mad if I eat all there berries?", "Just think, in a day or two its a day off"]
    
    required init(text: String) {
        initalText = text
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        notesField.text = initalText
        placeHolder()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let delegate = delegate{
            delegate.saveNotes(notes: notesField.text)
        }
        self.dismiss(animated: true, completion: nil)
        // Dismiss current Viewcontroller and back to Original
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }
    
    fileprivate func placeHolder(){
        if(notesField.text == ""){
            notesField.text = motivationArray[Int.random(in: 0..<motivationArray.count - 1)]
        }
        notesField.becomeFirstResponder()
    }
}

protocol NotesModalViewDelegate:NSObjectProtocol {
    func saveNotes(notes : String)
}
