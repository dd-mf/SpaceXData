//
//  Favorites.swift
//  Demo
//
//  Created by J.Rodden on 4/13/20.
//  Copyright © 2020 DD/MF & Associates. All rights reserved.
//

import Foundation

class Favorites<ID: Hashable>: ObservableObject
{
    private let key: String
    private var items: Set<ID>

    var count: Int { return items.count }
    
    init(named name: String)
    {
        key = "favorites-" + name
        items = Set(UserDefaults.standard
            .array(forKey: key) as? [ID] ?? [])
    }

    func add(_ id: ID)
    {
        objectWillChange.send()
        items.insert(id)
        save()
    }

    func save()
    {
        UserDefaults.standard
            .setValue(Array(items), forKey: key)
    }
    
    func remove(_ id: ID)
    {
        objectWillChange.send()
        items.remove(id)
        save()
    }

    func sort(_ lhs: ID, _ rhs: ID) -> Bool?
    {
        let lhsIsFavorite = contains(lhs)
        let rhsIsFavorite = contains(rhs)
        
        return lhsIsFavorite != rhsIsFavorite ?
            lhsIsFavorite && !rhsIsFavorite : nil
    }
    
    func toggle(_ id: ID) { (!contains(id) ? add : remove)(id) }
    
    func contains(_ id: ID) -> Bool { return items.contains(id) }
}
