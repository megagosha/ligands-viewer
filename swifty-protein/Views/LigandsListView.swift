import SwiftUI

struct LigandsListView: View {
    
    var ligands: [Ligand]
    @State private var searchText = ""

    var body: some View {
        NavigationView {
            if #available(macOS 12.0, iOS 15, *) {
                List {
                    ForEach(searchResults) { el in
                        NavigationLink {
                            ContentView(ligand: el)
                        } label: {
                            Text(el.meta.name)
                        }
                    }
                }.searchable(text: $searchText, prompt: "Type to search").disableAutocorrection(true).navigationTitle("Proteins")
            } else {
                // Fallback on earlier versions
            }
        }
    }
    
    var searchResults: [Ligand] {
          if searchText.isEmpty {
              return ligands
          } else {
              return ligands.filter { $0.meta.name.localizedStandardContains(searchText) }
          }
      }
}
