//
//  RealmDatabase.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-25.
//

import Foundation
import RealmSwift
typealias CompletionHandler = (_ success:Bool) -> Void

/*
 This should only be used after the connecToRealm funciton has been called.
 It was needed to be initialized in a global scope but can only be connected once realm has been given from async.
 So the initializer is plain and struct is vulnerable to error before getting connected.
 Therefore no funcitons should be used until connect woth Realm.async as shown in Login and Splash controllers
 
 Reason for connecting Realm once for the whole applicaiton?
    - Conserves reopening realm for every function
    - MongoDB docs say to open realm specificially for a view controller for security issues but with
      this note management application, there is no security issues so opening specific realms so it is a waste of lines
 */

struct RealmDatabase{
    fileprivate var realm : Realm?
    fileprivate var partitionValue: String?
    
    public mutating func connectToRealm(realm: Realm){
        self.realm = realm
        self.partitionValue = "user=\(app.currentUser!.id)"
    }
    
    //===============GET================
    
    func getLocalUser() -> User?{
        let users = realm!.objects(User.self).filter(NSPredicate(format: "_id = %@", app.currentUser!.id))
        print(realm!.objects(User.self))
        return users.first
    }
    
    func getParitionValue() -> String?{
        return partitionValue
    }
    
    func getSubBlockById(subBlockId: String) -> SubBlock?{
        let subBlocks = realm!.objects(SubBlock.self).filter(NSPredicate(format: "_id = %@", subBlockId))
        return subBlocks.first
    }
    
    func getSeasonRealm(predicate: NSPredicate?) -> Results<Season>{
        if let predicate = predicate{
            return realm!.objects(Season.self).filter(predicate)
        }
        else{
            return realm!.objects(Season.self)
        }
    }
    
    func getHandbookEntryRealm(predicate: NSPredicate?) -> Results<HandbookEntry>{
        if let predicate = predicate{
            return realm!.objects(HandbookEntry.self).filter(predicate)
        }
        else{
            return realm!.objects(HandbookEntry.self)
        }
    }
    
    func getBlockRealm(predicate: NSPredicate?) -> Results<Block>{
        if let predicate = predicate{
            return realm!.objects(Block.self).filter(predicate)
        }
        else{
            return realm!.objects(Block.self)
        }
    }
    
    func getSubBlockRealm(predicate: NSPredicate?) -> Results<SubBlock>{
        if let predicate = predicate{
            return realm!.objects(SubBlock.self).filter(predicate)
        }
        else{
            return realm!.objects(SubBlock.self)
        }
    }
    
    func getCacheRealm(predicate: NSPredicate?) -> Results<Cache>{
        if let predicate = predicate{
            return realm!.objects(Cache.self).filter(predicate)
        }
        else{
            return realm!.objects(Cache.self)
        }
    }
    
    //===============_DELETION_================
    
    func deleteSeason(season: Season, completionHandler: CompletionHandler) {
        let entryPredicate = NSPredicate(format: "seasonId = %@", season._id)
        let entriesToDelete = realm!.objects(HandbookEntry.self).filter(entryPredicate)
        let seasonIdString = String(season._id)

        deleteBunchEntrys(entriesToDelete: entriesToDelete, entryCompletionHandler: {(success) -> Void in
            if success{
                print("Deleting Season: \(seasonIdString)")
                realm!.safeWrite{
                    realm!.delete(season)
                }
                print("Season Deleted")
                completionHandler(true)
            }
            else{
                print("Season: \(season._id) Was Not Deleted")
                completionHandler(false)
            }
        })
    }

    func deleteEntry(entry: HandbookEntry, completionHandler: CompletionHandler) {
        let blockPredicate = NSPredicate(format: "entryId = %@", entry._id)
        let blocksToDelete = realm!.objects(Block.self).filter(blockPredicate)
        let entryIdString = String(entry._id)

        deleteBunchBlocks(blocksToDelete: blocksToDelete, blockCompletionHandler: {(success) -> Void in
            if success{
                print("Deleting Entry: \(entryIdString)")
                realm!.safeWrite {
                    realm!.delete(entry)
                }
                print("Entry Deleted")
                completionHandler(true)
            }
            else{
                print("Entry: \(entry._id) Was Not Deleted")
                completionHandler(false)
            }
        })
    }

    private func deleteBunchEntrys(entriesToDelete: Results<HandbookEntry>, entryCompletionHandler: CompletionHandler){
        if(!entriesToDelete.isEmpty){
            for aEntry in entriesToDelete{
                let blockPredicate = NSPredicate(format: "entryId = %@", aEntry._id)
                let blocksToDelete = realm!.objects(Block.self).filter(blockPredicate)

                deleteBunchBlocks(blocksToDelete: blocksToDelete, blockCompletionHandler: {(success) -> Void in
                    if success{
                        print("Deleting Entry: \(aEntry._id)")
                        realm!.safeWrite {
                            realm!.delete(aEntry)
                        }
                        print("Entry Deleted")
                    }
                    else{
                        print("Entry: \(aEntry._id) Was Not Deleted")
                        entryCompletionHandler(false)
                    }
                })
            }
            entryCompletionHandler(true)
        }
        else{
            entryCompletionHandler(true)
        }
    }

    func deleteBlock(block: Block, completionHandler: CompletionHandler) {
        let subBlockPredicate = NSPredicate(format: "blockId = %@", block._id)
        let subBlocksToDelete = realm!.objects(SubBlock.self).filter(subBlockPredicate)
        let blockIdString = String(block._id)

        deleteBunchSubBlocks(subBlocksToDelete: subBlocksToDelete, subBlockCompletionHandler: {(success) -> Void in
            if success{
                print("Deletin Block: \(blockIdString)")
                realm!.safeWrite {
                    realm!.delete(block)
                }
                print("Block Deleted")
                completionHandler(true)
            }
            else{
                print("Block: \(block._id) Was Not Deleted")
                completionHandler(false)
            }
        })
    }

    private func deleteBunchBlocks(blocksToDelete: Results<Block>, blockCompletionHandler: CompletionHandler){
        if(!blocksToDelete.isEmpty){
            for aBlock in blocksToDelete{
                let subBlockPredicate = NSPredicate(format: "blockId = %@", aBlock._id)
                let subBlocksToDelete = realm!.objects(SubBlock.self).filter(subBlockPredicate)

                deleteBunchSubBlocks(subBlocksToDelete: subBlocksToDelete,subBlockCompletionHandler: {(success) -> Void in
                    if success{
                        print("Deleting Block: \(aBlock._id)")
                        realm!.safeWrite {
                            realm!.delete(aBlock)
                        }
                        print("Block Deleted")
                    }
                    else{
                        print("Block: \(aBlock._id) Was Not Deleted")
                        blockCompletionHandler(false)
                    }
                })
            }
            blockCompletionHandler(true)
        }
        else{
            blockCompletionHandler(true)
        }
    }

    func deleteSubBlock(subBlock: SubBlock, completionHandler: CompletionHandler) {
        let cachesPredicate = NSPredicate(format: "subBlockId = %@", subBlock._id)
        let cachesToDelete = realm!.objects(Cache.self).filter(cachesPredicate)
        let subBlockIdString = String(subBlock._id)

        deleteBunchCaches(cachesToDelete: cachesToDelete,  cacheCompletionHandler: {(success) -> Void in
            if success{
                print("Deleting SubBlock: \(subBlockIdString)")
                realm!.safeWrite {
                    realm!.delete(subBlock)
                }
                print("SubBlock Deleted")
                completionHandler(true)
            }
            else{
                print("SubBlock: \(subBlock._id) Was Not Deleted")
                completionHandler(false)
            }
        })
    }

    private func deleteBunchSubBlocks(subBlocksToDelete: Results<SubBlock>, subBlockCompletionHandler: CompletionHandler){
        if(!subBlocksToDelete.isEmpty){
            for aSubBlock in subBlocksToDelete{
                let cachePredicate = NSPredicate(format: "subBlockId = %@", aSubBlock._id)
                let cachesToDelete = realm!.objects(Cache.self).filter(cachePredicate)

                deleteBunchCaches(cachesToDelete: cachesToDelete, cacheCompletionHandler: {(success) -> Void in
                    if success{
                        print("Deleting SubBlock: \(aSubBlock._id)")
                        realm!.safeWrite {
                            realm!.delete(aSubBlock)
                        }
                        print("SubBlock Deleted")
                    }
                    else{
                        print("SubBlock: \(aSubBlock._id) Was Not Deleted")
                        subBlockCompletionHandler(false)
                    }
                })
            }
            subBlockCompletionHandler(true)
        }
        else{
            subBlockCompletionHandler(true)
        }
    }

    func deleteCache(cache: Cache, completionHandler: CompletionHandler) {
        print("Deleting Cache: \(cache._id)")
        realm!.safeWrite {
            for list in cache.bagUpsPerTreeTypes{
                list.input.removeAll()
            }
            cache.plots.removeAll()
            for list in cache.coordinatesCovered{
                list.input.removeAll()
            }
            realm!.delete(cache)
            print("Cache Deleted")
        }
        completionHandler(true)
    }

    private func deleteBunchCaches(cachesToDelete: Results<Cache>, cacheCompletionHandler: CompletionHandler){
        for cache in cachesToDelete{
            let id = cache._id
            deleteCache(cache: cache){ result in
                if(!result){
                    print("Cache: \(id) Was Not Deleted")
                }
            }
        }
        cacheCompletionHandler(true)
    }
    
    //===============UPDATE================
    
    public func updateUser(user: User, _partition: String?, name: String?, company: String?, stepDistance: Int?, seasons: List<String>?){
        realm!.safeWrite{
            if let parition = _partition{
                user._partition = parition
            }
            if let name = name{
                user.name = name
            }
            if let company = company{
                user.company = company
            }
            if let stepDistance = stepDistance{
                user.stepDistance = stepDistance
            }
        }
        if let seasons = seasons{
            updateList(list: user.seasons, newList: seasons)
        }
    }
    
    public func updateBlock(block: Block, _partition: String?, entryId: String?, title: String?, date: Date?, subBlocks: List<String>?){
        realm!.safeWrite{
            if let parition = _partition{
                block._partition = parition
            }
            if let entryId = entryId{
                block.entryId = entryId
            }
            if let title = title{
                block.title = title
            }
            if let date = date{
                block.date = date
            }
        }
        if let subBlocks = subBlocks{
            updateList(list: block.subBlocks, newList: subBlocks)
        }
    }
    
    public func updateSubBlock(subBlock: SubBlock, _partition: String?, blockId: String?, title: String?, date: Date?, caches: List<String>?){
        realm!.safeWrite{
            if let parition = _partition{
                subBlock._partition = parition
            }
            if let blockId = blockId{
                subBlock.blockId = blockId
            }
            if let title = title{
                subBlock.title = title
            }
            if let date = date{
                subBlock.date = date
            }
        }
        if let caches = caches{
            updateList(list: subBlock.caches, newList: caches)
        }
    }
    
    public func updateCache(cache: Cache, _partition: String?, subBlockId: String?, title: String?, isPlanting: Bool?, treePerPlot: Int?, secondsPlanted: List<Int>?, treeTypes: List<String>?, centPerTreeTypes: List<Double>?, bundlesPerTreeTypes: List<Int>?, totalCashPerTreeTypes: List<Double>?, totalTreesPerTreeTypes: List<Int>?, bagUpsPerTreeTypes: List<BagUpInput>?, plots: List<PlotInput>?, coordinatesCovered: List<CoordinateInput>?){
        realm!.safeWrite{
            if let parition = _partition{
                cache._partition = parition
            }
            if let subBlockId = subBlockId{
                cache.subBlockId = subBlockId
            }
            if let title = title{
                cache.title = title
            }
            if let isPlanting = isPlanting{
                cache.isPlanting = isPlanting
            }
            if let treePerPlot = treePerPlot{
                cache.treePerPlot = treePerPlot
            }
        }
        if let secondsPlanted = secondsPlanted{
            updateList(list: cache.secondsPlanted, newList: secondsPlanted)
        }
        if let treeTypes = treeTypes{
            updateList(list: cache.treeTypes, newList: treeTypes)
        }
        if let centPerTreeTypes = centPerTreeTypes{
            updateList(list: cache.centPerTreeTypes, newList: centPerTreeTypes)
        }
        if let bundlesPerTreeTypes = bundlesPerTreeTypes{
            updateList(list: cache.bundlesPerTreeTypes, newList: bundlesPerTreeTypes)
        }
        if let totalCashPerTreeTypes = totalCashPerTreeTypes{
            updateList(list: cache.totalCashPerTreeTypes, newList: totalCashPerTreeTypes)
        }
        if let treeTypes = treeTypes{
            updateList(list: cache.treeTypes, newList: treeTypes)
        }
        if let bagUpsPerTreeTypes = bagUpsPerTreeTypes{
            for i in 0..<bagUpsPerTreeTypes.count{
                bagUpsPerTreeTypes[i].input.removeAll()
            }
            updateList(list: cache.bagUpsPerTreeTypes, newList: bagUpsPerTreeTypes)
        }
        if let plots = plots{
            updateList(list: cache.plots, newList: plots)
        }
        if let coordinatesCovered = coordinatesCovered{
            for i in 0..<coordinatesCovered.count{
                coordinatesCovered[i].input.removeAll()
            }
            updateList(list: cache.coordinatesCovered, newList: coordinatesCovered)
        }
    }
    
    public func updateCacheTitle(cache: Cache, title: String){
        realm!.safeWrite{
            cache.title = title
        }
    }
    
    public func updateCacheIsPlanting(cache: Cache, bool: Bool){
        realm!.safeWrite{
            cache.isPlanting = bool
        }
    }
    
    public func updateCacheTreePerPlot(cache: Cache, treesPerPlot: Int){
        realm!.safeWrite{
            cache.treePerPlot = treesPerPlot
        }
    }
    
    public func updateCachePlotInputs(plotArray: List<PlotInput>, row: Int, plotInputOne: Int?, plotInputTwo: Int?){
        realm!.safeWrite{
            if let inputOne = plotInputOne{
                plotArray[row].inputOne = inputOne
            }
            if let inputTwo = plotInputTwo{
                plotArray[row].inputTwo = inputTwo
            }
        }
    }

    //===============LIST================
    
    public func addToList<T>(list: List<T>, item: T){
        realm!.safeWrite{
            list.append(item)
        }
    }
    
    public func updateList<T>(list: List<T>, newList: List<T>){
        realm!.safeWrite{
            list.removeAll()
            for item in newList{
                list.append(item)
            }
        }
    }
    
    public func updateList<T>(list: List<T>, index: Int, item: T){
        realm!.safeWrite{
            list[index] = item
        }
    }
    
    public func clearList<T>(list: List<T>){
        realm!.safeWrite{
            list.removeAll()
        }
    }
    
    public func removeLastInList<T>(list: List<T>){
        realm!.safeWrite{
            list.removeLast()
        }
    }
    
    public func add(item: Object){
        realm!.safeWrite{
            realm!.add(item)
        }
    }
    
    //===============RANDOM================
    
    public func clearCacheTally(cache: Cache, completionHandler: CompletionHandler){
        emptyTallyPrimitiveList(list: cache.treeTypes, appending: "")
        emptyTallyPrimitiveList(list: cache.centPerTreeTypes, appending: 0.0)
        emptyTallyPrimitiveList(list: cache.bundlesPerTreeTypes, appending: 0)
        emptyTallyPrimitiveList(list: cache.totalCashPerTreeTypes, appending: 0.0)
        emptyTallyPrimitiveList(list: cache.totalTreesPerTreeTypes, appending: 0)
        emptyTallyBagUps(list: cache.bagUpsPerTreeTypes)
        emptyTallyPlots(list: cache.plots)
        completionHandler(true)
    }
    
    //Meant for primitive types like : Double, Int, String
    func emptyTallyPrimitiveList<T>(list: List<T>, appending: T){
        realm!.safeWrite{
            list.removeAll()
            for _ in 0..<TallyNumbers.columns{
                list.append(appending)
            }
        }
    }
    
    func emptyTallyBagUps(list: List<BagUpInput>){
        realm!.safeWrite{
            list.removeAll()
        }
        for _ in 0..<TallyNumbers.bagUpRows{
            let bagUpInput = BagUpInput()
            emptyTallyPrimitiveList(list: bagUpInput.input, appending: 0)
            realm!.safeWrite{
                list.append(bagUpInput)
            }
        }
    }

    func emptyTallyPlots(list: List<PlotInput>){
        realm!.safeWrite{
            list.removeAll()
            for _ in 0..<TallyNumbers.bagUpRows{
                list.append(PlotInput())
            }
        }
    }
    
    func emptyCacheCoordinates(list: List<CoordinateInput>){
        realm!.safeWrite{
            for coordinateList in list{
                coordinateList.input.removeAll()
            }
            list.removeAll()
        }
    }
    
}
