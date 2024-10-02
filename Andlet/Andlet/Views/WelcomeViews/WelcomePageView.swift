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
    var body: some View {
        NavigationStack {
            VStack{
                WelcomeIndividualPageView(pageIndex: $pageIndex, authViewModel: authViewModel, pages: WelcomePages)
            }
        }
        .onAppear{
            print("Entre al welcome Page view")
        }
        .navigationBarBackButtonHidden(true)
            
            
    }
    func incrementPage(){
        pageIndex += 1
    }
}

#Preview {
    WelcomePageView()
}
