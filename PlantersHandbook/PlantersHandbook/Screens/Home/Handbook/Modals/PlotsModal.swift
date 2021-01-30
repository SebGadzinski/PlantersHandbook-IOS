//
//  PlotsVC.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import UIKit
import RealmSwift

class PlotsModal: ProgramicVC {
    
    fileprivate let plots: List<PlotInput>
    
    fileprivate var titleLayout : UIView!
    fileprivate var plotsLayout : UIView!
    
    fileprivate let titleLb = label_normal(title: "Plots", fontSize: FontSize.extraLarge)
    fileprivate let densityLb = label_normal(title: "Density: ", fontSize: FontSize.large)
    fileprivate var plotsCv : UICollectionView!
    
    required init(title: String, plots: List<PlotInput>) {
        self.plots = plots
       
        super.init(nibName: nil, bundle: nil)

        self.title = title
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        calculateDensity()
    }
    
    override func generateLayout(){
        titleLayout = generalLayout(backgoundColor: .systemBackground)
        plotsLayout = generalLayout(backgoundColor: .systemBackground)
        plotsCv = plotsCV()
        keyboardSetUp()
    }
    
    override func configureViews(){
        setUpOverlay()
        setUpTitleLayout()
        setUpPlotsLayout()
    }
    
    func setUpOverlay(){
        let frame = bgView.safeAreaFrame
        
        [titleLayout, plotsLayout].forEach{bgView.addSubview($0)}
        titleLayout.anchor(top: bgView.topAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor, size: .init(width: frame.width, height: frame.height*0.15))
        plotsLayout.anchor(top: titleLayout.bottomAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor,size: .init(width: frame.width, height: frame.height*0.6))
    }
    
    func setUpTitleLayout(){
        titleLayout.addSubview(titleLb)
        titleLayout.addSubview(densityLb)
        titleLb.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: .init(width: titleLayout.safeAreaFrame.width/2, height: titleLayout.safeAreaFrame.height/2))
        titleLb.centerXAnchor.constraint(equalTo: titleLayout.centerXAnchor).isActive = true
        titleLb.centerYAnchor.constraint(equalTo: titleLayout.centerYAnchor).isActive = true
        densityLb.anchor(top: titleLb.bottomAnchor, leading: nil, bottom: nil, trailing: nil, padding: .init(top: 5, left: 0, bottom: 0, right: 0), size: .init(width: titleLayout.safeAreaFrame.width, height: titleLayout.safeAreaFrame.height/4))
        densityLb.anchorCenterX(to: titleLayout)
        densityLb.font = UIFont(name: Fonts.avenirNextMeduim, size: 16)
    }
    
    func setUpPlotsLayout(){
        let plotFrame = plotsLayout.safeAreaFrame.size
        plotsCv.delegate = self
        plotsCv.dataSource = self
        plotsLayout.addSubview(plotsCv)
        plotsCv.anchor(top: plotsLayout.topAnchor, leading: nil, bottom: plotsLayout.bottomAnchor, trailing: nil,size: .init(width: plotFrame.width*0.7, height: plotFrame.height))
        plotsCv.centerXAnchor.constraint(equalTo: plotsLayout.centerXAnchor).isActive = true
    }

    @objc func plotOneAction(_ sender: UITextField) {
        let cel  = sender.superview!.superview! as! PlotCell
        let row = Int(cel.number.text!)! - 1
        realmDatabase.updateCachePlotInputs(plotArray: plots, row: row, plotInputOne: integer(from: sender), plotInputTwo: nil)
        if(plots[row].inputOne == 0){
            sender.text = ""
        }
        calculateDensity()
    }
    @objc func plotTwoAction(_ sender: UITextField) {
        let cel  = sender.superview!.superview! as! PlotCell
        let row = Int(cel.number.text!)! - 1
        realmDatabase.updateCachePlotInputs(plotArray: plots, row: row, plotInputOne: integer(from: sender), plotInputTwo: nil)
        if(plots[row].inputTwo == 0){
            sender.text = ""
        }
        calculateDensity()
    }
    
    func calculateDensity(){
        densityLb.text = "Density: " + totalDensityFromArray(plotArray: plots).round(to: 2)
    }
}

extension PlotsModal: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout{
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width, height: collectionView.frame.height*0.1)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return TallyNumbers.bagUpRows
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = plotsCv.dequeueReusableCell(withReuseIdentifier: "PlotCell", for: indexPath) as! PlotCell
        cell.number.text = String(indexPath.row+1)
        cell.plotOne.inputAccessoryView = kb
        cell.plotTwo.inputAccessoryView = kb
        cell.plotOne.addTarget(self, action: #selector(plotOneAction), for: .editingDidEnd)
        cell.plotTwo.addTarget(self, action: #selector(plotTwoAction), for: .editingDidEnd)
        cell.plotOne.text = (plots[indexPath.row].inputOne != 0 ? String(plots[indexPath.row].inputOne) : "")
        cell.plotTwo.text = (plots[indexPath.row].inputTwo != 0 ? String(plots[indexPath.row].inputTwo) : "")
        return cell
    }
}
