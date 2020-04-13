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
    var title: String { get }
    var thumbnailURL: String { get }
}

// MARK: -

struct ContentView: View
{
    @State private var selectedTab = 1
    
    private let tabs: [(String, AnyView)] =
        [("SpaceX Launches", AnyView(ListOfLaunches())),
         ("Photo Viewer", AnyView(ListOfPhotos()))]

    var body: some View
    {
        NavigationView
        {
            VStack
            {
                Picker("", selection: $selectedTab)
                {
                    ForEach(0 ..< tabs.count)
                    {
                        Text(self.tabs[$0].0)//.tag($0)
                    }
                }
                .pickerStyle(SegmentedPickerStyle())

                tabs[selectedTab].1
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
    @ObservedObject var items = LaunchInfo.History()

    var body: some View { List(items.data) { ListCell(item: $0) } }
}

struct ListOfPhotos: View
{
    @ObservedObject var items = Photo.Library()
    
    var body: some View { List(items.info) { ListCell(item: $0) } }
}

struct ListCell: View
{
    var item: ListItem
    
    var body: some View
    {
        HStack
        {
            AsyncImage(url: item.thumbnailURL).frame(maxWidth: 30, maxHeight: 30)
            NavigationLink(destination: DetailView(info:item)) { Text("\(item.title)") }
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
            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .bottomTrailing)
        }
        .navigationBarTitle(Text(photo.title))
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

        var body: some View
        {
            Group
            {
                VStack
                {
                    if album.user != nil && comments.info != nil
                    {
                        UserInfoView(user: album.user!)
                        Text("\(comments.info!.count) Comments")
                    }
                }
                .padding(EdgeInsets(top: 0, leading: 10, bottom: 0, trailing: 10))
            }
            .padding(EdgeInsets(top: 10, leading: 10, bottom: 10, trailing: 10))
            .background(Color.white).opacity(0.75).cornerRadius(3)
            .shadow(radius: 3, x: -3, y: -3)
        }
    }
    
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
}

// MARK: -

struct ActivityIndicator: UIViewRepresentable
{
    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    typealias Context = UIViewRepresentableContext<ActivityIndicator>
    func makeUIView(context: Context) -> UIActivityIndicatorView
    {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: Context)
    {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
}

// MARK: -

struct ContentView_Previews: PreviewProvider
{
    static var previews: some View { ContentView()  }
}
