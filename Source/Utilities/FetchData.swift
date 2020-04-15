//
//  FetchData.swift
//  Demo
//
//  Created by J.Rodden on 4/11/20.
//  Copyright © 2020 DD/MF & Associates. All rights reserved.
//

import Foundation

func localFile(for url: URL) -> URL?
{
    guard let documents =
        FileManager.default.urls(
            for: .documentDirectory,
            in: .userDomainMask).first else { return nil }
    
    let filename = url.path
        .replacingOccurrences(of: "/", with: "-")
    return documents.appendingPathComponent(filename)
}

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
        let file = localFile(for: url)

        func process(_ data: Data?, quiet: Bool = false)
        {
            do
            {
                guard let data =
                    try data ?? ((file == nil) ? nil :
                        Data(contentsOf: file!)) else
                {
                    if !quiet { print("no response from \(url)") }
                    return
                }
                
                try decodeAndStore(data)
                if let localFile = file
                {
                    try data.write(to: localFile,
                                   options: .atomic)
                }
            }
            catch let error
            {
                print("\(error) " + (data == nil ? "" :
                    String(data: data!, encoding: .utf8) ?? "" ))
            }
        }
        
        if let localFile = file
        {   // first try loading from cached file (if it exists)
            do { process(try Data(contentsOf: localFile), quiet: true) } catch { }
        }
        
        URLSession.shared.dataTask(with: url) { data, _, _ in process(data) }.resume()
    }
}
