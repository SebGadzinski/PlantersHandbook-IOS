//
//  StatisticsViewController.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-08.
//

import UIKit
import RealmSwift

class StatisticsVC: ProgramicVC {
    
    var notificationToken: NotificationToken?
    let seasons: Results<Season>
    let handbookEntries: Results<HandbookEntry>
    let cardsCollectionView: UICollectionView = PH_CollectionView_Statistics()
    var longPressGesture = UILongPressGestureRecognizer()
    
    var items : [String] = ["1","2","3","4","5","6","7","8"]
    
    required init() {
        seasons = realmDatabase.getSeasonRealm(predicate: nil).sorted(byKeyPath: "_id")
        
        handbookEntries = realmDatabase.getHandbookEntryRealm(predicate: nil)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.navigationController?.navigationBar.isHidden = true
    }

    override func configureViews() {
        bgView.addSubview(cardsCollectionView)
        cardsCollectionView.fillSafeSuperView(to: bgView)
        cardsCollectionView.delegate = self
        cardsCollectionView.dataSource = self
        cardsCollectionView.dragDelegate = self
        cardsCollectionView.dropDelegate = self
    }
    
    override func setActions() {
    }
    
    fileprivate func reorderItems(coordinator: UICollectionViewDropCoordinator, destinationIndexPath: IndexPath, collectionView: UICollectionView){
        if let item = coordinator.items.first, let sourceIndexPath = item.sourceIndexPath{
            collectionView.performBatchUpdates({
                self.items.remove(at: sourceIndexPath.item)
                self.items.insert(item.dragItem.localObject as! String, at: destinationIndexPath.item)
                
                collectionView.deleteItems(at: [sourceIndexPath])
                collectionView.insertItems(at: [destinationIndexPath])
            })
            coordinator.drop(item.dragItem, toItemAt: destinationIndexPath)
        }
    }
    
}

extension StatisticsVC: UICollectionViewDelegateFlowLayout, UICollectionViewDataSource{
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if indexPath.row == 0{
            return .init(width: bgView.safeAreaFrame.width, height: view.frame.height*0.15)
        }
        else if indexPath.row == 3 || indexPath.row == 4{
            return .init(width: bgView.safeAreaFrame.width, height: view.frame.height*0.25)
        }
        else{
            return  .init(width: bgView.safeAreaFrame.width, height: view.frame.height*0.4)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return 8
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        if indexPath.row == 0{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "TotalCashCell", for: indexPath) as! TotalCashCell
           return cell
        }
        else if indexPath.row == 1{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LineGraphCell", for:  indexPath) as! LineGraphCell
            return cell
        }
        else if indexPath.row == 2{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LineGraphCell", for:  indexPath) as! LineGraphCell
            return cell
        }
        else if indexPath.row == 3{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OverallStatsCell", for: indexPath) as! OverallStatsCell
            return cell
        }
        else if indexPath.row == 4{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "PieChartCell", for: indexPath) as! PieChartCell
            return cell
        }
        else if indexPath.row == 5{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "OverallStatsCell", for: indexPath) as! OverallStatsCell
            return cell
        }
        else if indexPath.row == 6{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "LineGraphCell", for: indexPath) as! LineGraphCell
            return cell
        }
        else{
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "HorizontalBarGraphCell", for: indexPath) as! HorizontalBarGraphCell
            return cell
        }
    }
}

extension StatisticsVC: UICollectionViewDragDelegate{
    func collectionView(_ collectionView: UICollectionView, itemsForBeginning session: UIDragSession, at indexPath: IndexPath) -> [UIDragItem] {
        let item = self.items[indexPath.row]
        let itemProvider = NSItemProvider(object: item as NSString)
        let dragItem = UIDragItem(itemProvider: itemProvider)
        dragItem.localObject = item
        return [dragItem]
    }
}

extension StatisticsVC: UICollectionViewDropDelegate{
    func collectionView(_ collectionView: UICollectionView, performDropWith coordinator: UICollectionViewDropCoordinator) {
        var destinationIndexPath: IndexPath
        if let indexPath = coordinator.destinationIndexPath{
            destinationIndexPath = indexPath
        } else{
            let row = collectionView.numberOfItems(inSection: 0)
            destinationIndexPath = IndexPath(item: row-1, section: 0)
        }
        
        if coordinator.proposal.operation == .move{
            self.reorderItems(coordinator: coordinator, destinationIndexPath: destinationIndexPath, collectionView: collectionView)
        }
        
    }
    
    func collectionView(_ collectionView: UICollectionView, dropSessionDidUpdate session: UIDropSession, withDestinationIndexPath destinationIndexPath: IndexPath?) -> UICollectionViewDropProposal {
        if collectionView.hasActiveDrag{
            return UICollectionViewDropProposal(operation: .move, intent: .insertAtDestinationIndexPath)
        }
        return UICollectionViewDropProposal(operation: .forbidden)
    }
    
    
}
    
    
    
    
    
//    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
//        return 8
//    }
//
//    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
//        if indexPath.row == 0{
//            return view.frame.height*0.15
//        }
//        else if indexPath.row == 3 || indexPath.row == 4{
//            return view.frame.height*0.25
//        }
//        else{
//            return view.frame.height*0.4
//        }
//    }
//
//    func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
//        return .none
//    }
//
//    func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
//        return false
//    }
//
//    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
//        self.navigationItem.rightBarButtonItem?.style = .done
//        return true
//    }
//
//    func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
////        let movedObject = self.headlines[sourceIndexPath.row]
////        headlines.remove(at: sourceIndexPath.row)
////        headlines.insert(movedObject, at: destinationIndexPath.row)
//    }
//
//    override var prefersStatusBarHidden: Bool {
//            return true
//    }
//
//    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
//        if indexPath.row == 0{
//            let cell = tableView.dequeueReusableCell(withIdentifier: "TotalCashCell", for: indexPath) as! TotalCashCell
//
//            return cell
//        }
//        else if indexPath.row == 1{
//            let cell = tableView.dequeueReusableCell(withIdentifier: "LineGraphCell", for: indexPath) as! LineGraphCell
//            return cell
//        }
//        else if indexPath.row == 2{
//            let cell = tableView.dequeueReusableCell(withIdentifier: "LineGraphCell", for: indexPath) as! LineGraphCell
//            return cell
//        }
//        else if indexPath.row == 3{
//            let cell = tableView.dequeueReusableCell(withIdentifier: "OverallStatsCell", for: indexPath) as! OverallStatsCell
//            return cell
//        }
//        else if indexPath.row == 4{
//            let cell = tableView.dequeueReusableCell(withIdentifier: "PieChartCell", for: indexPath) as! PieChartCell
//            return cell
//        }
//        else if indexPath.row == 5{
//            let cell = tableView.dequeueReusableCell(withIdentifier: "OverallStatsCell", for: indexPath) as! OverallStatsCell
//            return cell
//        }
//        else if indexPath.row == 6{
//            let cell = tableView.dequeueReusableCell(withIdentifier: "LineGraphCell", for: indexPath) as! LineGraphCell
//            return cell
//        }
//        else{
//            let cell = tableView.dequeueReusableCell(withIdentifier: "HorizontalBarGraphCell", for: indexPath) as! HorizontalBarGraphCell
//            return cell
//        }
//    }
