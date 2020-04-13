//
//  FetchData.swift
//  Demo
//
//  Created by J.Rodden on 4/11/20.
//  Copyright © 2020 DD/MF & Associates. All rights reserved.
//

import Foundation

/// fetches json data from specified urlString on
/// a background dispatchQueue, decodes it, and calls closure on same
/// thread initially called from with resulting array of Decodable type
func fetchData<Item: Decodable>(from urlString: String,
                                store: @escaping (Item)->())
{
    guard let currentQueue =
        OperationQueue.current else { return }
    
    fetch(from: urlString)
    {
        let result = try JSONDecoder()
            .decode(Item.self, from: $0)
        
        currentQueue.addOperation { store(result) }
    }
}

/// fetches json data from specified urlString on
/// a background dispatchQueue, decodes it, and calls closure on same
/// thread initially called from with resulting array of Decodable type
func fetchData<Item: Decodable>(from urlString: String,
                                store: @escaping ([Item])->())
{
    guard let currentQueue =
        OperationQueue.current else { return }
    
    fetch(from: urlString)
    {
        let result = try JSONDecoder()
            .decode([Item].self, from: $0)
        
        currentQueue.addOperation { store(result) }
    }
}

fileprivate func fetch(from urlString: String,
                       decodeAndStore: @escaping ((Data) throws -> ()))
{
    guard let url = URL(string: urlString) else { return }
    
    let queue = DispatchQueue(
        label: "fetch from: \(urlString)", qos: .background)
    
    queue.async {
        URLSession.shared.dataTask(with: url)
        {
            data, response, error in
            guard let data = data else {
                return print("no response from \(url)")
            }
            
            do { try decodeAndStore(data) }
            catch let error { print(error) }
        }.resume()
    }
}
