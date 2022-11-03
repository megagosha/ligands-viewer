import SwiftUI

@available(macOS 12.0, *)
@main
struct SwiftyProteinApp: App {
    @StateObject var downloader = LigandLoader()
    
    var body: some Scene {
        WindowGroup {
            NavigationView {
                if downloader.isReady {
                    LigandsListView(ligands: downloader.ligands)
                }
                else {
                    if #available(iOS 15.0, *) {
                        LoadingView(error: $downloader.showError)
//#if os(macOS)
//
//#elseif os(iOS)
                            .navigationTitle("Ligands viewer").toolbar {
                                
                                ToolbarItem(placement: .navigationBarTrailing) {
                                    if downloader.showError == true {
                                        Button(action: {
                                            downloader.showError = false
                                            downloader.start()
                                        }) {
                                            Image(systemName: "arrow.counterclockwise")
                                        }
                                    }
                                }
                            }
                            .frame(minWidth: 400, idealWidth: 400, maxWidth: .infinity, minHeight: 400, idealHeight: 400, maxHeight: .infinity, alignment: .center).onAppear() {
                                downloader.start()
                            }
//#endif
                    }
                    else {
                        // Fallback on earlier versions
                    }
                }
            }
        }
    }
}
