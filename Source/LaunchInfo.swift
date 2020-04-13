//
//  Launches.swift
//  Demo
//
//  Created by J.Rodden on 4/8/20.
//  Copyright © 2020 DD/MF & Associates. All rights reserved.
//

import UIKit
import Combine
import Foundation

struct LaunchInfo
{
    let flightNum: Int
    let launchDate: String
    let missionName: String

    let rocketInfo: RocketInfo
    struct RocketInfo: Codable
    {
        let name: String

        enum CodingKeys: String, CodingKey
        {
            case name = "rocket_name"
        }
    }

    let launchSite: LaunchSite
    struct LaunchSite: Codable
    {
        let name: String

        enum CodingKeys: String, CodingKey
        {
            case name = "site_name"
        }
    }
    
    let links: Links
    struct Links: Codable
    {
        let missionPatch: String
        
        enum CodingKeys: String, CodingKey
        {
            case missionPatch = "mission_patch_small"
        }
    }

    var missionPatch: String { return links.missionPatch }
}

extension LaunchInfo: Identifiable
{
    var id: Int { return flightNum }
}

extension LaunchInfo: ListItem
{
    var title: String { return missionName }
    var thumbnailURL: String { return missionPatch }
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
    
    final class History: ObservableObject
    {
        @Published private(set) var data = [LaunchInfo]()
        
        init()
        {
            fetchData(from: API.past.urlString) { self.data = $0 }
        }
    }
}
