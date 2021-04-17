//
//  NotesModalViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-15.
//

import UIKit

///NotesModalViewController.swift - Displays notes from a handbookEntry
class NotesModalViewController: NotesModalView {
    weak var delegate : NotesModalViewDelegate?
    fileprivate let initalText : String
    fileprivate let motivationArray = ["Every strawberry you eat is a tree you could have planted", "Jeez your using notes, must of been a bad block", "Stop crying about the block and get back to pounding!!", "Fun fact about tree planting is that nobody actually likes it, but they still love it", "Today was the day that I decided to get a pb ... in amount of berries I can eat", "Why did I choose this job", "You think the bears would be mad if I eat all there berries?", "Just think, in a day or two its a day off"]
    
    ///Contructor that initalizes required fields and does any neccesary start functionality
    ///- Parameter text: Text to be filled into notes UITextView
    required init(text: String) {
        initalText = text
        super.init(nibName: nil, bundle: nil)
        textFieldShouldReturn = true
    }
    
    ///Contructor that decodes code for stroyboard
    ///- Parameter coder: Decoder for code to be translated into storyboard usage
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    ///Functionality for when view will appear
    ///- Parameter animated: Boolean to decide if view will apear with anination or not
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        notesField.text = initalText
        setUpUITextView()
        notesField.isScrollEnabled = true
    }
    
    ///Functionality for when view will disappear
    ///- Parameter animated: Boolean to decide if view will disappear with anination or not
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let delegate = delegate{
            delegate.saveNotes(notes: notesField.text.trimmingCharacters(in: .whitespacesAndNewlines))
        }
        self.dismiss(animated: true, completion: nil)
        // Dismiss current Viewcontroller and back to Original
        self.navigationController?.popViewController(animated: true)
    }
    
    ///Sets up the notes UITextView
    fileprivate func setUpUITextView(){
        if(notesField.text == ""){
            notesField.text = motivationArray[Int.random(in: 0..<motivationArray.count - 1)]
        }
        notesField.isScrollEnabled = false
        //Allows user to scroll down in textView
        notesField.text += "\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n\n"
    }
}

///Protocol used for a view controller that uses AddSeasonModalVIewController
protocol NotesModalViewDelegate:NSObjectProtocol {
    ///Tells the delegate to save the notes
    ///- Parameter notes: Notes from user for the handbookEntry
    func saveNotes(notes : String)
}
