//
//  ContentView.swift
//  Demo
//
//  Created by J.Rodden on 4/8/20.
//  Copyright © 2020 DD/MF & Associates. All rights reserved.
//

import SwiftUI

protocol ListItem
{
    var id: Int { get }
    var title: String { get }
    var thumbnailURL: String { get }
}

// MARK: -

struct ContentView: View
{
    @State private var selectedTab = Tabs.photos

    enum Tabs: Int, CaseIterable, Identifiable
    {
        case photos, launches
        
        var id: Tabs { self }

        var label: String
        {
            switch self
            {
            case .photos: return "Photo Viewer"
            case .launches: return "SpaceX Launches"
            }
        }
        
        var view: AnyView
        {
            // use cached instance, or create new
            Self.views[self] = Self.views[self] ??
            {
                switch self
                {
                case .photos: return AnyView(ListOfPhotos())
                case .launches: return AnyView(ListOfLaunches())
                }
            }()
            
            return Self.views[self]!
        }
        
        private static var views = [Tabs: AnyView]()
    }
    
    var body: some View
    {
        NavigationView
        {
            VStack
            {
                Picker("", selection: $selectedTab)
                {
                    ForEach(Tabs.allCases)
                    {
                        Text($0.label)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                selectedTab.view
                
                Spacer()
            }

            DetailView()
        }
        .navigationBarHidden(true)
        .navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
}

struct ListOfLaunches: View
{
    init(items: LaunchInfo.History = LaunchInfo.History())
    {
        self.items = items; favorites = items.favorites
    }
    
    @ObservedObject private var favorites: Favorites
    @ObservedObject private var items: LaunchInfo.History

    var body: some View
    {
        VStack
        {
            if items.info == nil
            {
                Text("No Items Available")
            }
            else
            {
                List(items.info!, rowContent: ListCell.init)
            }
        }
        .environmentObject(favorites)
    }
}

struct ListOfPhotos: View
{
    @ObservedObject private var items: Photo.Library
    @ObservedObject private var favorites: Favorites
    
    init(items: Photo.Library = Photo.Library())
    {
        self.items = items
        favorites = items.favorites
    }
    
    var body: some View
    {
        VStack
        {
            if items.info == nil
            {
                Text("No Items Available")
            }
            else
            {
                List(items.info!, rowContent: ListCell.init)
            }
        }
        .environmentObject(favorites)
    }
}

struct ListCell: View
{
    var item: ListItem
    
    var body: some View
    {
        HStack
        {
            AsyncImage(url: item.thumbnailURL).frame(maxWidth: 30, maxHeight: 30)
            NavigationLink(destination: DetailView(info:item))
            {
                // workaround vertical alignment issue
                VStack(alignment: .leading)
                {
                    Text("\(item.title)")
                }
                .layoutPriority(1)
                
                FavoriteMarker(id: item.id)
            }
        }
    }
}

struct FavoriteMarker: View
{
    var id: Int
    
    @EnvironmentObject var favorites: Favorites
    var isFavorite: Bool { return favorites.contains(id) }

    var body: some View
    {
        Group
        {
            if isFavorite
            {
                Spacer()
                Image(systemName: "heart.fill")
                    .accessibility(label: Text("This is a favorite item"))
            }
        }
    }
}

struct DetailView: View
{
    var info: ListItem?
    
    var body: some View
    {
        if let info = info as? Photo
        {
            return AnyView(PhotoDetailView(photo: info))
        }
        if let info = info as? LaunchInfo
        {
            return AnyView(LaunchDetailView(launchInfo: info))
        }
        return AnyView(Text("Select an item from the list on left (swipe if not visible)"))
    }
}

struct FavoritButton: View
{
    let id: Int
    
    @EnvironmentObject var favorites: Favorites
    var isOn: Bool { return favorites.contains(id) }

    var body: some View
    {
        Button(action: { self.favorites.toggle(self.id) })
        {
            Image(systemName: "heart" + (!isOn ? "" : ".fill"))
        }
    }
}

// MARK: -

struct LaunchDetailView: View
{
    var launchInfo: LaunchInfo
    
    var body: some View
    {
        VStack
        {
            AsyncImage(url: launchInfo.missionPatch).frame(maxHeight: 200)
            Text("Rocket: \(launchInfo.rocketInfo.name)")
            Text("Launched from \(launchInfo.launchSite.name)")
            Text("on \(launchInfo.launchDate)")
        }
        .navigationBarTitle(Text(launchInfo.missionName))
        .navigationBarItems(trailing: FavoritButton(id: launchInfo.id))
    }
}

// MARK: -

struct PhotoDetailView: View
{
    var photo: Photo
    
    var body: some View
    {
        ZStack
        {
            AsyncImage(url: photo.url)
            
            Group { ImageInfoView(for: photo) }
            .frame(maxWidth: .infinity, maxHeight:
                .infinity, alignment: .bottomTrailing)
        }
        .navigationBarTitle(Text(photo.title))
        .navigationBarItems(trailing: FavoritButton(id: photo.id))
    }

    struct ImageInfoView: View
    {
        init(for photo: Photo)
        {
            album = photo.album
            comments = photo.comments
        }
        
        @ObservedObject var album: Photo.Album
        @ObservedObject var comments: Photo.Comments
        
        struct UserInfoView: View
        {
            @ObservedObject var user: Photo.Album.User
            
            var body: some View
            {
                Group
                {
                    if user.info != nil
                    {
                        Text(user.info!.name)
                        Text(user.info!.email)
                        Text(user.info!.websiteURL)
                    }
                }
            }
        }

        var body: some View
        {
            Group
            {
                if album.user != nil && comments.info != nil
                {
                    Group
                    {
                        VStack
                        {
                            UserInfoView(user: album.user!)
                            Text("\(comments.info!.count) Comments")
                        }
                        .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
                    }
                    .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
                    .background(Color.white).opacity(0.75).cornerRadius(3)
                    .shadow(radius: 3, x: -3, y: -3)
                }
            }
        }
    }
}

// MARK: -

struct ContentView_Previews: PreviewProvider
{
    static var previews: some View { ContentView()  }
}
