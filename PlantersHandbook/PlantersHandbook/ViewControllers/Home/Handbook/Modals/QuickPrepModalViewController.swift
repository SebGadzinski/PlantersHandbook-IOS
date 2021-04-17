//
//  QuickPrepModalViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-16.
//

import UIKit

///QuickPrepModalViewController.swift - Displays personal quickprep arrays for treeTypes, centPerTreeTypes, and bundlePerTreeTypes in a cache
class QuickPrepModalViewController: QuickPrepModalView {
    weak var delegate : QuickPrepModalViewDelegate?
    fileprivate var treeTypes : [String] = []
    fileprivate var centPerTreeTypes : [Double] = []
    fileprivate var bundlesPerTreeTypes : [Int] = []
    
    ///Functionality for when view will appear
    ///- Parameter animated: Boolean to decide if view will apear with anination or not
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
    
    ///Configuire all views in programic view controller
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
    
    ///Set all actions in progrmaic view controller
    override func setActions(){
        confirmButton.addTarget(self, action: #selector(confirmButtonAction), for: .touchUpInside)
    }
    
    ///Grabs the new treetypes, centPerTreeTypes, and bundlesPerTreeTypes lists and sends them to TallySheetViewController to be used
    ///- Parameter sender: confirmButton
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
    
    ///Gets the quickPrep treeTypes array from the saved local storage
    fileprivate func getTreeTypes() -> [String]{
        if let tempItems = userDefaults.object(forKey: "prepTreeTypes"){
            let items = tempItems as! NSArray
            return items as! [String]
        }
        return ["","","","","","","",""]
    }
    
    ///Gets the quickPrep centPerTreeTypes array from the saved local storage
    fileprivate func getCentPerTreeTypes() -> [Double]{
        if let tempItems = userDefaults.object(forKey: "prepCentPerTreeTypes"){
            let items = tempItems as! NSArray
            return items as! [Double]
        }
        return [0.0,0.0,0.0,0.0,0.0,0.0,0.0,0.0]
    }
    
    ///Gets the quickPrep bundlePerTreeTypes array from the saved local storage
    fileprivate func getBundlesPerTreeTypes() -> [Int]{
        if let tempItems = userDefaults.object(forKey: "prepBundlesPerTreeTypes"){
            let items = tempItems as! NSArray
            return items as! [Int]
        }
        return [0,0,0,0,0,0,0,0]
    }
    
    ///Ensures changes to a treeType UITextField is put into the treeTypes array
    ///- Parameter sender: treeType UITextField
    @objc fileprivate func treeTypesInputAction(sender: UITextField){
        treeTypes[sender.tag] = sender.text!
    }
    
    ///Ensures changes to a centPerTreeType UITextField is put into the centPerTreeTypes array
    ///- Parameter sender: centPerTreeType UITextField
    @objc fileprivate func centPerTreeInputAction(sender: UITextField){
        if(sender.text!.containsLetters()){
            let alert = UIAlertController(title: "Error: Incorrect Type", message: "Please use numbers only for cent per tree value", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

            self.present(alert, animated: true)
            sender.text = ""
        }
        else{
            centPerTreeTypes[sender.tag] = (sender.text! == "" ? 0 : Double(sender.text!)!)
        }
    }
    
    ///Ensures changes to a bundleTreeType UITextField is put into the bundleTreeTypes array
    ///- Parameter sender: bundleTreeType UITextField
    @objc fileprivate func bundleAmountInputAction(sender: UITextField){
        if(sender.text!.containsLetters()){
            let alert = UIAlertController(title: "Error: Incorrect Type", message: "Please use numbers only for bundle amount", preferredStyle: .alert)

            alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))

            self.present(alert, animated: true)
            sender.text = ""
        }
        else{
            bundlesPerTreeTypes[sender.tag] = (sender.text! == "" ? 0 : Int(sender.text!)!)
        }
    }
    
    ///Save the quickPrep  treeTypes, centPerTreeTypes, and bundlesPerTreeTypes arrays to local data storage
    fileprivate func saveArrays() {
        userDefaults.set(treeTypes, forKey:"prepTreeTypes")
        userDefaults.set(centPerTreeTypes, forKey:"prepCentPerTreeTypes")
        userDefaults.set(bundlesPerTreeTypes, forKey:"prepBundlesPerTreeTypes")
    }
}

protocol QuickPrepModalViewDelegate:NSObjectProtocol {
    ///Gives the cache info arrays from quickPrep
    ///- Parameter treeTypes: treeTypes array
    ///- Parameter centPerTreeTypes: centPerTreeTypes array
    ///- Parameter bundlePerTreeTypes: bundlePerTreeTypes
    func fillInfo(treeTypes : [String], centPerTreeTypes : [Double], bundlePerTreeTypes : [Int])
}

///Functionality required for using UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout
extension QuickPrepModalViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    
    ///Asks the delegate for the size of the specified item’s cell.
    ///- Parameter collectionView: The collection view object displaying the flow layout.
    ///- Parameter collectionViewLayout: The layout object requesting the information.
    ///- Parameter indexPath: The index path of the item.
    ///- Returns: The width and height of the specified item. Both values must be greater than 0.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: widthOfCollectionCell, height: collectionView.frame.height)
    }
    
    ///Asks your data source object for the number of items in the specified section.
    ///- Parameter CollectionView: The collection view object displaying the flow layout.
    ///- Parameter numberOfItemsInSection: Given number of items to be insection
    ///- Returns: Number of items to be insection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }

    ///Asks your data source object for the cell that corresponds to the specified item in the collection view.
    ///- Parameter collectionView: The collection view object displaying the flow layout.
    ///- Parameter indexPath: Index path that specifies location of item
    ///- Returns: A configured cell object. You must not return nil from this method.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TallyCell", for: indexPath) as! TallyCell
        if(collectionView == self.treeTypesCollectionView){
            TallyCell.createAdvancedTallyCell(cell: cell, toolBar: toolBar, tag: indexPath.row, keyboardType: .default)
            cell.input.addTarget(self, action: #selector(treeTypesInputAction), for: .editingDidEnd)
            cell.input.text = treeTypes[indexPath.row]
            return cell
        }
        else if(collectionView == self.centPerTreeTypeCollectionView){
            TallyCell.createAdvancedTallyCell(cell: cell, toolBar: toolBar, tag: indexPath.row, keyboardType: .decimalPad)
            cell.input.addTarget(self, action: #selector(centPerTreeInputAction), for: .editingDidEnd)
            cell.input.text = (centPerTreeTypes[indexPath.row] == 0 ? "" : String(centPerTreeTypes[indexPath.row]))
            return cell
        }
        else{
            TallyCell.createAdvancedTallyCell(cell: cell, toolBar: toolBar, tag: indexPath.row, keyboardType: .numberPad)
            cell.input.addTarget(self, action: #selector(bundleAmountInputAction), for: .editingDidEnd)
            cell.input.text = (bundlesPerTreeTypes[indexPath.row] == 0 ? "" : String(bundlesPerTreeTypes[indexPath.row]))
            return cell
        }
    }
}
