import MetalKit
import SwiftUI
// swiftlint:disable implicitly_unwrapped_optional

class Renderer: NSObject, Identifiable {
    @Binding var selectedAtom: AtomLigand?
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    static var library: MTLLibrary!
    var mtk:  MTKView
    var forwardRenderPass: ForwardRenderPass
    var objectIdRenderPass: ObjectIdRenderPass
    var pipelineState: MTLRenderPipelineState!
    //    let depthStencilState: MTLDepthStencilState?
    var timer: Float = 0
    var uniforms = Uniforms()
    var params = Params()
    let ligand: Ligand?
    var processClick: Bool = false
    var isViewBlocked: Bool = false
    var point: CGPoint?
    // the models to render
    lazy var scene = LigandScene(ligand: ligand)
    
    init(ligand: Ligand?, metalView: MTKView, atomSelected: Binding<AtomLigand?>) {
        guard
            let device = MTLCreateSystemDefaultDevice(),
            let commandQueue = device.makeCommandQueue() else {
            fatalError("GPU not available")
        }
        Renderer.device = device
        Renderer.commandQueue = commandQueue
        metalView.device = device
        
        let library = device.makeDefaultLibrary()
        Self.library = library
        objectIdRenderPass = ObjectIdRenderPass()
        forwardRenderPass = ForwardRenderPass(view: metalView)
        self.ligand = ligand
#if canImport(AppKit)
        let color = Color(NSColor.windowBackgroundColor)
#elseif canImport(UIKit)
        let color = Color(UIColor.systemBackground)
#endif
        let res = color.rgb
        metalView.clearColor = MTLClearColor(
            red: Double(res.x),
            green: Double(res.y),
            blue: Double(res.z),
            alpha: 1.0)
        metalView.depthStencilPixelFormat = .depth32Float
        mtk = metalView
        self._selectedAtom = atomSelected
        super.init()
        mtk.preferredFramesPerSecond = 120
        metalView.delegate = self
        mtkView(metalView, drawableSizeWillChange: metalView.bounds.size)
        metalView.framebufferOnly = false
        
    }
    
    
    func  testHit(at point: CGPoint) {
        self.processClick = true
        self.point = point
    }
    
    func updateUniforms(scene: LigandScene) {
        uniforms.viewMatrix = scene.camera.viewMatrix
        uniforms.projectionMatrix = scene.camera.projectionMatrix
        params.lightCount = UInt32(scene.lighting.lights.count)
        params.cameraPosition = scene.camera.position
    }
}

extension Renderer: MTKViewDelegate {
    
    private func updateTouchToPixel()
    {
        DispatchQueue.main.async {
            InputController.shared.xFromTouch = self.mtk.bounds.maxX / self.mtk.drawableSize.width
            InputController.shared.yFromTouch = self.mtk.bounds.maxY / self.mtk.drawableSize.height
            //            print("xFrom \(InputController.shared.xFromTouch)")
            //            print("yFrom \(InputController.shared.yFromTouch)")
            
        }
    }
    
    func mtkView(
        _ view: MTKView,
        drawableSizeWillChange size: CGSize
    ) {
        updateTouchToPixel()
        objectIdRenderPass.resize(view: view, size: size)
        scene.update(size: size)
    }
    
    func draw(in view: MTKView) {
        guard let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
              let descriptor = view.currentRenderPassDescriptor else {
            return
        }
        if isViewBlocked {
            return
        }
        timer += 0.005
        //        renderEncoder.setDepthStencilState(depthStencilState)
        //        renderEncoder.setRenderPipelineState(pipelineState)
        
        updateUniforms(scene: scene)
        scene.update(deltaTime: timer)
        objectIdRenderPass.draw(commandBuffer: commandBuffer, scene: scene, uniforms: uniforms, params: params)
        forwardRenderPass.idTexture = objectIdRenderPass.idTexture
        forwardRenderPass.descriptor = descriptor
        forwardRenderPass.draw(commandBuffer: commandBuffer, scene: scene, uniforms: uniforms, params: params)
        
        guard let drawable = view.currentDrawable else {
            return
        }
        commandBuffer.addCompletedHandler{ [self]_ in
            if self.processClick {
                guard let texture = self.objectIdRenderPass.idTexture, let point = self.point else {
                    self.processClick = false
                    return
                }
                let res = self.translatePointToPixel()
                if  res.0 <= 0 ||
                        res.0 >= self.mtk.drawableSize.width ||
                        res.1 <= 0 ||
                        res.1 >= self.mtk.drawableSize.height
                {
                    self.processClick = false
                    self.selectedAtom = nil
                    return
                }
                let pixels: UnsafeMutablePointer<UInt32> = texture.getPixels(MTLRegionMake2D(Int(res.0), Int(res.1), 1, 1))
                defer {
                    pixels.deallocate()
                }
                let pixel = pixels[0]
                self.selectedAtom = self.scene.selectAtom(fromId: pixel)
                self.processClick = false
            }
        }
        //        commandBuffer.addCompletedHandler( {x in
        //            x.commandQueue.device.
        //
        //        })
        //        if let blitEncoder = commandBuffer.makeBlitCommandEncoder() {
        //            let textureDescriptor = MTLTextureDescriptor.texture2DDescriptor(
        //                pixelFormat: mtk.colorPixelFormat,
        //                width: drawable.texture.width,
        //                height: drawable.texture.height,
        //                mipmapped: false)
        //
        //              textureDescriptor.usage = [.shaderWrite, .shaderRead]
        //
        //            guard let texture: MTLTexture = commandBuffer.device.makeTexture(descriptor: textureDescriptor) else
        //              {
        //                print("ERROR")
        //                return
        //              }
        
        //            let region = MTLRegion.init(origin: MTLOrigin.init(x: 0, y: 0, z: 0), size: MTLSize.init(width: drawable.texture.width, height: drawable.texture.height, depth: 1));
        
        //            blitEncoder.copy(from: drawable.texture, to: texture)
        //            blitEncoder.endEncoding()
        //        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
    
    private func translatePointToPixel()->(CGFloat, CGFloat) {
        guard let point = point else {
            return (0, 0)
        }
        var x = CGFloat()
        var y = CGFloat()
        
        DispatchQueue.main.sync {
            
            
            x = point.x /  mtk.bounds.maxX  * mtk.drawableSize.width
            y = point.y / mtk.bounds.maxY * mtk.drawableSize.height
            
            print("point.x \(point.x) translated: \(x)")
            print("point.y \(point.y) translated: \(y)")
        }
        return (x, y)
    }
#if os(iOS)
    public func shareView()->UIImage? {
        guard let cg = mtk.currentDrawable!.texture.toImage() else {
            return nil
        }
        return UIImage(cgImage: cg, scale: 1, orientation: .up)
    }
#endif
}
