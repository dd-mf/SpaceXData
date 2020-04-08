//
//  ContentView.swift
//  SpaceXData
//
//  Created by me on 4/8/20.
//  Copyright © 2020 DD/MF & Associates. All rights reserved.
//

import SwiftUI

private let dateFormatter: DateFormatter = {
    let dateFormatter = DateFormatter()
    dateFormatter.dateStyle = .medium
    dateFormatter.timeStyle = .medium
    return dateFormatter
}()

struct ContentView: View {

    var body: some View {
        NavigationView {
            MasterView()
                .navigationBarTitle(Text("Master"))
            DetailView()
        }.navigationViewStyle(DoubleColumnNavigationViewStyle())
    }
}

struct MasterView: View {
    @ObservedObject var launchInfo = FetchLaunchInfo.shared

    var body: some View {
        List(launchInfo.data) {
            launchInfo in
            NavigationLink(destination:
                DetailView(launchInfo: launchInfo))
            {
                Text("\(launchInfo.missionName)")
            }
        }
    }
}

struct DetailView: View {
    var launchInfo: LaunchInfo?
    
    var introText: String
    {
        return "Select a mission from the left to see the details for that launch\n"
            + "(swipe from the left to see list of missions if they aren't visible)"
    }
    
    var body: some View {
        Group {
            if launchInfo != nil {
                VStack {
                    AsyncImage(url: launchInfo!.missionPatch)
                    Text("Rocket: \(launchInfo!.rocketInfo.name)")
                    Text("Launched from \(launchInfo!.launchSite.name)")
                    Text("on \(launchInfo!.launchDate)")
                }
            } else {
                Text(introText).multilineTextAlignment(.center)
            }
        }.navigationBarTitle(Text("\(launchInfo?.missionName ?? "SpaceX Missions")"))
    }
}

struct ActivityIndicator: UIViewRepresentable {

    @Binding var isAnimating: Bool
    let style: UIActivityIndicatorView.Style

    typealias Context = UIViewRepresentableContext<ActivityIndicator>
    func makeUIView(context: Context) -> UIActivityIndicatorView {
        return UIActivityIndicatorView(style: style)
    }

    func updateUIView(_ uiView: UIActivityIndicatorView, context: UIViewRepresentableContext<ActivityIndicator>) {
        isAnimating ? uiView.startAnimating() : uiView.stopAnimating()
    }
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
            }
            else
            {
                ActivityIndicator(isAnimating: .constant(true), style: .large)
            }
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View { ContentView()  }
}
