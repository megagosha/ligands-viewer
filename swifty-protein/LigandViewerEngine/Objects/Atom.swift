import MetalKit
import simd

class Atom: ProgrammbableModel {
    
    let radius: Float = 0.3
    init(name: String, id: UInt32, color: float3) {
        let mdlMesh = MDLMesh(
            sphereWithExtent: [radius, radius, radius],
            segments: [20, 20],
            inwardNormals: false,
            geometryType: .triangles,
            allocator: MTKMeshBufferAllocator(device: Renderer.device))
        super.init(name: name, id: id, mdlMesh: mdlMesh, color: color)
    }
}
