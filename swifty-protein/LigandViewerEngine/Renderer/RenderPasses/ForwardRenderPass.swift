import MetalKit

struct ForwardRenderPass: RenderPass {
    let label = "Forward Render Pass"
    var descriptor: MTLRenderPassDescriptor?
    
    var pipelineState: MTLRenderPipelineState
    let depthStencilState: MTLDepthStencilState?
    weak var idTexture: MTLTexture?
    
    init(view: MTKView) {
        pipelineState = PipelineStates.createForwardPSO(
            colorPixelFormat: view.colorPixelFormat)
        depthStencilState = Self.buildDepthStencilState()
    }
    
    static func buildDepthStencilState() -> MTLDepthStencilState? {
        let descriptor = MTLDepthStencilDescriptor()
        descriptor.depthCompareFunction = .less
        descriptor.isDepthWriteEnabled = true
        return Renderer.device.makeDepthStencilState(
            descriptor: descriptor)
    }
    
    mutating func resize(view: MTKView, size: CGSize) {
    }
    
    func draw(
        commandBuffer: MTLCommandBuffer,
        scene: LigandScene,
        uniforms: Uniforms,
        params: Params
    ) {
        guard let descriptor = descriptor,
              let renderEncoder =
                commandBuffer.makeRenderCommandEncoder(
                    descriptor: descriptor) else {
            return
        }
        renderEncoder.label = label
        renderEncoder.setDepthStencilState(depthStencilState)
        renderEncoder.setRenderPipelineState(pipelineState)
        
        var lights = scene.lighting.lights
        renderEncoder.setFragmentBytes(
            &lights,
            length: MemoryLayout<Light>.stride * lights.count,
            index: LightBuffer.index)
        renderEncoder.setFragmentTexture(idTexture, index: 11)
        var params = params
        params.posX = UInt32((InputController.shared.touchLocation?.x ?? 0) / InputController.shared.xFromTouch)
        params.posY = UInt32((InputController.shared.touchLocation?.y ?? 0) / InputController.shared.yFromTouch)
        for model in scene.models {
            model.render(
                encoder: renderEncoder,
                uniforms: uniforms,
                lights: scene.lighting.lights,
                params: params)
        }
        renderEncoder.endEncoding()
    }
}
