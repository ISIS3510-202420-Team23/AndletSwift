//
//  WelcomePageView.swift
//  SwiftApp
//
//  Created by Daniel Arango Cruz on 16/09/24.
//

import SwiftUI

struct WelcomePageView: View {
    @State private var pageIndex = 0
    private let WelcomePages: [Page] = Page.pages
    @StateObject private var authViewModel = AuthenticationViewModel()
    @State var path = NavigationPath()
    var body: some View {
        NavigationStack(path: $path) {
            VStack{
                WelcomeIndividualPageView(pageIndex: $pageIndex, authViewModel: authViewModel, path: $path, pages: WelcomePages)
            }
        }
        .navigationBarBackButtonHidden(true)
        .onAppear{
            print("PATH \(String(describing: path.codable))")
            path.removeLast(path.count)
            
        }
            
            
    }
    func incrementPage(){
        pageIndex += 1
    }
}

#Preview {
    WelcomePageView()
}
