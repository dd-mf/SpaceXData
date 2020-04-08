//
//  LaunchInfo.swift
//  SpaceXData
//
//  Created by me on 4/8/20.
//  Copyright © 2020 DD/MF & Associates. All rights reserved.
//

import UIKit
import Combine
import Foundation

struct LaunchInfo: Identifiable
{
    let flightNum: Int
    let launchDate: String
    let missionName: String

    let rocketInfo: RocketInfo
    struct RocketInfo: Codable
    {
        let name: String

        enum CodingKeys:
            String, CodingKey
        {
            case name = "rocket_name"
        }
    }

    let launchSite: LaunchSite
    struct LaunchSite: Codable
    {
        let name: String

        enum CodingKeys:
            String, CodingKey
        {
            case name = "site_name"
        }
    }
    
    let links: Links
    struct Links: Codable
    {
        let missionPatch: String
        
        enum CodingKeys:
            String, CodingKey
        {
            case missionPatch = "mission_patch_small"
        }
    }
    
    var id: Int { return flightNum }
    var missionPatch: String { return links.missionPatch }
}

extension LaunchInfo: Codable
{
    enum CodingKeys: String, CodingKey
    {   // map property to json key
        // (& specify keys we consume)
        case links
        case rocketInfo = "rocket"
        case launchSite = "launch_site"
        case flightNum = "flight_number"
        case missionName = "mission_name"
        case launchDate = "launch_date_utc"
    }
}

extension LaunchInfo: Hashable
{
    var hashValue: Int
    {
        return flightNum.hashValue
    }

    func hash(into hasher: inout Hasher)
    {
        flightNum.hash(into: &hasher)
    }

    static func == (lhs: LaunchInfo,
                    rhs: LaunchInfo) -> Bool
    {
        return lhs.flightNum == rhs.flightNum
    }
}

extension LaunchInfo
{
    enum API
    {
        var path: String
        {
            switch self
            {
            case .all: return "launches"
            case .past: return "launches/past"
            case .next: return "launches/next"
            case .latest: return "launches/latest"
            case .upcoming: return "launches/upcoming"
                
            case .base: return "https://api.spacexdata.com/v3"
            case .launch(let number): return "launches/\(number)"
            }
        }
        
        var urlString: String
        {
            let basePath = API.base.path as NSString
            return basePath.appendingPathComponent(path)
        }
        
        case base, all, past, next, latest, upcoming, launch(number: Int)
    }
}

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
        cancellable = URLSession.shared.dataTaskPublisher(for: url)
            .map { UIImage(data: $0.data) }
            .replaceError(with: nil)
            .receive(on: DispatchQueue.main)
            .assign(to: \.image, on: self)
    }
    
    func cancel() { cancellable?.cancel() }
}

class FetchLaunchInfo: ObservableObject
{
    static let shared = FetchLaunchInfo()

    static let queue = DispatchQueue(
        label: "FetchData", qos: .background)
    
    @Published private(set) var data = [LaunchInfo]()

    private init()
    {
        let urlString = LaunchInfo.API.past.urlString
        guard let url = URL(string: urlString) else { return }

        FetchLaunchInfo.queue.async {
            URLSession.shared.dataTask(with: url)
            {
                data, response, error in
                guard let data = data else { return }
                
                do {
                    let result = try JSONDecoder()
                        .decode([LaunchInfo].self, from: data)
                    
                    DispatchQueue.main.async { self.data = result }
                } catch let error { print(error) }
            }.resume()
        }
    }
}

extension Dictionary where Key == String, Value == UIImage
{
    subscript(unchecked key: Key) -> Value?
    {
        get { return self[key] }
        set { self[key] = newValue }
    }
}
