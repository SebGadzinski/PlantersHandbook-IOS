//
//  RealmDatabase.swift
//  PlantersHandbook
//
//  Created by Sebastian Gadzinski on 2021-01-25.
//

import Foundation
import RealmSwift
typealias CompletionHandler = (_ success:Bool) -> Void
typealias ErrorCompletionHandler = (_ success:Bool, _ error: String?) -> Void

/*
 This should only be used after the connectToRealm funciton has been called.
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
    
    func getSeason(seasonId: String) -> Season?{
        if let season = realm!.objects(Season.self).filter(NSPredicate(format: "_id = %@", seasonId)).first{
            return season
        }else{
            return nil
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
    
    func getHandbookEntry(entryId: String) -> HandbookEntry?{
        if let entry = realm!.objects(HandbookEntry.self).filter(NSPredicate(format: "_id = %@", entryId)).first{
            return entry
        }else{
            return nil
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
    
    func getBlock(blockId: String) -> Block?{
        if let block = realm!.objects(Block.self).filter(NSPredicate(format: "_id = %@", blockId)).first{
            return block
        }else{
            return nil
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
    
    func getSubBlock(subBlockId: String) -> SubBlock?{
        if let subBlock = realm!.objects(SubBlock.self).filter(NSPredicate(format: "_id = %@", subBlockId)).first{
            return subBlock
        }else{
            return nil
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
    
    func getCache(cacheId: String) -> Cache?{
        if let cache = realm!.objects(Cache.self).filter(NSPredicate(format: "_id = %@", cacheId)).first{
            return cache
        }else{
            return nil
        }
    }
    
    //===============_ADD_================
    
    public func addUser(user: User, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite({
            realm!.add(user)
        }){
            completionHandler(false, error)
        }else{
            completionHandler(true, nil)
        }
    }
    
    public func addSeason(user: User, season: Season, completionHandler: ErrorCompletionHandler){
        let allSeasons = realm!.objects(Season.self)
        if allSeasons.contains(where: {$0.title == season.title}){
            completionHandler(false, "Duplicate Season Names")
        }
        else{
            if let error = realm!.safeWrite ({
                user.seasons.append(season._id)
                realm!.add(season)
            }){
                completionHandler(false, error)
            }else{
                completionHandler(true, nil)
            }
        }
    }
    
    public func addEntry(season: Season, entry: HandbookEntry, completionHandler: ErrorCompletionHandler){
        let entryPredicate = NSPredicate(format: "_id IN %@", season.entries)
        let entries = realm!.objects(HandbookEntry.self).filter(entryPredicate)
        if entries.contains(where: {$0.date == entry.date}){
            completionHandler(false, "Duplicate Dates")
        }
        else{
            if let error = realm!.safeWrite ({
                season.entries.append(entry._id)
                realm!.add(entry)
            }){
                completionHandler(false, error)
            }else{
                completionHandler(true, nil)
            }
        }
    }
    
    public func addBlock(entry: HandbookEntry, block: Block, completionHandler: ErrorCompletionHandler){
        let blockPredicate = NSPredicate(format: "_id IN %@", entry.blocks)
        let blocks = realm!.objects(Block.self).filter(blockPredicate)
        if blocks.contains(where: {$0.title == block.title}){
            completionHandler(false, "Duplicate Names")
        }
        else{
            if let error = realm!.safeWrite ({
                entry.blocks.append(block._id)
                realm!.add(block)
            }){
                completionHandler(false, error)
            }else{
                completionHandler(true, nil)
            }
        }
    }
    
    public func addSubBlock(block: Block, subBlock: SubBlock, completionHandler: ErrorCompletionHandler){
        let subBlockPredicate = NSPredicate(format: "_id IN %@", block.subBlocks)
        let subBlocks = realm!.objects(SubBlock.self).filter(subBlockPredicate)
        if subBlocks.contains(where: {$0.title == subBlock.title}){
            completionHandler(false, "Duplicate Names")
        }
        else{
            if let error = realm!.safeWrite ({
                block.subBlocks.append(subBlock._id)
                realm!.add(subBlock)
            }){
                completionHandler(false, error)
            }else{
                completionHandler(true, nil)
            }
        }
    }
    
    public func addCache(subBlock: SubBlock, cache: Cache, completionHandler: ErrorCompletionHandler){
        let cachePredicate = NSPredicate(format: "_id IN %@", subBlock.caches)
        let caches = realm!.objects(Cache.self).filter(cachePredicate)
        if caches.contains(where: {$0.title == cache.title}){
            completionHandler(false, "Duplicate Names")
        }
        else{
            if let error = realm!.safeWrite ({
                subBlock.caches.append(cache._id)
                realm!.add(cache)
            }){
                completionHandler(false, error)
            }else{
                completionHandler(true, nil)
            }
        }
    }
    
    //===============_DELETION_================
    
    func deleteSeason(season: Season, completionHandler: ErrorCompletionHandler) {
        let entryPredicate = NSPredicate(format: "_id IN %@", season.entries)
        let entriesToDelete = realm!.objects(HandbookEntry.self).filter(entryPredicate)
        let seasonId = String(season._id)

        deleteBunchEntrys(entriesToDelete: entriesToDelete, entryCompletionHandler: {(success, error) -> Void in
            if success{
                print("Deleting Season: \(seasonId)")
                if let error = realm!.safeWrite ({
                    realm!.delete(season)
                    print("Season Deleted")
                }){
                    completionHandler(false, error)
                }else{
                    if let user = getLocalUser(){
                        removeItemInList(list: user.seasons, item: seasonId){ success, error in
                            if success{
                                completionHandler(true, nil)
                            }else{
                                print("Season \(seasonId)not found in Users list")
                                completionHandler(false, error!)
                            }
                        }
                    }else{
                        print("User not found")
                        completionHandler(false, "User not found")
                    }
                }
            }
            else{
                print("Season: \(seasonId) Was Not Deleted")
                if let error = error{
                    completionHandler(false, error)
                }
            }
        })
    }

    func deleteEntry(entry: HandbookEntry, completionHandler: ErrorCompletionHandler) {
        let blockPredicate = NSPredicate(format: "_id IN %@", entry.blocks)
        let blocksToDelete = realm!.objects(Block.self).filter(blockPredicate)
        let entryId = String(entry._id)
        if let season = getSeason(seasonId: entry.seasonId){
            deleteBunchBlocks(blocksToDelete: blocksToDelete, blockCompletionHandler: {(success, error) -> Void in
                if success{
                    print("Deleting Entry: \(entryId)")
                    if let error = realm!.safeWrite ({
                        realm!.delete(entry)
                        print("Entry Deleted")
                    }){
                        completionHandler(true, error)
                    }else{
                        removeItemInList(list: season.entries, item: entryId){ success, error in
                            if success{
                                completionHandler(true, nil)
                            }else{
                                completionHandler(true, error!)
                            }
                        }
                    }
                }else{
                    print("Entry: \(entryId) Was Not Deleted")
                    if let error = error{
                        completionHandler(false, error)
                    }
                }
            })
        }else{
            print("Entry Not Deleted, Season Not Found")
            completionHandler(false, "Season \(entry.seasonId)")
        }
    }

    private func deleteBunchEntrys(entriesToDelete: Results<HandbookEntry>, entryCompletionHandler: ErrorCompletionHandler){
        if(!entriesToDelete.isEmpty){
            for aEntry in entriesToDelete{
                let blockPredicate = NSPredicate(format: "_id IN %@", aEntry.blocks)
                let blocksToDelete = realm!.objects(Block.self).filter(blockPredicate)
                let entryId = String(aEntry._id)
                if let season = getSeason(seasonId: aEntry.seasonId){
                    deleteBunchBlocks(blocksToDelete: blocksToDelete, blockCompletionHandler: {(success, error) -> Void in
                        if success{
                            print("Deleting Entry: \(entryId)")
                            if let error = realm!.safeWrite ({
                                realm!.delete(aEntry)
                                print("Entry Deleted")
                            }){
                                entryCompletionHandler(false, "Entry: \(entryId) Was Not Deleted | Linked To: " + error)
                                return
                            }else{
                                removeItemInList(list: season.entries, item: entryId){ success, error in
                                    if success{
                                        entryCompletionHandler(true, nil)
                                    }else{
                                        entryCompletionHandler(false, "Entry: \(entryId) Was Not Deleted | Linked To: " + error!)
                                        return
                                    }
                                }
                            }
                        }
                        else{
                            print("Entry: \(aEntry._id) Was Not Deleted")
                            if let error = error{
                                entryCompletionHandler(false, "Entry: \(entryId) Was Not Deleted | Linked To: " + error)
                            }
                        }
                    })
                }else{
                    entryCompletionHandler(false, "Entry: \(entryId) Was Not Deleted | Could Not Find Season \(aEntry.seasonId)")
                    return
                }
            }
            entryCompletionHandler(true, nil)
        }
        else{
            entryCompletionHandler(true, nil)
        }
    }

    func deleteBlock(block: Block, completionHandler: ErrorCompletionHandler) {
        let subBlockPredicate = NSPredicate(format: "_id IN %@", block.subBlocks)
        let subBlocksToDelete = realm!.objects(SubBlock.self).filter(subBlockPredicate)
        let blockId = String(block._id)
        if let entry = getHandbookEntry(entryId: block.entryId){
            deleteBunchSubBlocks(subBlocksToDelete: subBlocksToDelete, subBlockCompletionHandler: {(success, error) -> Void in
                if success{
                    print("Deletin Block: \(blockId)")
                    if let error = realm!.safeWrite ({
                        realm!.delete(block)
                    }){
                        completionHandler(false, error)
                    }else{
                        print("Block Deleted")
                        removeItemInList(list: entry.blocks, item: blockId){ success, error in
                            if success{
                                completionHandler(true, nil)
                            }else{
                                completionHandler(false, error!)
                            }
                        }
                    }
                }
            })
        }else{
            print("Block: \(block._id) Was Not Deleted")
            completionHandler(false, "Block: \(block._id) Was Not Deleted : Could not find Entry")
        }
    }

    private func deleteBunchBlocks(blocksToDelete: Results<Block>, blockCompletionHandler: ErrorCompletionHandler){
        if(!blocksToDelete.isEmpty){
            for aBlock in blocksToDelete{
                let subBlockPredicate = NSPredicate(format: "_id IN %@", aBlock.subBlocks)
                let subBlocksToDelete = realm!.objects(SubBlock.self).filter(subBlockPredicate)
                let blockId = aBlock._id
                if let entry = getHandbookEntry(entryId: aBlock.entryId){
                    deleteBunchSubBlocks(subBlocksToDelete: subBlocksToDelete,subBlockCompletionHandler: {(success, error) -> Void in
                        if success{
                            print("Deleting Block: \(aBlock._id)")
                            if let error = realm!.safeWrite ({
                                realm!.delete(aBlock)
                                print("Block Deleted")
                            }){
                                blockCompletionHandler(false, "Block: \(blockId) Was Not Deleted | Linked To :" + error)
                                return
                            }else{
                                removeItemInList(list: entry.blocks, item: blockId){ success, error in
                                    if success{

                                    }else{
                                        blockCompletionHandler(false, "Block: \(blockId) Was Not Deleted From Entry List| Linked To :" + error!)
                                        return
                                    }
                                }
                            }
                        }
                    })
                }else{
                    print("Block: \(aBlock._id) Was Not Deleted")
                    blockCompletionHandler(false, "Block: \(blockId) Was Not Deleted : Could not find Entry")
                    return
                }
            }
            blockCompletionHandler(true, nil)
        }
        else{
            blockCompletionHandler(true, nil)
        }
    }

    func deleteSubBlock(subBlock: SubBlock, completionHandler: ErrorCompletionHandler) {
        let cachePredicate = NSPredicate(format: "_id IN %@", subBlock.caches)
        let cachesToDelete = realm!.objects(Cache.self).filter(cachePredicate)
        let subBlockIdString = String(subBlock._id)

        deleteBunchCaches(cachesToDelete: cachesToDelete,  cacheCompletionHandler: {(success, error) -> Void in
            if success{
                print("Deleting SubBlock: \(subBlockIdString)")
                if let block = getBlock(blockId: subBlock.blockId){
                    if let error = realm!.safeWrite({
                        realm!.delete(subBlock)
                        print("SubBlock Deleted")
                    }){
                        completionHandler(false, error)
                        return
                    }else{
                        removeItemInList(list: block.subBlocks, item: subBlockIdString){ success, error in
                            if success{
                                completionHandler(true, nil)
                            }else{
                                print("SubBlock: \(subBlockIdString) Was not found in \(block.title) list")
                                completionHandler(false, error!)
                            }
                        }
                    }
                }
            }
            else{
                print("SubBlock: \(subBlock._id) Was Not Deleted")
                if let error = error{
                    completionHandler(false, error)
                }
            }
        })
    }

    private func deleteBunchSubBlocks(subBlocksToDelete: Results<SubBlock>, subBlockCompletionHandler: ErrorCompletionHandler){
        if(!subBlocksToDelete.isEmpty){
            for aSubBlock in subBlocksToDelete{
                let cachePredicate = NSPredicate(format: "_id IN %@", aSubBlock.caches)
                let cachesToDelete = realm!.objects(Cache.self).filter(cachePredicate)

                deleteBunchCaches(cachesToDelete: cachesToDelete, cacheCompletionHandler: {(success, error) -> Void in
                    if success{
                        if let block = getBlock(blockId: aSubBlock.blockId){
                            let subBlockId = String(aSubBlock._id)
                            print("Deleting SubBlock: \(subBlockId)")
                            if let error = realm!.safeWrite({
                                realm!.delete(aSubBlock)
                                print("SubBlock Deleted")
                            }){
                                subBlockCompletionHandler(false, "SubBlock: \(subBlockId) Was Not Deleted" + error)
                                return
                            }else{
                                removeItemInList(list: block.subBlocks, item: subBlockId){ success, error in
                                    if success{
                                        print("SubBlock deleted from block list")
                                    }else{
                                        print("SubBlock: \(subBlockId) Was not found in \(block.title) list")
                                        subBlockCompletionHandler(false, "SubBlock: \(subBlockId) Was Not Deleted From Block List : " + error!)
                                        return
                                    }
                                }
                            }
                        }else{
                            subBlockCompletionHandler(false, "SubBlock: \(aSubBlock._id) Block was not found" + error!)
                            return
                        }
                    }
                    else{
                        print("SubBlock: \(aSubBlock._id) Was Not Deleted")
                        if let error = error{
                            subBlockCompletionHandler(false, "SubBlock: \(aSubBlock._id) Was Not Deleted | Linked To : " + error)
                        }
                        return
                    }
                })
            }
            subBlockCompletionHandler(true, nil)
        }
        else{
            subBlockCompletionHandler(true, nil)
        }
    }

    func deleteCache(cache: Cache, completionHandler: ErrorCompletionHandler) {
        print("Deleting Cache: \(cache._id)")
        if let subBlock = getSubBlock(subBlockId: cache.subBlockId){
            let cacheId = String(cache._id)
            if let error = realm!.safeWrite({
                for list in cache.bagUpsPerTreeTypes{
                    list.input.removeAll()
                }
                cache.plots.removeAll()
                for list in cache.coordinatesCovered{
                    list.input.removeAll()
                }
                realm!.delete(cache)
                print("Cache Deleted")
                }){
                completionHandler(false, error)
            }else{
                removeItemInList(list: subBlock.caches, item: cacheId){ success, error in
                    if success{
                        print("Cache deleted from subBlock caches list")
                        completionHandler(true, nil)
                    }
                    else{
                        print("Cache: \(cacheId) Was not found in \(subBlock.title) list")
                        completionHandler(false, error!)
                    }
                }
            }
        }else{
            completionHandler(false, "Could not get subblock " + cache.subBlockId)
        }
    }

    private func deleteBunchCaches(cachesToDelete: Results<Cache>, cacheCompletionHandler: ErrorCompletionHandler){
        for cache in cachesToDelete{
            let id = cache._id
            deleteCache(cache: cache){ success, error in
                if let error = error{
                    print("Cache: \(id) Was Not Deleted | Linked To : " + error)
                    cacheCompletionHandler(false, nil)
                }
            }
        }
        cacheCompletionHandler(true, nil)
    }
    
    //===============UPDATE================
    
    public func updateUser(user: User, _partition: String?, name: String?, company: String?, stepDistance: Int?, seasons: List<String>?, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
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
        }){
            completionHandler(false, error)
            return
        }else{
            if let seasons = seasons{
                updateList(list: user.seasons, newList: seasons){ _, error in
                    if error != nil{
                        completionHandler(false, error)
                    }
                }
            }
            completionHandler(true, nil)
        }
    }
    
    public func updateHandbookEntry(entry: HandbookEntry, _partition: String?, seasonId: String?, notes: String?, date: Date?, blocks: List<String>?, extraCash: List<ExtraCash>?, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite({
            if let parition = _partition{
                entry._partition = parition
            }
            if let seasonId = seasonId{
                entry.seasonId = seasonId
            }
            if let notes = notes{
                entry.notes = notes
            }
            if let date = date{
                entry.date = date
            }
        }){
            completionHandler(false, error)
            return
        }else{
            if let blocks = blocks{
                updateList(list: entry.blocks, newList: blocks){ _, error in
                    if error != nil{
                        completionHandler(false, error)
                        return
                    }
                }
            }
            if let extraCash = extraCash{
                updateList(list: entry.extraCash, newList: extraCash){ _, error in
                    if error != nil{
                        completionHandler(false, error)
                        return
                    }
                }
            }
        }
    }
    
    public func updateHandbookExtraCash(extraCashList: List<ExtraCash>, cash: Double?, reason: String?, index: Int, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            if let cash = cash{
                extraCashList[index].cash = cash
            }
            if let reason = reason{
                extraCashList[index].reason = reason
            }
        }){
            completionHandler(false, error)
        }
    }
    
    public func updateBlock(block: Block, _partition: String?, entryId: String?, title: String?, date: Date?, subBlocks: List<String>?, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
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
        }){
            completionHandler(false, error)
        }else{
            if let subBlocks = subBlocks{
                updateList(list: block.subBlocks, newList: subBlocks){ _, error in
                    if error != nil{
                        completionHandler(false, error)
                        return
                    }
                }
            }
            
        }
    }
    
    public func updateSubBlock(subBlock: SubBlock, _partition: String?, blockId: String?, title: String?, date: Date?, caches: List<String>?, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite({
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
        }){
            completionHandler(false, error)
            return
        }
        if let caches = caches{
            updateList(list: subBlock.caches, newList: caches){ _, error in
                if error != nil{
                    completionHandler(false, error)
                    return
                }
            }
        }
    }
    
    public func updateCache(cache: Cache, _partition: String?, subBlockId: String?, title: String?, isPlanting: Bool?, treePerPlot: Int?, secondsPlanted: List<Int>?, treeTypes: List<String>?, centPerTreeTypes: List<Double>?, bundlesPerTreeTypes: List<Int>?, totalCashPerTreeTypes: List<Double>?, totalTreesPerTreeTypes: List<Int>?, bagUpsPerTreeTypes: List<BagUpInput>?, plots: List<PlotInput>?, coordinatesCovered: List<CoordinateInput>?, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
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
        }){
            completionHandler(false, error)
            return
        }else{
            completionHandler(true, nil)
        }
        if let secondsPlanted = secondsPlanted{
            updateList(list: cache.secondsPlanted, newList: secondsPlanted){ _, error in
                if error != nil{
                    completionHandler(false, error)
                    return
                }
            }
        }
        if let treeTypes = treeTypes{
            updateList(list: cache.treeTypes, newList: treeTypes){ _, error in
                if error != nil{
                    completionHandler(false, error)
                    return
                }
            }
        }
        if let centPerTreeTypes = centPerTreeTypes{
            updateList(list: cache.centPerTreeTypes, newList: centPerTreeTypes){ _, error in
                if error != nil{
                    completionHandler(false, error)
                    return
                }
            }
        }
        if let bundlesPerTreeTypes = bundlesPerTreeTypes{
            updateList(list: cache.bundlesPerTreeTypes, newList: bundlesPerTreeTypes){ _, error in
                if error != nil{
                    completionHandler(false, error)
                    return
                }
            }
        }
        if let totalCashPerTreeTypes = totalCashPerTreeTypes{
            updateList(list: cache.totalCashPerTreeTypes, newList: totalCashPerTreeTypes){ _, error in
                if error != nil{
                    completionHandler(false, error)
                    return
                }
            }
        }
        if let treeTypes = treeTypes{
            updateList(list: cache.treeTypes, newList: treeTypes){ _, error in
                if error != nil{
                    completionHandler(false, error)
                    return
                }
            }
        }
        if let bagUpsPerTreeTypes = bagUpsPerTreeTypes{
            for i in 0..<bagUpsPerTreeTypes.count{
                bagUpsPerTreeTypes[i].input.removeAll()
            }
            updateList(list: cache.bagUpsPerTreeTypes, newList: bagUpsPerTreeTypes){ _, error in
                if error != nil{
                    completionHandler(false, error)
                    return
                }
            }
        }
        if let plots = plots{
            updateList(list: cache.plots, newList: plots){ _, error in
                if error != nil{
                    completionHandler(false, error)
                    return
                }
            }
        }
        if let coordinatesCovered = coordinatesCovered{
            for i in 0..<coordinatesCovered.count{
                coordinatesCovered[i].input.removeAll()
            }
            updateList(list: cache.coordinatesCovered, newList: coordinatesCovered){ _, error in
                if error != nil{
                    completionHandler(false, error)
                    return
                }
            }
        }
    }
    
    public func updateCacheTitle(cache: Cache, title: String, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            cache.title = title
        }){
            completionHandler(false, error)
        }else{
            completionHandler(true, nil)
        }
    }
    
    public func updateCacheIsPlanting(cache: Cache, bool: Bool, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            cache.isPlanting = bool
        }){
            completionHandler(false, error)
        }else{
            completionHandler(true, nil)
        }
    }
    
    public func updateCacheTreePerPlot(cache: Cache, treesPerPlot: Int, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            cache.treePerPlot = treesPerPlot
        }){
            completionHandler(false, error)
        }else{
            completionHandler(true, nil)
        }
    }
    
    public func updateCachePlotInputs(plotArray: List<PlotInput>, row: Int, plotInputOne: Int?, plotInputTwo: Int?, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            if let inputOne = plotInputOne{
                plotArray[row].inputOne = inputOne
            }
            if let inputTwo = plotInputTwo{
                plotArray[row].inputTwo = inputTwo
            }
        }){
            completionHandler(false, error)
        }else{
            completionHandler(true, nil)
        }
    }
    
    

    //===============LIST================
    
    public func addToList<T>(list: List<T>, item: T, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            list.append(item)
        }){
            completionHandler(false, error)
        }else{
            completionHandler(true, nil)
        }
    }
    
    public func updateList<T>(list: List<T>, newList: List<T>, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            list.removeAll()
            for item in newList{
                list.append(item)
            }
        }){
            completionHandler(false, error)
        }else{
            completionHandler(true, nil)
        }
    }
    
    public func updateList<T>(list: List<T>, index: Int, item: T, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            list[index] = item
        }){
            completionHandler(false, error)
        }else{
            completionHandler(true, nil)
        }
    }
    
    public func updateList<T>(list: List<T>, copyArray: [T], completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            list.removeAll()
            for item in copyArray{
                list.append(item)
            }
        }){
            completionHandler(false, error)
        }else{
            completionHandler(true, nil)
        }
    }
    
    public func clearList<T>(list: List<T>, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            list.removeAll()
        }){
            completionHandler(false, error)
        }else{
            completionHandler(true, nil)
        }
    }
    
    public func removeLastInList<T>(list: List<T>, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            list.removeLast()
        }){
            completionHandler(false, error)
        }else{
            completionHandler(true, nil)
        }
    }
    
    public func removeItemInList<T>(list: List<T>, index: Int, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            list.remove(at: index)
        }){
            completionHandler(false, error)
        }else{
            completionHandler(true, nil)
        }
    }
    
    public func removeItemInList<T>(list: List<T>, item: T, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            for i in 0..<list.count{
                if list[i] == item{
                    list.remove(at: i)
                    break
                }
            }
        }){
            completionHandler(false, error)
        }else{
            completionHandler(true, nil)
        }
    }
    
    //===============RANDOM================
    
    public func clearCacheTally(cache: Cache, completionHandler: ErrorCompletionHandler){
        emptyTallyPrimitiveList(list: cache.treeTypes, appending: ""){ success, error in
            if success{
                emptyTallyPrimitiveList(list: cache.centPerTreeTypes, appending: 0.0){ success, error in
                    if success{
                        emptyTallyPrimitiveList(list: cache.bundlesPerTreeTypes, appending: 0){ success, error in
                            if success{
                                emptyTallyPrimitiveList(list: cache.totalCashPerTreeTypes, appending: 0.0){ success, error in
                                    if success{
                                        emptyTallyPrimitiveList(list: cache.totalTreesPerTreeTypes, appending: 0){ success, error in
                                            if success{
                                                emptyTallyBagUps(list: cache.bagUpsPerTreeTypes){ success, error in
                                                    if success{
                                                        emptyTallyPlots(list: cache.plots){ success, error in
                                                            if success{
                                                                completionHandler(true, nil)
                                                            }else{
                                                                completionHandler(false, error)
                                                            }
                                                        }
                                                    }else{
                                                        completionHandler(false, error)
                                                    }
                                                }
                                            }else{
                                                completionHandler(false, error)
                                            }
                                        }
                                    }else{
                                        completionHandler(false, error)
                                    }
                                }
                            }else{
                                completionHandler(false, error)
                            }
                        }
                    }else{
                        completionHandler(false, error)
                    }
                }
            }else{
                completionHandler(false, error)
            }
        }
    }
    
    //Meant for primitive types like : Double, Int, String
    func emptyTallyPrimitiveList<T>(list: List<T>, appending: T, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            list.removeAll()
            for _ in 0..<TallyNumbers.columns{
                list.append(appending)
            }
        }){
            completionHandler(false, error)
        }else{
            completionHandler(true, nil)
        }
    }
    
    func emptyTallyBagUps(list: List<BagUpInput>, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            list.removeAll()
        }){
            completionHandler(false, error)
        }else{
            for _ in 0..<TallyNumbers.bagUpRows{
                let bagUpInput = BagUpInput()
                emptyTallyPrimitiveList(list: bagUpInput.input, appending: 0){ success, error in
                    if success{
                        if let finalError = realm!.safeWrite({
                            list.append(bagUpInput)
                        }){
                            completionHandler(false, finalError)
                        }else{
                            completionHandler(true, nil)
                        }
                    }
                }
            }
        }
    }

    func emptyTallyPlots(list: List<PlotInput>, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            list.removeAll()
            for _ in 0..<TallyNumbers.bagUpRows{
                list.append(PlotInput())
            }
        }){
            completionHandler(false, error)
        }else{
            completionHandler(true, nil)
        }
    }
    
    func emptyCacheCoordinates(list: List<CoordinateInput>, completionHandler: ErrorCompletionHandler){
        if let error = realm!.safeWrite ({
            for coordinateList in list{
                coordinateList.input.removeAll()
            }
            list.removeAll()
        }){
            completionHandler(false, error)
        }else{
            completionHandler(true, nil)
        }
    }
}
