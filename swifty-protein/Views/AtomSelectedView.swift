import SwiftUI

@available(macOS 12, iOS 15.0, *)
struct AtomSelectedView: View {
    @Binding var atomSelected: AtomLigand?
    
    init(atom: Binding<AtomLigand?>) {
        self._atomSelected = atom
    }
    
    var body: some View {
        HStack {
            if atomSelected != nil {
                Capsule().fill(.secondary).overlay(
                    Text(verbatim: "Selected atom: \(atomSelected?.symbol ?? "")")).frame(minWidth: 50, maxWidth: 150, minHeight: 25, maxHeight: 50)
            }
//            Button("Toggle") {
//                isSelected.toggle()
//            }
        }
    }
}
