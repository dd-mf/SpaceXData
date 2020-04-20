//
//  ListData.swift
//  Demo
//
//  Created by J.Rodden on 4/15/20.
//  Copyright © 2020 DD/MF & Associates. All rights reserved.
//

import Combine
import Foundation

fileprivate let liveSorting = true

class ListData<Item: Codable & Identifiable>:
    ObservableObject where Item.ID == Int
{
    private var needsSorting = false
    private var observer: AnyCancellable?
    
    typealias Sort = (Item, Item) -> Bool
    var secondarySort: Sort { return { $0.id < $1.id } }
    
    @Published private(set) var items: [Item]?
    
    @Published private(set) var favorites =
        Favorites<Item>(named: String(describing: Item.self))
    
    init(from urlString: String)
    {
        observer = favorites.objectWillChange.sink
        {
            [weak self] _ in self?.needsSorting = true
            
            guard liveSorting else { return }
            OperationQueue.main.addOperation
            {
                [weak self] in
                if let this = self, let items = this.items
                {
                    this.items = this.sorted(items: items)
                }
            }
        }
        
        fetchData(from: urlString) { self.items = self.sorted(items: $0) }
    }
    
    func sortItems()
    {
        if  needsSorting,
            let items = items
        {
            needsSorting = false
            self.items = sorted(items: items)
        }
    }
    
    private func sorted(items: [Item]) -> [Item]
    {
        return items.sorted
        {   // sort favorites first, then by secondarySort
            favorites.sort($0, $1) ?? secondarySort($0, $1)
        }
    }
}
