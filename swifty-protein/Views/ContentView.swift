
import SwiftUI



@available(macOS 12, iOS 15.0, *)
struct ContentView: View {
    var ligand: Ligand?
    @State  var atomSelected: AtomLigand?
    @State var renderer: Renderer?
    @State private var imgToShare: ImageToShare?
    
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
                MetalView(ligand: ligand, renderer: $renderer, atomSelected: $atomSelected) //.gesture(myGesture)
                AtomSelectedView(atom: $atomSelected).position(x: 80, y: 35)
            }
        }.navigationTitle("\(ligand?.meta.name ?? "")").toolbar {
            
#if os(macOS)
            
#elseif os(iOS)
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    imgToShare = ImageToShare(img: renderer?.shareView())
                    renderer?.isViewBlocked = true
                }, label: {
                    Image(systemName: "square.and.arrow.up")
                })
                .sheet(item: $imgToShare, onDismiss: {
                    imgToShare = nil
                    renderer?.isViewBlocked = false
                }) {
                    ActivityViewController(img: $0)
                }
                //                .sheet(item: self.$imgToShare) {
                //                    ActivityViewController(activityItems: [$0])
                //
                //                }
                //                Button(action: {
                //                    renderer?.shareView()
                //                }) {
                //                    Image(systemName: "square.and.arrow.up")
                //                }
            }
#endif
            
        }
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

class ImageToShare: Identifiable {
    var img: UIImage?
    
    init(img: UIImage?) {
        self.img = img
    }
}
