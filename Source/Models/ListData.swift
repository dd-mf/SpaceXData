//
//  ListData.swift
//  Demo
//
//  Created by J.Rodden on 4/15/20.
//  Copyright © 2020 DD/MF & Associates. All rights reserved.
//

import Foundation

class ListData<Item: Codable & Identifiable>:
    ObservableObject where Item.ID == Int
{
    typealias Sort = (Item, Item) -> Bool
    var secondarySort: Sort { return { $0.id < $1.id } }
    
    @Published private(set) var items: [Item]?
    
    @Published private(set) var favorites =
        Favorites(named: String(describing: Item.self))
    
    init(from urlString: String)
    {
        fetchData(from: urlString) { self.sortItems($0) }
    }
    
    private func sortItems(_ newItems: [Item]?)
    {
        items = (newItems ?? items)?.sorted
        {   // sort by favorite membership, then by secondarySort
            favorites.sort($0.id, $1.id) ?? secondarySort($0, $1)
        }
    }
}
