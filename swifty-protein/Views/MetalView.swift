
import SwiftUI
import MetalKit

struct MetalView: View {
    let ligand: Ligand?
    @State public var renderer: Renderer?
    @State private var metalView = MTKView()
    @State private var previousTranslation = CGSize.zero
    @State private var previousScroll: CGFloat = 1
    @Binding var atomSelected: AtomLigand?
    var body: some View {
        MetalViewRepresentable(
            renderer: renderer,
            metalView: $metalView)
        .onAppear {
            renderer = Renderer(
                ligand: ligand,
                metalView: metalView, atomSelected: $atomSelected)
            renderer?.scene.camera.defaultRotation = true
        }
        .gesture(DragGesture(minimumDistance: 0, coordinateSpace: .local)
            .onChanged { value in
                    InputController.shared.touchLocation = value.location
                    InputController.shared.touchDelta = CGSize(
                        width: value.translation.width - previousTranslation.width,
                        height: value.translation.height - previousTranslation.height)
                    previousTranslation = value.translation
                    // if the user drags, cancel the tap touch
                    if abs(value.translation.width) > 1 ||
                        abs(value.translation.height) > 1 {
                        InputController.shared.touchLocation = nil
                    }
            }
            .onEnded {value in
                if isTap(location: value) {
                    print("loc \(value.location)")
                    renderer?.testHit(at: value.location)
                }
                previousTranslation = .zero
                InputController.shared.leftMouseDown = false
            })
        .gesture(MagnificationGesture()
            .onChanged { value in
                let scroll = value - previousScroll
                InputController.shared.mouseScroll.x = Float(scroll)
                * Settings.touchZoomSensitivity
                previousScroll = value
            }
            .onEnded {_ in
                previousScroll = 1
            })
    }
    func isTap(location: DragGesture.Value)->Bool {
        let difX = location.predictedEndLocation.x - location.location.x
        let difY = location.predictedEndLocation.y - location.location.y
        
        return difX > -5 && difX < 5 &&
        difY > -5 && difY < 5
    }
}

#if os(macOS)
typealias ViewRepresentable = NSViewRepresentable
typealias MyMetalView = NSView
#elseif os(iOS)
typealias ViewRepresentable = UIViewRepresentable
typealias MyMetalView = UIView
#endif

struct MetalViewRepresentable: ViewRepresentable {
    let renderer: Renderer?
    @Binding var metalView: MTKView
    
#if os(macOS)
    func makeNSView(context: Context) -> some NSView {
        return metalView
    }
    func updateNSView(_ uiView: NSViewType, context: Context) {
    }
#elseif os(iOS)
    func makeUIView(context: Context) -> MTKView {
        metalView
    }
    
    func updateUIView(_ uiView: MTKView, context: Context) {
        //        updateMetalView()
    }
#endif
    
}
//
//struct MetalView_Previews: PreviewProvider {
//    @Binding var atomSelected: AtomLigand?
//
//    static var previews: some View {
//        VStack {
//            MetalView(ligand: nil, atomSelected: $atomSelected)
//            Text("Metal View")
//        }
//    }
//}
