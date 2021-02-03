//
//  RealmDatabase.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-25.
//

import Foundation
import RealmSwift
typealias CompletionHandler = (_ success:Bool) -> Void

struct RealmDatabase{
    private var realm : Realm?
    private var partitionValue: String?
    
    public mutating func connectToRealm(realm: Realm){
        self.realm = realm
        guard let syncConfiguration = realm.configuration.syncConfiguration else {
            fatalError("Sync configuration not found! Realm not opened with sync?");
        }
        self.partitionValue = syncConfiguration.partitionValue!.stringValue!
        
    }
    
    //===============GET================
    
    func getLocalUser() -> User?{
        let users = realm!.objects(User.self).filter(NSPredicate(format: "_id = %@", app.currentUser!.id))
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
                try! realm!.write {
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
                try! realm!.write {
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
                        try! realm!.write {
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
                try! realm!.write {
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
                        try! realm!.write {
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
                try! realm!.write {
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
                        try! realm!.write {
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
        try! realm!.write {
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
    
    public func updateUser(user: User, _partition: String?, name: String?, company: String?, seasons: List<String>?){
        try! realm!.write{
            if let parition = _partition{
                user._partition = parition
            }
            if let name = name{
                user.name = name
            }
            if let company = company{
                user.company = company
            }
            if let seasons = seasons{
                updateList(list: user.seasons, newList: seasons)
            }
        }
    }
    
    public func updateCacheIsPlanting(cache: Cache, bool: Bool){
        try! realm!.write{
            cache.isPlanting = bool
        }
    }
    
    public func updateCacheTreePerPlot(cache: Cache, treesPerPlot: Int){
        try! realm!.write{
            cache.treePerPlot = treesPerPlot
        }
    }
    
    public func updateCachePlotInputs(plotArray: List<PlotInput>, row: Int, plotInputOne: Int?, plotInputTwo: Int?){
        try! realm!.write{
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
        try! realm!.write{
            list.append(item)
        }
    }
    
    public func updateList<T>(list: List<T>, newList: List<T>){
        try! realm!.write{
            list.removeAll()
            for item in newList{
                list.append(item)
            }
        }
    }
    
    public func updateList<T>(list: List<T>, index: Int, item: T){
        try! realm!.write{
            list[index] = item
        }
    }
    
    public func clearList<T>(list: List<T>){
        try! realm!.write{
            list.removeAll()
        }
    }
    
    public func removeLastInList<T>(list: List<T>){
        try! realm!.write{
            list.removeLast()
        }
    }
    
    public func add(item: Object){
        try! realm!.write{
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
        try! realm!.write{
            list.removeAll()
            for _ in 0..<TallyNumbers.columns{
                list.append(appending)
            }
        }
    }
    
    func emptyTallyBagUps(list: List<BagUpInput>){
        try! realm!.write{
            list.removeAll()
        }
        for _ in 0..<TallyNumbers.bagUpRows{
            let bagUpInput = BagUpInput()
            emptyTallyPrimitiveList(list: bagUpInput.input, appending: 0)
            try! realm!.write{
                list.append(bagUpInput)
            }
        }
    }

    func emptyTallyPlots(list: List<PlotInput>){
        try! realm!.write{
            list.removeAll()
            for _ in 0..<TallyNumbers.bagUpRows{
                list.append(PlotInput())
            }
        }
    }
    
    func emptyCacheCoordinates(list: List<CoordinateInput>){
        try! realm!.write{
            for coordinateList in list{
                coordinateList.input.removeAll()
            }
            list.removeAll()
        }
    }
    
}
