//
//  MainTabLandlordView.swift
//  SwiftApp
//
//  Created by Sofía Torres Ramírez on 19/09/24.
//

import SwiftUI


struct MainTabLandlordView: View {
    @Binding var path: NavigationPath
    
    var body: some View {
        TabView {
            HomepageRentView(path: $path)
                .tabItem {
                    Label("Explore", systemImage: "location.fill"
                        )
                    .foregroundStyle(Color(hex: "0C356A"))
                }
            
        }
        .accentColor(Color(hex: "0C356A"))
        .onAppear{
            UITabBar.appearance().backgroundColor = UIColor.white
            UITabBar.appearance().shadowImage = UIImage()
            UITabBar.appearance().backgroundImage = UIImage()
            
        }
    }
}
