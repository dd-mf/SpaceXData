//
//  Favorites.swift
//  Demo
//
//  Created by J.Rodden on 4/13/20.
//  Copyright © 2020 DD/MF & Associates. All rights reserved.
//

import Foundation

class Favorites<Item: Identifiable>: ObservableObject
{
    private let key: String
    private var items: Set<Item.ID>

    var count: Int { return items.count }
    
    init(named name: String)
    {
        key = "favorites-" + name
        items = Set(UserDefaults.standard
            .array(forKey: key) as? [Item.ID] ?? [])
    }

    func add(_ item: Item)
    {
        objectWillChange.send()
        items.insert(item.id)
        save()
    }

    func save()
    {
        UserDefaults.standard
            .setValue(Array(items), forKey: key)
    }
    
    func remove(_ item: Item)
    {
        objectWillChange.send()
        items.remove(item.id)
        save()
    }

    func sort(_ lhs: Item, _ rhs: Item) -> Bool?
    {
        let lhsIsFavorite = contains(lhs)
        let rhsIsFavorite = contains(rhs)
        
        return lhsIsFavorite != rhsIsFavorite ?
            lhsIsFavorite && !rhsIsFavorite : nil
    }
    
    func toggle(_ item: Item) { (!contains(item) ? add : remove)(item) }
    
    func contains(_ item: Item) -> Bool { return items.contains(item.id) }
}
