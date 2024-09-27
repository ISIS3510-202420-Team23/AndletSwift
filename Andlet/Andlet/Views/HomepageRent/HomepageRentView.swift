//
//  HomepageTestsView.swift
//  SwiftApp
//
//  Created by Sofía Torres Ramírez on 17/09/24.
//

import SwiftUI

struct HomepageRentView: View {
    @State private var showFilterSearchView = false
    @StateObject private var viewModel = OfferRentViewModel()
    var body: some View{
        
        if #available(iOS 16.0, *) {
            NavigationStack {
                if showFilterSearchView{
                    FilterSearchView(show: $showFilterSearchView)
                } else {
                    ScrollView {
                        VStack {
                            Heading()
                            SearchAndFilterBar()
                            
                                .onTapGesture {
                                    withAnimation(.snappy){
                                        showFilterSearchView.toggle()
                                    }
                                }
                            CreateMoreButton()
                            //                            LazyVStack (spacing: 32){
                            //                                ForEach(0 ... 10, id: \.self) { listing in
                            //                                    NavigationLink(value: listing){
                            //                                        OfferRentView()
                            //                                            .frame(height: 360)
                            //                                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            //                                    }
                            //
                            //                                }
                            //                            }
                            // Comprobar si hay ofertas del landlord disponibles
                            if viewModel.offersWithProperties.isEmpty {
                                Text("No offers available")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                LazyVStack(spacing: 32) {
                                    ForEach(viewModel.offersWithProperties) { offerWithProperty in
                                        NavigationLink(value: offerWithProperty) {
                                            OfferRentView(offer: offerWithProperty.offer, property: offerWithProperty.property)
                                                .frame(height: 360)
                                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                        }
                                    }
                                }
                                .padding()
                            }
                        }
                    }
                }
            }
            .onAppear {
                print("HomepageRentView appeared - Fetching offers for tamaiothais@gmail.com")
                viewModel.fetchOffers(for: "tamaiothais@gmail.com")
            }
            .navigationBarHidden(true)
        } else {
            // Fallback en versiones anteriores
        }
    }
}
//#Preview {
//    HomepageRentView()
//}
