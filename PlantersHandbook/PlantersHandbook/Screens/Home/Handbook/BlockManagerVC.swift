//
//  BlockManagerVC.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import UIKit
import RealmSwift

class BlockManagerVC: ProgramicVC {
    
    fileprivate var titleLayout : UIView!
    fileprivate var actionLayout : UIView!
    fileprivate var tableViewLayout : UIView!
    
    fileprivate let handbookId: String
    fileprivate var blockNotificationToken: NotificationToken?
    fileprivate let blocks: Results<Block>
    fileprivate let titleLabel : UILabel
    fileprivate let blockNameTextField = SUI_TextField_Form(placeholder: "", textType: .name)
    fileprivate let addBlockButton = PH_Button(title: "Add Block", fontSize: FontSize.large)
    fileprivate var blockTableView = SUI_TableView()
    
    required init(title: String, handbookId: String) {
        self.blocks = realmDatabase.getBlockRealm(predicate: NSPredicate(format: "entryId = %@", handbookId)).sorted(byKeyPath: "_id")
        self.handbookId = handbookId
        self.titleLabel = SUI_Label(title: title, fontSize: FontSize.largeTitle)
        
        super.init(nibName: nil, bundle: nil)
        
        self.title = "Blocks"

        blockNotificationToken = blocks.observe { [weak self] (changes) in
            guard let tableView = self?.blockTableView else { return }
            switch changes {
            case .initial:
                // Results are now populated and can be accessed without blocking the UI
                tableView.reloadData()
            case .update(_, let deletions, let insertions, let modifications):
                // Query results have changed, so apply them to the UITableView.
                tableView.performBatchUpdates({
                    // It's important to be sure to always update a table in this order:
                    // deletions, insertions, then updates. Otherwise, you could be unintentionally
                    // updating at the wrong index!
                    tableView.deleteRows(at: deletions.map({ IndexPath(row: $0, section: 0) }),
                        with: .automatic)
                    tableView.insertRows(at: insertions.map({ IndexPath(row: $0, section: 0) }),
                        with: .automatic)
                    tableView.reloadRows(at: modifications.map({ IndexPath(row: $0, section: 0) }),
                        with: .automatic)
                })
            case .error(let error):
                // An error occurred while opening the Realm file on the background worker thread
                fatalError("\(error)")
            }
        }
    }
    
    deinit {
        blockNotificationToken?.invalidate()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func generateLayout() {
        titleLayout = SUI_View(backgoundColor: .systemBackground)
        actionLayout = SUI_View(backgoundColor: .systemBackground)
        tableViewLayout = SUI_View(backgoundColor: .systemBackground)
    }
    
    override func configureViews() {
        setUpOverlay()
        setUpTitleLayout()
        setUpActionLayout()
        setUpTableViewLayout()
        setUpTableDelegates()
        keyboardMoveUpWhenTextFieldTouched = 0
    }
    
    override func setActions() {
        addBlockButton.addTarget(self, action: #selector(addBlockAction), for: .touchUpInside)
    }
    
    func setUpOverlay(){
        let frame = bgView.safeAreaFrame
        
        [titleLayout, actionLayout, tableViewLayout].forEach{bgView.addSubview($0)}
        
        titleLayout.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor, padding: .init(top: 10, left: 0, bottom: 0, right: 0),size: .init(width: frame.width, height: frame.height*0.1))
        
        actionLayout.anchor(top: titleLayout.bottomAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor, size: .init(width: frame.width, height: frame.height*0.20))
        tableViewLayout.anchor(top: actionLayout.bottomAnchor, leading: bgView.leadingAnchor, bottom: nil, trailing: bgView.trailingAnchor, size: .init(width: frame.width, height: frame.height*0.70))
    }
    
    func setUpTitleLayout(){
        [titleLabel].forEach{titleLayout.addSubview($0)}
        
        titleLabel.anchor(top: nil, leading: nil, bottom: nil, trailing: nil, size: .init(width: titleLayout.safeAreaFrame.width/2, height: titleLayout.safeAreaFrame.height/2))
        titleLabel.anchorCenter(to: titleLayout)
    }
    
    func setUpActionLayout(){
        let actionFrame = actionLayout.safeAreaFrame
        let textFieldBoundarySpace = CGFloat(50)
        
        [blockNameTextField, addBlockButton].forEach{actionLayout.addSubview($0)}

        blockNameTextField.anchor(top: actionLayout.topAnchor, leading: actionLayout.leadingAnchor, bottom: nil, trailing: actionLayout.trailingAnchor, padding: .init(top: 5, left: textFieldBoundarySpace, bottom: 0, right: textFieldBoundarySpace))
        blockNameTextField.anchorCenterX(to: actionLayout)
        self.blockNameTextField.delegate = self
        blockNameTextField.textAlignment = .center
        
        addBlockButton.anchor(top: blockNameTextField.bottomAnchor, leading: nil, bottom: actionLayout.bottomAnchor, trailing: nil, padding: .init(top: 10, left: 0, bottom: 0, right: 0),size: .init(width: actionFrame.width*0.6, height: 0))
        addBlockButton.anchorCenterX(to: actionLayout)
    }
    
    func setUpTableViewLayout(){
        [blockTableView].forEach{tableViewLayout.addSubview($0)}

        blockTableView.rowHeight = 70
        
        blockTableView.anchor(top: tableViewLayout.topAnchor, leading: tableViewLayout.leadingAnchor, bottom: tableViewLayout.bottomAnchor, trailing: tableViewLayout.trailingAnchor, padding: .init(top: 20, left: 0, bottom: 0, right: 0))
        setUpTableDelegates()
    }
    
    func setUpTableDelegates(){
        blockTableView.delegate = self
        blockTableView.dataSource = self
    }
    
    func nextVC(block: Block){
        self.navigationController?.pushViewController(
            SubBlockManagerVC(title: block.title, blockId: block._id),
            animated: true
        )
    }
    
    @objc func addBlockAction(){
        if (blocks.contains{$0.title == blockNameTextField.text!}) {
                let alert = UIAlertController(title: "Duplicate Block", message: "You already have a block with that name in this entry, use a different name", preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
                self.present(alert, animated: true)
                return
        }
        else{
            if(blockNameTextField.text! != ""){
                let block = Block(partition: realmDatabase.getParitionValue()!, title: blockNameTextField.text!, entryId: handbookId)
                realmDatabase.add(item: block)
            }
        }
        blockNameTextField.text = ""
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        view.endEditing(true)
        return false
    }

}

extension BlockManagerVC: UITableViewDelegate, UITableViewDataSource{
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return blocks.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cell", for: indexPath)
        cell.textLabel?.text = blocks[indexPath.row].title
        cell.textLabel?.textAlignment = .center
        cell.textLabel?.font = UIFont(name: Fonts.avenirNextMeduim, size: CGFloat(FontSize.extraLarge))
        cell.textLabel?.adjustsFontSizeToFitWidth = true
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: false)
        nextVC(block: blocks[indexPath.row])
    }

    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else { return }
        
        let block = blocks[indexPath.row]
        realmDatabase.deleteBlock(block: block){ (result) in
            if(result){
                print("Block Deleted From BlockManager")
            }
            else{
                let alertController = UIAlertController(title: "Error: Realm Erro", message: "Could Not Delete Block", preferredStyle: .alert)
                let defaultAction = UIAlertAction(title: "OK", style: .cancel, handler: nil)
                alertController.addAction(defaultAction)
                self.present(alertController, animated: true, completion: nil)
            }
        }
    }
}
