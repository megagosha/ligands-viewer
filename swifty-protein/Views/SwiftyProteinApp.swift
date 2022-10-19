import SwiftUI

@available(macOS 12.0, *)
@main
struct SwiftyProteinApp: App {
    @StateObject var downloader = LigandLoader()
    
    var body: some Scene {
        WindowGroup {
            if downloader.isReady {
                LigandsListView(ligands: downloader.ligands)
            }
            else {
                if #available(iOS 15.0, *) {
                    LoadingView()
                        .navigationTitle("SwiftyProtein").alert("Error", isPresented: $downloader.showError, actions: {})
                        .frame(minWidth: 400, idealWidth: 400, maxWidth: .infinity, minHeight: 400, idealHeight: 400, maxHeight: .infinity, alignment: .center).onAppear() {
                            downloader.start()
                        }
                } else {
                    // Fallback on earlier versions
                }
            }
        }
    }
}
