import MetalKit

struct ObjectIdRenderPass: RenderPass {
    let label = "Object ID Render Pass"
    var descriptor: MTLRenderPassDescriptor?
    var pipelineState: MTLRenderPipelineState
    var idTexture: MTLTexture?
    var depthTexture: MTLTexture?
    var depthStencilState: MTLDepthStencilState?

    mutating func resize(view: MTKView, size: CGSize) {
        idTexture = Self.makeTexture(size: size, pixelFormat: .r32Uint, label: "ID Texture", storageMode: .shared)
        depthTexture = Self.makeTexture(size: size, pixelFormat: .depth32Float, label: "IDd Depth Texture")
    }
    
    init() {
        pipelineState = PipelineStates.createObjectIdPSO()
        descriptor = MTLRenderPassDescriptor()
        depthStencilState = Self.buildDepthStencilState()
    }
    
    func draw(commandBuffer: MTLCommandBuffer, scene: LigandScene, uniforms: Uniforms, params: Params) {
        guard let descriptor = descriptor else {
            return
        }
        descriptor.colorAttachments[0].texture = idTexture
        descriptor.colorAttachments[0].loadAction = .clear
        descriptor.colorAttachments[0].storeAction = .store
        descriptor.depthAttachment.texture = depthTexture
        guard let renderEncoder =
          commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else {
            return
        }
        renderEncoder.label = label
        renderEncoder.setRenderPipelineState(pipelineState)
        renderEncoder.setDepthStencilState(depthStencilState)
        for model in scene.models {
          model.render(
            encoder: renderEncoder,
            uniforms: uniforms,
            lights: scene.lighting.lights,
//            gRotation: scene.gRotationMat,
            params: params
          )
        }
        renderEncoder.endEncoding()
    }
}

extension MTLTexture {
  func getPixels<T> (_ region: MTLRegion? = nil, mipmapLevel: Int = 0) -> UnsafeMutablePointer<T> {
    let fromRegion  = region ?? MTLRegionMake2D(0, 0, self.width, self.height)
    let width       = fromRegion.size.width
    let height      = fromRegion.size.height
    let bytesPerRow = MemoryLayout<T>.stride * width
    let data        = UnsafeMutablePointer<T>.allocate(capacity: bytesPerRow * height)
    self.getBytes(data, bytesPerRow: bytesPerRow, from: fromRegion, mipmapLevel: mipmapLevel)
    return data
  }
}
