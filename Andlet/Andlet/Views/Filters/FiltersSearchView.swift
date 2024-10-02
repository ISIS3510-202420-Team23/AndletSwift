import SwiftUI
import FirebaseAuth
import FirebaseFirestore

struct FilterSearchView: View {
    @Binding var show: Bool
    @ObservedObject var filterViewModel: FilterViewModel
    @ObservedObject var offerViewModel: OfferViewModel

    // Variables locales para manejar temporalmente los valores de los filtros
    @State private var localStartDate: Date
    @State private var localEndDate: Date
    @State private var localMinPrice: Double
    @State private var localMaxPrice: Double
    @State private var localMaxMinutes: Double
    @State private var selectedOption: FilterSearchOptions = .dates

    // Custom initializer para inicializar las variables locales con los valores del ViewModel
    init(show: Binding<Bool>, filterViewModel: FilterViewModel, offerViewModel: OfferViewModel) {
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
                // Header con botón de cerrar (x) y botón de aplicar (Apply)
                HStack {
                    Button {
                        withAnimation(.snappy) {
                            show.toggle() // Cerrar vista de filtros sin aplicar cambios
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
                        // Actualizar los filtros en FilterViewModel con los valores locales
                        filterViewModel.updateFilters(
                            startDate: localStartDate,
                            endDate: localEndDate,
                            minPrice: localMinPrice,
                            maxPrice: localMaxPrice,
                            maxMinutes: localMaxMinutes
                        )

                        // Actualizar los filtros en OfferViewModel para reflejar los cambios aplicados
                        offerViewModel.updateFilters(
                            startDate: localStartDate,
                            endDate: localEndDate,
                            minPrice: localMinPrice,
                            maxPrice: localMaxPrice,
                            maxMinutes: localMaxMinutes
                        )

                        // Establecer que se han aplicado filtros
                        offerViewModel.filtersApplied = true

                        // Llamar a la función para cargar las ofertas con filtros
                        offerViewModel.fetchOffersWithFilters()

                        // Registrar el evento en Firestore
                        logFilterAppliedEvent()

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

                // Sincronizar los valores locales con los del ViewModel cada vez que se abra la vista
                .onAppear {
                    loadValuesFromViewModel()
                }
                
                // Sección para seleccionar fechas
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
                
                // Sección para seleccionar rango de precios
                VStack(alignment: .leading) {
                    if selectedOption == .prices {
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
                        
                        Slider(value: $localMaxMinutes, in: 0...30, step: 1)
                            .accentColor(Color(hex: "0C356A"))
                        HStack {
                            Spacer()
                            Text("\(Int(localMaxMinutes)) mins")
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
    
    // Función para registrar evento de filtro aplicado en Firestore
    private func logFilterAppliedEvent() {
        guard let currentUser = Auth.auth().currentUser, let userEmail = currentUser.email else {
            print("Error: No se pudo obtener el email del usuario, el usuario no está autenticado.")
            return
        }
        
        // Crear un identificador único para el documento usando el formato solicitado
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd_HH:mm:ss"
        let formattedDate = dateFormatter.string(from: Date())
        let documentID = "1_\(userEmail)_\(formattedDate)"

        // Crear la estructura del documento
        let actionData: [String: Any] = [
            "action": "filter",
            "app": "swift",
            "date": Date(),
            "user_id": userEmail
        ]

        // Registrar la acción en la colección "user_actions" en Firestore
        let db = Firestore.firestore()
        db.collection("user_actions").document(documentID).setData(actionData) { error in
            if let error = error {
                print("Error al registrar el evento en Firestore: \(error.localizedDescription)")
            } else {
                print("Evento de filtro aplicado registrado exitosamente en Firestore con ID: \(documentID)")
            }
        }
    }

    // Función para sincronizar los valores locales con los del ViewModel al cargar la vista
    private func loadValuesFromViewModel() {
        localStartDate = filterViewModel.startDate
        localEndDate = filterViewModel.endDate
        localMinPrice = filterViewModel.minPrice
        localMaxPrice = filterViewModel.maxPrice
        localMaxMinutes = filterViewModel.maxMinutes
    }
}




#Preview {
    FilterSearchView(
        show: .constant(false),
        filterViewModel: FilterViewModel(
            startDate: Date(),
            endDate: Date().addingTimeInterval(24 * 60 * 60),
            minPrice: 0,
            maxPrice: 10000000,
            maxMinutes: 30
        ),
        offerViewModel: OfferViewModel()
    )
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
