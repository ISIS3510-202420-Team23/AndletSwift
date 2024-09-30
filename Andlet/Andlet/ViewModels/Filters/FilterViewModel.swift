import SwiftUI

class FilterViewModel: ObservableObject {
    @Published var startDate: Date
    @Published var endDate: Date
    @Published var minPrice: Double
    @Published var maxPrice: Double
    @Published var maxMinutes: Double
    @Published var selectedOption: FilterSearchOptions

    init(startDate: Date, endDate: Date, minPrice: Double, maxPrice: Double, maxMinutes: Double, selectedOption: FilterSearchOptions = .dates) {
        self.startDate = startDate
        self.endDate = endDate
        self.minPrice = minPrice
        self.maxPrice = maxPrice
        self.maxMinutes = maxMinutes
        self.selectedOption = selectedOption
    }

    // Actualizar los valores en el FilterViewModel
    func updateFilters(startDate: Date, endDate: Date, minPrice: Double, maxPrice: Double, maxMinutes: Double) {
        self.startDate = startDate
        self.endDate = endDate
        self.minPrice = minPrice
        self.maxPrice = maxPrice
        self.maxMinutes = maxMinutes
    }
}
