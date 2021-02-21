//
//  QuickPrepModalViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-16.
//

import UIKit

class QuickPrepModalViewController: QuickPrepModalView {
    weak var delegate : QuickPrepModalViewDelegate?
    fileprivate var treeTypes : [String] = []
    fileprivate var centPerTreeTypes : [Double] = []
    fileprivate var bundlesPerTreeTypes : [Int] = []
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        firstTimerKey = "QuickPrepModalViewController"
        if(isFirstTimer()){
            let alertController = UIAlertController(title: "Quick Prep", message: "Welcome to Quick Prep! \n\n Here you can set up what your normal info on the tally sheet would look like. (Considering you work with the same type of trees and cents for weeks straight sometimes). \n Press confirm once you set it up and it auto fills the tally. Once set, every time you start a tally you can use Quick Prep to prep the tally with your already set up info", preferredStyle: .alert)
            let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: {_ in
                self.saveFirstTimer(finishedFirstTime: true)
            })
            alertController.addAction(defaultAction)
            self.present(alertController, animated: true, completion: nil)
        }
    }
    
    override func configureViews() {
        super.configureViews()
        treeTypes = getTreeTypes()
        centPerTreeTypes = getCentPerTreeTypes()
        bundlesPerTreeTypes = getBundlesPerTreeTypes()
        treeTypesCollectionView.delegate = self
        treeTypesCollectionView.dataSource = self
        centPerTreeTypeCollectionView.delegate = self
        centPerTreeTypeCollectionView.dataSource = self
        bundlePerTreeTypeCollectionView.delegate = self
        bundlePerTreeTypeCollectionView.dataSource = self
        
    }
    
    override func setActions(){
        confirmButton.addTarget(self, action: #selector(confirmButtonAction), for: .touchUpInside)
    }
    
    @objc func confirmButtonAction(_ sender: Any) {
        saveArrays()
        if let delegate = delegate{
            delegate.fillInfo(treeTypes: treeTypes, centPerTreeTypes: centPerTreeTypes, bundlePerTreeTypes: bundlesPerTreeTypes)
        }
        // For Dismissing the Popup
        self.dismiss(animated: true, completion: nil)
        // Dismiss current Viewcontroller and back to Original
        self.navigationController?.popViewController(animated: true)
    }
    
    fileprivate func getTreeTypes() -> [String]{
        if let tempItems = userDefaults.object(forKey: "prepTreeTypes"){
            let items = tempItems as! NSArray
            return items as! [String]
        }
        return ["","","","","","","",""]
    }
    
    fileprivate func getCentPerTreeTypes() -> [Double]{
        if let tempItems = userDefaults.object(forKey: "prepCentPerTreeTypes"){
            let items = tempItems as! NSArray
            return items as! [Double]
        }
        return [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
    }
    
    fileprivate func getBundlesPerTreeTypes() -> [Int]{
        if let tempItems = userDefaults.object(forKey: "prepBundlesPerTreeTypes"){
            let items = tempItems as! NSArray
            return items as! [Int]
        }
        return [0,0,0,0,0,0,0,0]
    }
    
    @objc fileprivate func treeTypesInputAction(sender: UITextField){
        treeTypes[sender.tag] = sender.text!
    }
    
    @objc fileprivate func centPerTreeInputAction(sender: UITextField){
        if(GeneralFunctions.containsLetters(input: sender.text!)){
            let alert = UIAlertController(title: "Error: Incorrect Type", message: "Please use numbers only for cent per tree value", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

            self.present(alert, animated: true)
            sender.text = ""
        }
        else{
            centPerTreeTypes[sender.tag] = (sender.text! == "" ? 0 : Double(sender.text!)!)
        }
    }
    
    @objc fileprivate func bundleAmountInputAction(sender: UITextField){
        if(GeneralFunctions.containsLetters(input: sender.text!)){
            let alert = UIAlertController(title: "Error: Incorrect Type", message: "Please use numbers only for bundle amount", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

            self.present(alert, animated: true)
            sender.text = ""
        }
        else{
            bundlesPerTreeTypes[sender.tag] = (sender.text! == "" ? 0 : Int(sender.text!)!)
        }
    }
    
    
    fileprivate func saveArrays() {
        userDefaults.set(treeTypes, forKey:"prepTreeTypes")
        userDefaults.set(centPerTreeTypes, forKey:"prepCentPerTreeTypes")
        userDefaults.set(bundlesPerTreeTypes, forKey:"prepBundlesPerTreeTypes")
    }
}

protocol QuickPrepModalViewDelegate:NSObjectProtocol {
    func fillInfo(treeTypes : [String], centPerTreeTypes : [Double], bundlePerTreeTypes : [Int])
}

extension QuickPrepModalViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: widthOfCollectionCell, height: collectionView.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TallyCell", for: indexPath) as! TallyCell
        if(collectionView == self.treeTypesCollectionView){
            GeneralFunctions.createAdvancedTallyCell(cell: cell, toolBar: toolBar, tag: indexPath.row, keyboardType: .default)
            cell.input.addTarget(self, action: #selector(treeTypesInputAction), for: .editingDidEnd)
            cell.input.text = treeTypes[indexPath.row]
            return cell
        }
        else if(collectionView == self.centPerTreeTypeCollectionView){
            GeneralFunctions.createAdvancedTallyCell(cell: cell, toolBar: toolBar, tag: indexPath.row, keyboardType: .decimalPad)
            cell.input.addTarget(self, action: #selector(centPerTreeInputAction), for: .editingDidEnd)
            cell.input.text = (centPerTreeTypes[indexPath.row] == 0 ? "" : String(centPerTreeTypes[indexPath.row]))
            return cell
        }
        else{
            GeneralFunctions.createAdvancedTallyCell(cell: cell, toolBar: toolBar, tag: indexPath.row, keyboardType: .numberPad)
            cell.input.addTarget(self, action: #selector(bundleAmountInputAction), for: .editingDidEnd)
            cell.input.text = (bundlesPerTreeTypes[indexPath.row] == 0 ? "" : String(bundlesPerTreeTypes[indexPath.row]))
            return cell
        }
    }
}
