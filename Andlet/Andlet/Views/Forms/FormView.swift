import SwiftUI

struct FormView: View {
    var body: some View {
        NavigationView {
            Step1View() // Inicia en el Step 1
        }
    }
    
}

struct FormView_Previews: PreviewProvider {
    static var previews: some View {
        FormView()
    }
}
