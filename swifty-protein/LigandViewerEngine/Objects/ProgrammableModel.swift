import Foundation
import ModelIO
import Metal
import MetalKit

class ProgrammbableModel: Model {

    init(name: String, id: UInt32, mdlMesh: MDLMesh, color: float3) {
        super.init(name: name, id: id, baseColor: color)
         do {
             let mesh = try MTKMesh(mesh: mdlMesh, device: Renderer.device)
             meshes = zip([mdlMesh], [mesh]).map {
                 Mesh(mdlMesh: $0.0, mtkMesh: $0.1)
             }
         } catch {
             fatalError("Mesh error")
         }
    }
}
