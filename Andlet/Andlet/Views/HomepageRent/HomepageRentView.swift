//
//  HomepageTestsView.swift
//  SwiftApp
//
//  Created by Sofía Torres Ramírez on 17/09/24.
//

import SwiftUI
import FirebaseAuth

struct HomepageRentView: View {
    @State private var showFilterSearchView = false
    @StateObject private var viewModel = OfferRentViewModel()
    let currentUser = Auth.auth().currentUser
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
                                        .onAppear {
                                                    print("Oferta: \(offerWithProperty.offer)")
                                                    print("Propiedad: \(offerWithProperty.property)")
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
                print("HomepageRentView appeared - Fetching offers for \(currentUser?.email ?? "Unknown") ...")
                viewModel.fetchOffers(for: "\(currentUser?.email ?? "Unknown")")
                
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
