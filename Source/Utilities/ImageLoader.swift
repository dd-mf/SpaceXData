//
//  ImageLoader.swift
//  Demo
//
//  Created by J.Rodden on 4/11/20.
//  Copyright © 2020 DD/MF & Associates. All rights reserved.
//

import UIKit
import Combine
import SwiftUI

fileprivate enum ImageCache
{
    static private let cache = NSCache<NSString, UIImage>()
    
    static subscript(_ url: URL) -> UIImage?
    {
        get
        {
            return cache.object(forKey: url.absoluteString as NSString) ??
                UIImage(contentsOfFile: localFile(for: url)?.absoluteString ?? "")
        }
        set
        {
            let file = localFile(for: url)
            let key = url.absoluteString as NSString
            
            if let image = newValue
            {
                cache.setObject(image, forKey: key)
                
                guard let file = file else { return }
                do { try image.pngData()?.write(to: file, options: .atomic) }
                catch let error { print("unable to cache image to file: \(error)") }
            }
            else
            {
                cache.removeObject(forKey: key)
                
                guard let file = file else { return }
                do { try FileManager.default.removeItem(at: file) }
                catch let error { print("unable to remove image file: \(error)") }
            }
        }
    }
}

class ImageLoader: ObservableObject
{
    private let url: URL?
    private(set) var cancel: (()->())?

    static private let queue = DispatchQueue(
        label: "image loader", qos: .background)
    
    @Published private(set) var image: UIImage?
    {
        didSet
        {
            if  let url = url,
                let image = image
            { ImageCache[url] = image }
        }
    }

    init(_ url: URL?) { self.url = url }

    convenience init(_ urlString: String)
    {
        self.init(URL(string: urlString))
    }
    
    deinit { cancel?() }

    func load()
    {
        guard let url = url else { return }
        
        image = ImageCache[url]
        
        if image == nil
        {
            let cancellable = URLSession.shared
                .dataTaskPublisher(for: url)
                .map { UIImage(data: $0.data) }
                .replaceError(with: nil)
                .subscribe(on: Self.queue)
                .receive(on: DispatchQueue.main)
                .assign(to: \.image, on: self)
            
            cancel = { cancellable.cancel() }
        }
    }
}

struct AsyncImage: View
{
    @ObservedObject private var loader: ImageLoader
    
    init(url: String) { loader = ImageLoader(url) }

    var body: some View
    {
        image.resizable()
            .aspectRatio(contentMode: .fit)
            .onAppear(perform: loader.load)
            .onDisappear(perform: loader.cancel)
    }
    
    private var image: Image
    {
        return loader.image == nil ?
            Image(systemName: "photo") :
            Image(uiImage: loader.image!)
    }
}
