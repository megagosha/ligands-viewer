
import SwiftUI



@available(macOS 12, iOS 15.0, *)
struct ContentView: View {
    var ligand: Ligand?
    @State  var atomSelected: AtomLigand?
//    let myGesture = DragGesture(minimumDistance: 0, coordinateSpace: .local).onEnded({
//        InputController.shared.touchLocation?.x = $0.startLocation.x
//        InputController.shared.touchLocation?.y = $0.startLocation.y
//        print("cords x: \($0.startLocation.x) \($0.startLocation.y)")
//    })
        
//    init(ligand: Ligand?, atomSelected: AtomLigand?) {
//        self.ligand = ligand
//        self.atomSelected = atomSelected
//    }
    
    var body: some View {
        VStack(alignment: .leading) {
            ZStack {
                MetalView(ligand: ligand, atomSelected: $atomSelected) //.gesture(myGesture)
                AtomSelectedView(atom: $atomSelected).position(x: 80, y: 35)
            }
        }.navigationTitle("\(ligand?.meta.name ?? "")")
    }
}

//struct ContentView_Previews: PreviewProvider {
//    var ligand: Ligand?
//    static var previews: some View {
//        Group {
//            ContentView(ligand: nil)
//        }
//    }
//}
