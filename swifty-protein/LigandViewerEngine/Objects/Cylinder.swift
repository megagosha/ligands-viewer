
import MetalKit

class Cylinder: ProgrammbableModel {

    init(height: Float, name: String, color: float3,  id: UInt32, isDouble: Bool = false) {
        let radii = isDouble ? vector_float2(x: 0.07, y: 0.07) : vector_float2(x: 0.11, y: 0.11)
//        let mdlMesh = MDLMesh.newCapsule(withHeight: height, radii: radii, radialSegments: 20, verticalSegments: 20, hemisphereSegments: 10, geometryType: .triangles, inwardNormals: false, allocator: MTKMeshBufferAllocator(device: Renderer.device))
        let mdlMesh = MDLMesh.newCylinder(withHeight: height, radii: radii, radialSegments: 20, verticalSegments: 20, geometryType: .triangles, inwardNormals: false, allocator: MTKMeshBufferAllocator(device: Renderer.device))
        do {
            super.init(name: name, id: id, mdlMesh: mdlMesh, color: color)
        } catch {
            fatalError("Mesh error")
        }
    }
}
