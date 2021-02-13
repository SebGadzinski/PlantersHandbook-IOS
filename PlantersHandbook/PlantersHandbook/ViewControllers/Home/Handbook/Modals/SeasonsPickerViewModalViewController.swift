//
//  SeasonsPickerViewModal.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-02-04.
//


import RealmSwift

class SeasonsPickerViewModalViewController: SeasonsPickerViewModalView {
    weak var delegate : SeasonsPickerViewModalDelegate?
    fileprivate let seasons: Results<Season>
    fileprivate var seasonSelected = 0
    fileprivate var prevSeasonSelected : Int
    
    required init(seasonSelected: Int) {
        seasons = realmDatabase.getSeasonRealm(predicate: nil).sorted(byKeyPath: "_id")
        self.prevSeasonSelected = seasonSelected
        super.init(nibName: nil, bundle: nil)
    }
    
    internal override func configureViews(){
        super.configureViews()
        seasonsPickerView.delegate = self
        seasonsPickerView.dataSource = self
        seasonsPickerView.selectRow(seasonSelected, inComponent: 0, animated: true)
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

    internal override func setActions() {
        confirmButton.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
    }

    @objc fileprivate func confirmAction(){
        self.navigationController?.popViewController(animated: true)
    }

}

extension SeasonsPickerViewModalViewController: UIPickerViewDelegate, UIPickerViewDataSource{
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

protocol SeasonsPickerViewModalDelegate:NSObjectProtocol {
    func selectSeason(indexOfSeason: Int, changeAllGraphs: Bool)
}
