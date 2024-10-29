import SwiftUI

struct SearchAndFilterBar: View {
    @ObservedObject var filterViewModel: FilterViewModel
    @ObservedObject var offerViewModel: OfferViewModel

    
    var body: some View {
        VStack(spacing: 8) {
            // Search bar
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(Color(hex: "0C356A"))
                
                VStack(alignment: .leading, spacing: 2){
                    Text ("")
                        .font(.caption2)
                        .foregroundStyle(.gray)
                }
                Spacer()
                
                Image(systemName: !filterViewModel.filtersApplied ? "line.horizontal.3" : "text.badge.xmark")
                                    .foregroundStyle(Color(hex: "0C356A"))
                                    .onTapGesture {
                                        if filterViewModel.filtersApplied {
                                            filterViewModel.clearFilters()
                                            offerViewModel.fetchOffers()
                                        }
                                    }
            }
            .padding(.horizontal)
            .padding(.vertical, 11)
            .background(Color(hex: "C5DDFF"))
            .cornerRadius(10)
            .overlay {
                Capsule()
                    .stroke(lineWidth: 0)
            }
            .padding(.horizontal)
            .padding(.top, 4)
            
            // Filter tags section
            if filterViewModel.filtersApplied {
                            VStack(spacing: 8) {
                                HStack(spacing: 8) {                            
                                    if filterViewModel.maxPrice < 10000000 {
                                        FilterTagView(text: "Price: $\(Int(filterViewModel.maxPrice))")
                                    }
                                    if filterViewModel.maxMinutes > 0 {
                                        FilterTagView(text: "Minutes: \(Int(filterViewModel.maxMinutes))")
                                    }
                                }
                                
                                if filterViewModel.startDate != Date() || filterViewModel.endDate != Date().addingTimeInterval(24 * 60 * 60) {
                                    HStack {
                                        FilterTagView(text: "Date: \(formattedDateRange())")
                                    }
                                }
                            }
                            .padding(.horizontal)
                            .transition(.opacity)
                        }
        }
    }
    
    // Helper function to format date range
    private func formattedDateRange() -> String {
        print("Entre aqui de alguna forma EPAAAAAAA")
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let startDate = dateFormatter.string(from: filterViewModel.startDate)
        let endDate = dateFormatter.string(from: filterViewModel.endDate)
        return "\(startDate) - \(endDate)"
    }
}

// Custom view for displaying filter tags
struct FilterTagView: View {
    let text: String
    
    var body: some View {
        Text(text)
            .font(.caption)
            .padding(.horizontal, 8)
            .padding(.vertical, 4)
            .background(Color(hex: "C5DDFF"))
            .cornerRadius(8)
            .foregroundColor(.black)
    }
}
