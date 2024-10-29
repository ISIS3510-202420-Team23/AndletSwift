import SwiftUI
import FirebaseAnalytics

class FilterViewModel: ObservableObject {
    @AppStorage("filterStartDate") private var storedStartDate: Double = Date().timeIntervalSince1970
    @AppStorage("filterEndDate") private var storedEndDate: Double = Date().addingTimeInterval(24 * 60 * 60).timeIntervalSince1970
    @AppStorage("filterMinPrice") var minPrice: Double = 0
    @AppStorage("filterMaxPrice") var maxPrice: Double = 10000000
    @AppStorage("filterMaxMinutes") var maxMinutes: Double = 30
    @AppStorage("filtersApplied") var filtersApplied: Bool = false
    @Published var selectedOption: FilterSearchOptions = .dates

    var startDate: Date {
        get { Date(timeIntervalSince1970: storedStartDate) }
        set {
            storedStartDate = newValue.timeIntervalSince1970
            print("Updated startDate in AppStorage:", newValue)  // Agregar print
        }
    }
    
    var endDate: Date {
        get { Date(timeIntervalSince1970: storedEndDate) }
        set {
            storedEndDate = newValue.timeIntervalSince1970
            print("Updated endDate in AppStorage:", newValue)  // Agregar print
        }
    }

    init() {}

    func updateFilters(startDate: Date, endDate: Date, minPrice: Double, maxPrice: Double, maxMinutes: Double) {
        print("Updating filters in FilterViewModel with values:")
        print("Start Date:", startDate)
        print("End Date:", endDate)
        print("Min Price:", minPrice)
        print("Max Price:", maxPrice)
        print("Max Minutes:", maxMinutes)

        self.startDate = startDate
        self.endDate = endDate
        self.minPrice = minPrice
        self.maxPrice = maxPrice
        self.maxMinutes = maxMinutes
        self.filtersApplied = true
        print("Filters updated successfully. filtersApplied:", filtersApplied)
    }
    
    func clearFilters() {
        self.startDate = Date()
        self.endDate = Date().addingTimeInterval(24 * 60 * 60)
        self.minPrice = 0
        self.maxPrice = 10000000
        self.maxMinutes = 30
        self.filtersApplied = false
        print("Filters cleared.")
    }
}
