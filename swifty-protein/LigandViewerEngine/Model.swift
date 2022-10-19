// swiftlint:disable force_try
// swiftlint:disable vertical_whitespace_opening_braces

import MetalKit

class Model: Transformable {
    var transform = Transform()
    var meshes: [Mesh] = []
    var name: String
    var tiling: UInt32 = 1
    var color: float3
    var objectId: UInt32
    
    init(name: String, id: UInt32, baseColor: float3) {
        self.name = name
        self.objectId = id
        self.color = baseColor
    }
    
    func render(
        encoder: MTLRenderCommandEncoder,
        uniforms vertex: Uniforms,
        lights: [Light],
        params fragment: Params
    ) {
        var uniforms = vertex
        var params = fragment

        params.objectId = objectId
        params.tiling = tiling
        uniforms.modelMatrix = transform.modelMatrix
        uniforms.normalMatrix = uniforms.modelMatrix.upperLeft

        encoder.setVertexBytes(&color, length: MemoryLayout<float3>.stride, index: ColorBuffer.index)

        encoder.setVertexBytes(
            &uniforms,
            length: MemoryLayout<Uniforms>.stride,
            index: UniformsBuffer.index)

        encoder.setFragmentBytes(
            &params,
            length: MemoryLayout<Params>.stride,
            index: ParamsBuffer.index)


        for mesh in meshes {
            for (index, vertexBuffer) in mesh.vertexBuffers.enumerated() {
                encoder.setVertexBuffer(
                    vertexBuffer,
                    offset: 0,
                    index: index)
            }

            for submesh in mesh.submeshes {
                encoder.drawIndexedPrimitives(
                    type: .triangle,
                    indexCount: submesh.indexCount,
                    indexType: submesh.indexType,
                    indexBuffer: submesh.indexBuffer,
                    indexBufferOffset: submesh.indexBufferOffset
                )
            }
        }
    }
}
