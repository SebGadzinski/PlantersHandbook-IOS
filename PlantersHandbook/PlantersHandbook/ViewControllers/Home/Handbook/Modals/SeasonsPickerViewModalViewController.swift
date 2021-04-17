//
//  SeasonsPickerViewModal.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-04.
//


import RealmSwift

///SeasonsPickerViewModalViewController.swift - Displays all seasons in a picker view 
class SeasonsPickerViewModalViewController: SeasonsPickerViewModalView {
    weak var delegate : SeasonsPickerViewModalDelegate?
    fileprivate let seasons: Results<Season>
    fileprivate var seasonSelected = 0
    fileprivate var prevSeasonSelected : Int
    
    ///Contructor that initalizes required fields
    ///- Parameter seasonSelected: Index of season selected in list of seasons
    required init(seasonSelected: Int) {
        seasons = realmDatabase.findObjectRealm(predicate: nil, classType: Season()).sorted(byKeyPath: "_id")
        self.prevSeasonSelected = seasonSelected
        super.init(nibName: nil, bundle: nil)
    }
    
    ///Configuire all views in programic view controller
    internal override func configureViews(){
        super.configureViews()
        seasonsPickerView.delegate = self
        seasonsPickerView.dataSource = self
        seasonsPickerView.selectRow(seasonSelected, inComponent: 0, animated: true)
    }
    
    ///Functionality for when view will disappear
    ///- Parameter animated: Boolean to decide if view will disappear with anination or not
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if let delegate = delegate{
            if prevSeasonSelected != seasonSelected{
                delegate.selectSeason(indexOfSeason: seasonSelected, changeAllGraphs: (changeAllGraphsCheckBox.checkState == .checked ? true : false))
            }
        }
    }
    
    ///Contructor that decodes code for stroyboard
    ///- Parameter coder: Decoder for code to be translated into storyboard usage
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    ///Set all actions in progrmaic view controller
    internal override func setActions() {
        confirmButton.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
    }

    ///Pops modal view controller from navigation controller stack and returns to HandbookViewController
    @objc fileprivate func confirmAction(){
        self.navigationController?.popViewController(animated: true)
    }

}

///Functionality required for using UIPickerViewDelegate and UIPickerViewDataSource
extension SeasonsPickerViewModalViewController: UIPickerViewDelegate, UIPickerViewDataSource{
    ///Called by the UIPickerView when it needs the number of compenets
    ///- Parameter pickerView: UIPickerView requesting data
    ///- Returns: Number of compenents required
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    ///Called by the UIPickerView when it needs number of rows in each component
    ///- Parameter pickerView: UIPickerView requesting data
    ///- Returns: Number of rows in components required
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return seasons.count
    }
    
    ///Called by the UIPickerView when it needs title for a component
    ///- Parameter pickerView: UIPickerView requesting data
    ///- Returns: Title for row
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return seasons[row].title
    }
    
    ///Called by the UIPickerView when a row is selected
    ///- Parameter pickerView: UIPickerView requesting data
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        seasonSelected = row
    }
}

///Protocol used for a view controller that uses SeasonPickerViewModalVIewController
protocol SeasonsPickerViewModalDelegate:NSObjectProtocol {
    ///Tells the delegate to select season and change all graphs
    ///- Parameter indexOfSeason: Index of season in all seasons
    ///- Parameter changeAllGraphs: Boolean to change all graphs or just one selected
    func selectSeason(indexOfSeason: Int, changeAllGraphs: Bool)
}
