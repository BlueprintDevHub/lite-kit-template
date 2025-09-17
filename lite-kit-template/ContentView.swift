//
//  ContentView.swift
//  lite-kit-template
//
//  Created by Alterem on 9/7/25.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            HomeView()
                .tabItem {
                    Image(systemName: "house")
                    Text("首页")
                }
            
            ComponentsView()
                .tabItem {
                    Image(systemName: "swift")
                    Text("组件")
                }
            
            ProfileView()
                .tabItem {
                    Image(systemName: "person.circle")
                    Text("设置")
                }
        }
        .tint(.blue)
    }
}

#Preview {
    ContentView()
}
