import SwiftUI


struct LoadingView: View {
    @Binding var error: Bool
    
    var body: some View {
        VStack {
            if error == true {
                Text("Error occured while downloading files")
            }
            else {
                ProgressView().progressViewStyle(.circular)
            }
        }
    }
}
