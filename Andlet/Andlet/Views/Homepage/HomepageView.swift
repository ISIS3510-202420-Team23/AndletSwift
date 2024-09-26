//
//  HomepageTestsView.swift
//  SwiftApp
//
//  Created by Sofía Torres Ramírez on 16/09/24.
//

import SwiftUI

struct HomepageView: View {
    @State private var showFilterSearchView = false
    @StateObject private var offerViewModel = OfferViewModel()

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                if showFilterSearchView {
                    FilterSearchView(show: $showFilterSearchView)
                } else {
                    ScrollView {
                        VStack {
                            Heading()
                            SearchAndFilterBar()
                                .onTapGesture {
                                    withAnimation(.snappy) {
                                        showFilterSearchView.toggle()
                                    }
                                }
                            
                            if offerViewModel.offersWithProperties.isEmpty {
                                Text("No offers available")
                                    .font(.headline)
                                    .foregroundColor(.gray)
                                    .padding()
                            } else {
                                LazyVStack(spacing: 32) {
                                    ForEach(offerViewModel.offersWithProperties) { offerWithProperty in
                                        NavigationLink(value: offerWithProperty) {  // Aquí pasamos OfferWithProperty
                                            OfferView(offer: offerWithProperty.offer, property: offerWithProperty.property)
                                                .frame(height: 330)
                                                .clipShape(RoundedRectangle(cornerRadius: 30))
                                        }
                                    }
                                }
                                .padding()
                            }
                        }
                        // Cambia el tipo que pasas al `navigationDestination` a `OfferWithProperty`
                        .navigationDestination(for: OfferWithProperty.self) { offerWithProperty in
                            OfferDetailView(offer: offerWithProperty.offer, property: offerWithProperty.property)
                                .navigationBarBackButtonHidden()
                        }
                    }
                }
            }
        } else {
            Text("Versión de iOS no soportada")
        }
    }
}
