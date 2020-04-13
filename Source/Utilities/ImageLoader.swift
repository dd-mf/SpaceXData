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

class ImageLoader: ObservableObject
{
    private let url: URL?
    @Published var image: UIImage?
    private var cancellable: AnyCancellable?

    init(_ url: URL?) { self.url = url }

    convenience init(_ urlString: String) {
        self.init(URL(string: urlString))
    }
    
    deinit { cancellable?.cancel() }

    func load() {
        guard let url = url else { return }
        cancellable = URLSession.shared
            .dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: self)
    }
    
    func cancel() { cancellable?.cancel() }
}

struct AsyncImage: View {
    @ObservedObject private var loader: ImageLoader
    
    init(url: String) { loader = ImageLoader(url) }

    var body: some View {
        image
            .onAppear(perform: loader.load)
            .onDisappear(perform: loader.cancel)
    }
    
    private var image: some View {
        Group {
            if loader.image != nil {
                Image(uiImage: loader.image!)
                    .resizable().aspectRatio(contentMode: .fit)
            }
            else {
                ActivityIndicator(isAnimating:
                    .constant(true), style: .large)
                    .frame(alignment: .center)
            }
        }
    }
}
