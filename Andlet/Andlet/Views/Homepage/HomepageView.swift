import SwiftUI

struct HomepageView: View {
    @State private var showFilterSearchView = false
    @StateObject private var offerViewModel = OfferViewModel()
    @StateObject private var filterViewModel = FilterViewModel(  // Crear una instancia de FilterViewModel
           startDate: Date(),
           endDate: Date().addingTimeInterval(24 * 60 * 60),
           minPrice: 0,
           maxPrice: 10000000,
           maxMinutes: 30
       )

    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                if showFilterSearchView {
                    FilterSearchView(show: $showFilterSearchView, filterViewModel: filterViewModel, offerViewModel: offerViewModel)
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
                        .onAppear {
                            if offerViewModel.filtersApplied {
                                // Llamar a fetchOffersWithFilters si se han aplicado filtros
                                offerViewModel.fetchOffersWithFilters()
                            } else {
                                // Llamar a fetchOffers si no se han aplicado filtros
                                offerViewModel.fetchOffers()
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
