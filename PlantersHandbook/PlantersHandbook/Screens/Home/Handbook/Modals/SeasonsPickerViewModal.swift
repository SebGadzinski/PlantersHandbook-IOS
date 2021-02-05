//
//  SeasonsPickerViewModal.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-04.
//

import UIKit
import M13Checkbox
import RealmSwift



class SeasonsPickerViewModal: ProgramicVC {
    weak var delegate : SeasonsPickerViewModal_Delegate?
    
    fileprivate var titleLayout : UIView!
    fileprivate var seasonsLayout : UIView!
    
    fileprivate let seasons: Results<Season>
    fileprivate let titleLabel = SUI_Label(title: "Seasons", fontSize: FontSize.largeTitle)
    fileprivate var seasonsPickerView = UIPickerView()
    fileprivate var changeAllGraphsCheckBox = M13Checkbox(frame: .zero)
    fileprivate let confirmButton = PH_Button(title: "Confirm", fontSize: FontSize.large)
    fileprivate let checkBoxLabel = SUI_Label(title: "Change All Graphs", fontSize: FontSize.meduim)
    fileprivate var seasonSelected = 0
    fileprivate var prevSeasonSelected : Int
    
    required init(seasonSelected: Int) {
        seasons = realmDatabase.getSeasonRealm(predicate: nil).sorted(byKeyPath: "_id")
        self.prevSeasonSelected = seasonSelected
        super.init(nibName: nil, bundle: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let delegate = delegate{
            if prevSeasonSelected != seasonSelected{
                delegate.selectSeason(indexOfSeason: seasonSelected, changeAllGraphs: (changeAllGraphsCheckBox.checkState == .checked ? true : false))
            }
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func generateLayout() {
        titleLayout = SUI_View(backgoundColor: .systemBackground)
        seasonsLayout = SUI_View(backgoundColor: .systemBackground)
    }
    
    override func configureViews() {
        setUpOverlay()
        setUpTitleLayout()
        setUpSeasonLayout()
        seasonsPickerView.selectRow(seasonSelected, inComponent: 0, animated: true)
    }
    
    override func setActions() {
        confirmButton.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
    }
    
    func setUpOverlay() {
        [titleLayout, seasonsLayout].forEach{bgView.addSubview($0)}
                
        titleLayout.anchor(top: bgView.topAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor, size: .init(width: frame.width, height: frame.height*0.15))
        seasonsLayout.anchor(top: titleLayout.bottomAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor,size: .init(width: frame.width, height: frame.height*0.8))
    }
    
    func setUpTitleLayout() {
        titleLayout.addSubview(titleLabel)
        
        titleLabel.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: .init(width: titleLayout.safeAreaFrame.width/2, height: titleLayout.safeAreaFrame.height/2))
        titleLabel.anchorCenter(to: titleLayout)
    }
    
    func setUpSeasonLayout() {
        [seasonsPickerView, changeAllGraphsCheckBox, checkBoxLabel].forEach{seasonsLayout.addSubview($0)}
        
        seasonsPickerView.delegate = self
        seasonsPickerView.dataSource = self
        seasonsPickerView.anchor(top: seasonsLayout.topAnchor, leading: seasonsLayout.leadingAnchor, bottom: nil, trailing: seasonsLayout.trailingAnchor, padding: .init(top: 10, left: 0, bottom: 10, right: 0), size: .init(width: 0, height: seasonsLayout.safeAreaFrame.height*0.8))
        
        changeAllGraphsCheckBox.anchor(top: seasonsPickerView.bottomAnchor, leading: seasonsLayout.leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 5, left: 10, bottom: 0, right: 0),size: .init(width: 30, height: 30))
        changeAllGraphsCheckBox.boxType = .square
        changeAllGraphsCheckBox.stateChangeAnimation = .bounce(.fill)
        changeAllGraphsCheckBox.tintColor = .systemGreen
        
        checkBoxLabel.anchor(top: nil, leading: changeAllGraphsCheckBox.trailingAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 5, bottom: 0, right: 0),size: .init(width: 200, height: 50))
        checkBoxLabel.anchorCenterY(to: changeAllGraphsCheckBox)
        
    }
    
    @objc func confirmAction(){
        self.navigationController?.popViewController(animated: true)
    }

}

extension SeasonsPickerViewModal: UIPickerViewDelegate, UIPickerViewDataSource{
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return seasons.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return seasons[row].title
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        seasonSelected = row
    }
}

protocol SeasonsPickerViewModal_Delegate:NSObjectProtocol {
    func selectSeason(indexOfSeason: Int, changeAllGraphs: Bool)
}
