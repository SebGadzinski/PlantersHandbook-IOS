//
//  PlotsVC.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import RealmSwift
import JDropDownAlert

///PlotsModalViewController.swift - Displays all plots within a cache
class PlotsModalViewController: PlotsModalView {
    
    fileprivate let plots: List<PlotInput>
    
    ///Contructor that initalizes required fields
    ///- Parameter title:Title of current view controller in navigation controller
    ///- Parameter plots: Lists of plots
    required init(title: String, plots: List<PlotInput>) {
        self.plots = plots
       
        super.init(nibName: nil, bundle: nil)
        keyboardMoveWhenTextFieldTouched = 150

        self.title = title
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
        plotsCollectionView.delegate = self
        plotsCollectionView.dataSource = self
        calculateDensity()
    }

    ///Action if one of the plots in the first coloumn gets edited
    ///- Parameter sender: UITextField that has been clicked
    @objc fileprivate func plotOneAction(_ sender: UITextField) {
        let cel  = sender.superview!.superview! as! PlotCell
        let row = Int(cel.number.text!)! - 1
        realmDatabase.updateCachePlotInputs(plotArray: plots, row: row, plotInputOne: GeneralFunctions.integer(from: sender), plotInputTwo: nil){ success, error in
            if error != nil{
                let alert = JDropDownAlert()
                alert.alertWith("Error with database, restart app if further errors")
            }
        }
        if(plots[row].inputOne == 0){
            sender.text = ""
        }
        calculateDensity()
    }
    
    ///Action if one of the plots in the first coloumn gets edited
    ///- Parameter sender: UITextField that has been clicked
    @objc fileprivate func plotTwoAction(_ sender: UITextField) {
        let cel  = sender.superview!.superview! as! PlotCell
        let row = Int(cel.number.text!)! - 1
        realmDatabase.updateCachePlotInputs(plotArray: plots, row: row, plotInputOne: nil, plotInputTwo: GeneralFunctions.integer(from: sender)){ success, error in
            if error != nil{
                let alert = JDropDownAlert()
                alert.alertWith("Error with database, restart app if further errors")
            }
        }
        if(plots[row].inputTwo == 0){
            sender.text = ""
        }
        calculateDensity()
    }
    
    ///Calculates density of the current plot array and updates the denisty label
    fileprivate func calculateDensity(){
        densityLabel.text = "Density: " + String(GeneralFunctions.totalDensityFromArray(plotArray: plots).round(to: 2))
    }
}

///Functionality required for using UICollectionViewDelegate, UICollectionViewDataSource, and UICollectionViewDelegateFlowLayout
extension PlotsModalViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    ///Asks the delegate for the size of the specified item’s cell
    ///- Parameter collectionView: The collection view object displaying the flow layout.
    ///- Parameter collectionViewLayout: Layout object requesting information
    ///- Parameter sizeForItemAt: Size for the items at that indexPath
    ///- Parameter indexPath: Index path of item
    ///- Returns: The width and height of the specified item. Both values must be greater than 0.
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height*0.1)
    }
    ///Asks your data source object for the number of items in the specified section.
    ///- Parameter collectionView: The collection view object displaying the flow layout.
    ///- Parameter numberOfItemsInSection: Given number of items to be insection
    ///- Returns: Number of items to be insection
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TallyNumbers.bagUpRows
    }

    ///Asks your data source object for the cell that corresponds to the specified item in the collection view.
    ///- Parameter collectionView: The collection view object displaying the flow layout.
    ///- Parameter indexPath: Index path that specifies location of item
    ///- Returns: A configured cell object. You must not return nil from this method.
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = plotsCollectionView.dequeueReusableCell(withReuseIdentifier: "PlotCell", for: indexPath) as! PlotCell
        cell.number.text = String(indexPath.row+1)
        cell.plotOne.inputAccessoryView = toolBar
        cell.plotTwo.inputAccessoryView = toolBar
        cell.plotOne.addTarget(self, action: #selector(plotOneAction), for: .editingDidEnd)
        cell.plotTwo.addTarget(self, action: #selector(plotTwoAction), for: .editingDidEnd)
        cell.plotOne.text = (plots[indexPath.row].inputOne != 0 ? String(plots[indexPath.row].inputOne) : "")
        cell.plotTwo.text = (plots[indexPath.row].inputTwo != 0 ? String(plots[indexPath.row].inputTwo) : "")
        return cell
    }
}
