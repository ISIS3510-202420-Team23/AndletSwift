//
//  FilterSearchSavedView.swift
//  Andlet
//
//  Created by Daniel Arango Cruz on 27/11/24.
//

import SwiftUI

struct FilterSearchSavedView: View {
    @Binding var show: Bool
    @ObservedObject var filterViewModel: FilterViewModel
    @ObservedObject var offerViewModel: SavedOffersViewModel

    @State private var localStartDate: Date
    @State private var localEndDate: Date
    @State private var localMinPrice: Double
    @State private var localMaxPrice: Double
    @State private var localMaxMinutes: Double

    init(show: Binding<Bool>, filterViewModel: FilterViewModel, offerViewModel: SavedOffersViewModel) {
        _show = show
        _localStartDate = State(initialValue: filterViewModel.startDate)
        _localEndDate = State(initialValue: filterViewModel.endDate)
        _localMinPrice = State(initialValue: filterViewModel.minPrice)
        _localMaxPrice = State(initialValue: filterViewModel.maxPrice)
        _localMaxMinutes = State(initialValue: filterViewModel.maxMinutes)
        self.filterViewModel = filterViewModel
        self.offerViewModel = offerViewModel
    }

    var body: some View {
        if #available(iOS 16.0, *) {
            VStack {
                HStack {
                    Button {
                        withAnimation(.snappy) {
                            show.toggle()
                        }
                    } label: {
                        Image(systemName: "xmark")
                            .foregroundStyle(Color(hex: "FFF4CF"))
                            .background {
                                Circle()
                                    .fill(Color(hex: "0C356A"))
                                    .frame(width: 40, height: 40)
                            }
                    }
                    
                    Spacer()
                    
                    Button(action: {
                        filterViewModel.updateFilters(
                            startDate: localStartDate,
                            endDate: localEndDate,
                            minPrice: localMinPrice,
                            maxPrice: localMaxPrice,
                            maxMinutes: localMaxMinutes
                        )

                        offerViewModel.fetchOffersWithFilters()
                        withAnimation(.snappy) {
                            show.toggle()
                        }
                    }) {
                        Text("Apply")
                            .font(.custom("LeagueSpartan-SemiBold", size: 18))
                            .foregroundColor(.white)
                            .frame(width: 80, height: 40)
                            .background(Color(hex: "0C356A"))
                            .cornerRadius(20)
                    }
                }
                .padding()
                .padding(.horizontal)
                .padding(.top, 55)
                .onAppear {
                    loadValuesFromViewModel()
                }

                VStack(alignment: .leading) {
                    Text("When?")
                        .font(.custom("LeagueSpartan-SemiBold", size: 28))
                        .fontWeight(.semibold)
                    
                    DatePicker("From", selection: $localStartDate, in: Date()...,
                               displayedComponents: .date)
                    
                    Divider()
                    
                    DatePicker("To", selection: $localEndDate, in: (localStartDate.addingTimeInterval(24 * 60 * 60))..., displayedComponents: .date)
                }
                .padding()
                .frame(height: 180)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding()
                .shadow(radius: 10)
                
                VStack(alignment: .leading) {
                    Text("Price")
                        .font(.custom("LeagueSpartan-SemiBold", size: 28))
                        .fontWeight(.semibold)
                    
                    Slider(value: $localMaxPrice, in: 0...10000000, step: 100000)
                        .accentColor(Color(hex: "0C356A"))
                    HStack {
                        Spacer()
                        Text("$\(Int(localMaxPrice))")
                    }
                    .padding(.horizontal)
                }
                .padding()
                .frame(height: 120)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding()
                .shadow(radius: 10)

                VStack(alignment: .leading) {
                    Text("Minutes from campus")
                        .font(.custom("LeagueSpartan-SemiBold", size: 28))
                        .fontWeight(.semibold)
                    
                    Slider(value: $localMaxMinutes, in: 0...30, step: 1)
                        .accentColor(Color(hex: "0C356A"))
                    HStack {
                        Spacer()
                        Text("\(Int(localMaxMinutes)) mins")
                    }
                    .padding(.horizontal)
                }
                .padding()
                .frame(height: 120)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding()
                .shadow(radius: 10)

                Spacer()

                Text("To remove selected filters after applying them, simply shake your phone.")
                    .font(.custom("LeagueSpartan-Light", size: 12))
                    .foregroundColor(Color(hex: "0C356A"))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal)
                    .padding(.bottom, 45)
            }
            .toolbar(.hidden, for: .tabBar)
        }
    }
    
    private func loadValuesFromViewModel() {
        localStartDate = filterViewModel.startDate
        localEndDate = filterViewModel.endDate
        localMinPrice = filterViewModel.minPrice
        localMaxPrice = filterViewModel.maxPrice
        localMaxMinutes = filterViewModel.maxMinutes
    }
}
