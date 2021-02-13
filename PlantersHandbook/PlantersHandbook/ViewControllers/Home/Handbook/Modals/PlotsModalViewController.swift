//
//  PlotsVC.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import RealmSwift

class PlotsModalViewController: PlotsModalView {
    
    fileprivate let plots: List<PlotInput>
    
    required init(title: String, plots: List<PlotInput>) {
        self.plots = plots
       
        super.init(nibName: nil, bundle: nil)
        keyboardMoveUpWhenTextFieldTouched = 150

        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        plotsCollectionView.delegate = self
        plotsCollectionView.dataSource = self
        calculateDensity()
    }

    @objc fileprivate func plotOneAction(_ sender: UITextField) {
        let cel  = sender.superview!.superview! as! PlotCell
        let row = Int(cel.number.text!)! - 1
        realmDatabase.updateCachePlotInputs(plotArray: plots, row: row, plotInputOne: GeneralFunctions.integer(from: sender), plotInputTwo: nil)
        if(plots[row].inputOne == 0){
            sender.text = ""
        }
        calculateDensity()
    }
    @objc fileprivate func plotTwoAction(_ sender: UITextField) {
        let cel  = sender.superview!.superview! as! PlotCell
        let row = Int(cel.number.text!)! - 1
        realmDatabase.updateCachePlotInputs(plotArray: plots, row: row, plotInputOne: GeneralFunctions.integer(from: sender), plotInputTwo: nil)
        if(plots[row].inputTwo == 0){
            sender.text = ""
        }
        calculateDensity()
    }
    
    fileprivate func calculateDensity(){
        densityLabel.text = "Density: " + GeneralFunctions.totalDensityFromArray(plotArray: plots).round(to: 2)
    }
}

extension PlotsModalViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height*0.1)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TallyNumbers.bagUpRows
    }

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
