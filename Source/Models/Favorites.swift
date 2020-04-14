//
//  Favorites.swift
//  Demo
//
//  Created by J.Rodden on 4/13/20.
//  Copyright © 2020 DD/MF & Associates. All rights reserved.
//

import Foundation

class Favorites: ObservableObject
{
    private let key: String
    private var items: Set<Int>

    init(named name: String)
    {
        key = "favorites-" + name
        items = Set(UserDefaults.standard.array(forKey: key) as? [Int] ?? [])
    }

    func add(_ id: Int)
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
    
    func remove(_ id: Int)
    {
        objectWillChange.send()
        items.remove(id)
        save()
    }

    func sort(_ lhs: Int, _ rhs: Int) -> Bool?
    {
        return contains(lhs) && !contains(rhs) ? true : nil
    }
    
    func toggle(_ id: Int) { (!contains(id) ? add : remove)(id) }
    
    func contains(_ id: Int) -> Bool { return items.contains(id) }
}
