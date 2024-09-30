import SwiftUI

enum FilterSearchOptions {
    case dates
    case prices
    case minutes
}

struct FilterSearchView: View {
    @Binding var show: Bool
    @ObservedObject var offerViewModel: OfferViewModel

    // Estados locales para almacenar temporalmente los valores de los filtros
    @State private var selectedOption: FilterSearchOptions = .dates
    @State private var startDate: Date
    @State private var endDate: Date
    @State private var minPrice: Double
    @State private var maxPrice: Double
    @State private var maxMinutes: Double

    // Custom initializer para inicializar los @State con los valores del ViewModel
    init(show: Binding<Bool>, offerViewModel: OfferViewModel) {
        _show = show
        _startDate = State(initialValue: offerViewModel.startDate)
        _endDate = State(initialValue: offerViewModel.endDate)
        _minPrice = State(initialValue: offerViewModel.minPrice)
        _maxPrice = State(initialValue: offerViewModel.maxPrice)
        _maxMinutes = State(initialValue: offerViewModel.maxMinutesFromCampus)
        self.offerViewModel = offerViewModel
    }

    var body: some View {
        if #available(iOS 16.0, *) {
            VStack {
                // Header con botón de cerrar (x) y botón de aplicar (Apply)
                HStack {
                    Button {
                        withAnimation(.snappy) {
                            show.toggle() // Cerrar vista de filtros
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
                        // Actualizar los filtros en el ViewModel
                        offerViewModel.updateFilters(
                            startDate: startDate,
                            endDate: endDate,
                            minPrice: minPrice,
                            maxPrice: maxPrice,
                            maxMinutes: maxMinutes
                        )

                        // Imprimir los filtros seleccionados en la consola
                        print("Filtros aplicados:")
                        print("Fecha Inicial: \(startDate)")
                        print("Fecha Final: \(endDate)")
                        print("Precio Mínimo: \(minPrice)")
                        print("Precio Máximo: \(maxPrice)")
                        print("Minutos Máximos desde el campus: \(maxMinutes)")

                        withAnimation(.snappy) {
                            show.toggle() // Cerrar vista de filtros al hacer clic en "Apply"
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

                // Sincronizar los valores del ViewModel cada vez que se abra la vista
                .onAppear {
                    loadValuesFromViewModel()
                }
                
                // Sección para seleccionar fechas
                VStack(alignment: .leading) {
                    Text("When?")
                        .font(.custom("LeagueSpartan-SemiBold", size: 28))
                        .fontWeight(.semibold)
                    
                    DatePicker("From", selection: $startDate, in: Date()...,
                               displayedComponents: .date)
                    
                    Divider()
                    
                    DatePicker("To", selection: $endDate, in: (startDate.addingTimeInterval(24 * 60 * 60))..., displayedComponents: .date)
                }
                .padding()
                .frame(height: 180)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding()
                .shadow(radius: 10)
                
                // Sección para seleccionar rango de precios
                VStack(alignment: .leading) {
                    if selectedOption == .prices {
                        Text("Price")
                            .font(.custom("LeagueSpartan-SemiBold", size: 28))
                            .fontWeight(.semibold)
                        
                        Slider(value: $maxPrice, in: 0...10000000, step: 100000)
                            .accentColor(Color(hex: "0C356A"))
                        HStack {
                            Spacer()
                            Text("$\(Int(maxPrice))")
                        }
                        .padding(.horizontal)
                        
                    } else {
                        CollapsedPickedView(title: "Price", description: "Select price")
                    }
                }
                .padding()
                .frame(height: selectedOption == .prices ? 120 : 64)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding()
                .shadow(radius: 10)
                .onTapGesture {
                    withAnimation(.snappy) { selectedOption = .prices }
                }
                
                // Sección para seleccionar minutos desde el campus
                VStack(alignment: .leading) {
                    if selectedOption == .minutes {
                        Text("Minutes from campus")
                            .font(.custom("LeagueSpartan-SemiBold", size: 28))
                            .fontWeight(.semibold)
                        
                        Slider(value: $maxMinutes, in: 0...30, step: 1)
                            .accentColor(Color(hex: "0C356A"))
                        HStack {
                            Spacer()
                            Text("\(Int(maxMinutes)) mins")
                        }
                        .padding(.horizontal)
                        
                    } else {
                        CollapsedPickedView(title: "Minutes from campus", description: "Select minutes")
                    }
                }
                .padding()
                .frame(height: selectedOption == .minutes ? 120 : 64)
                .background(.white)
                .clipShape(RoundedRectangle(cornerRadius: 12))
                .padding()
                .shadow(radius: 10)
                .onTapGesture {
                    withAnimation(.snappy) { selectedOption = .minutes }
                }
                
                Spacer()
            }
            .toolbar(.hidden, for: .tabBar)
        }
    }
    
    // Función para sincronizar los valores del ViewModel con los @State al cargar la vista
    private func loadValuesFromViewModel() {
        startDate = offerViewModel.startDate
        endDate = offerViewModel.endDate
        minPrice = offerViewModel.minPrice
        maxPrice = offerViewModel.maxPrice
        maxMinutes = offerViewModel.maxMinutesFromCampus
    }
}

#Preview {
    FilterSearchView(show: .constant(false), offerViewModel: OfferViewModel())
}

struct CollapsedPickedView: View {
    let title: String
    let description: String
    var body: some View {
        VStack {
            HStack {
                Text(title)
                    .foregroundStyle(.gray)
                Spacer()
                Text(description)
            }
            .font(.subheadline)
        }
    }
}
