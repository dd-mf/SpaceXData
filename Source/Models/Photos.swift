//
//  Photos.swift
//  Demo
//
//  Created by J.Rodden on 4/11/20.
//  Copyright © 2020 DD/MF & Associates. All rights reserved.
//

import Foundation

struct Photo: Codable, Identifiable, ListItem
{
    let id: Int
    let url: String
    let title: String
    let albumID: Int
    let thumbnailURL: String
    
    enum CodingKeys: String, CodingKey
    {
        case id, url, title
        case albumID = "albumId"
        case thumbnailURL = "thumbnailUrl"
    }
}

extension Photo
{
    enum API
    {
        var path: String
        {
            switch self
            {
            case .photos: return "photos"
            case .albumInfo(for: let id): return "albums/\(id)"
            case .userInfo(for: let id): return "users/\(id)"
            case .comments(for: let id): return "photos/\(id)/comments"
                
            case .base: return "https://jsonplaceholder.typicode.com"
            }
        }
        
        var urlString: String
        {
            let basePath = API.base.path as NSString
            return basePath.appendingPathComponent(path)
        }
        
        case base, photos, albumInfo(for: Int), userInfo(for: Int), comments(for: Int)
    }
}

extension Photo
{
    final class Library: ListData<Photo>
    {
        init() { super.init(from: API.photos.urlString) }
    }
}

// MARK: -

extension Photo
{
    var album: Album { return Album(albumID) }
    
    final class Album: ObservableObject
    {
        @Published private(set) var user: User?
        @Published private(set) var info: Info?
        {
            didSet
            {
                if let info = info
                {
                    user = User(info.userID)
                }
            }
        }

        struct Info: Codable, Identifiable
        {
            let id: Int
            let userID: Int
            let title: String
            
            enum CodingKeys: String, CodingKey
            {
                case id, title, userID = "userId"
            }
        }
        
        init(_ albumID: Int)
        {
            fetchData(from: API.albumInfo(for: albumID).urlString) { self.info = $0 }
        }
    }
}

// MARK: -

extension Photo
{
    var comments: Comments { return Comments(id) }
    
    final class Comments: ObservableObject
    {
        @Published private(set) var info: [Info]?
        
        struct Info: Codable, Identifiable
        {
            let id: Int
            let postID: Int
            let body: String
            let name: String
            let email: String
            
            enum CodingKeys: String, CodingKey
            {
                case id, body, name, email, postID = "postId"
            }
        }
        
        init(_ photoID: Int)
        {
            fetchData(from: API.comments(for: photoID).urlString) { self.info = $0 }
        }
    }
}

// MARK: -

extension Photo.Album
{
    typealias API = Photo.API
        
    final class User: ObservableObject
    {
        @Published private(set) var info: Info?
        
        struct Info: Codable, Identifiable
        {
            let id: Int
            let name: String
            let email: String
            let phone: String
            let username: String
            let websiteURL: String

            let address: Address
            struct Address: Codable
            {
                let street: String
                let suite: String
                let city: String
                let zipcode: String

                let coordinates: Coordinates
                struct Coordinates: Codable
                {
                    let lat: String
                    let lng: String
                }

                enum CodingKeys: String, CodingKey
                {
                    case street, suite, city, zipcode, coordinates = "geo"
                }
            }
            
            let company: Company
            struct Company: Codable
            {
                let name: String
                let summary: String
                let catchPhrase: String

                enum CodingKeys: String, CodingKey
                {
                    case name, catchPhrase, summary = "bs"
                }
            }

            enum CodingKeys: String, CodingKey
            {
                case id, name, email, phone, username
                case address, company, websiteURL = "website"
            }
        }
        
        init(_ userID: Int)
        {
            fetchData(from: API.userInfo(for: userID).urlString) { self.info = $0 }
        }
    }
}
