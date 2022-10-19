import MetalKit

extension MTLVertexDescriptor {
    static var defaultLayout: MTLVertexDescriptor {
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[Position.index].format = .float3
        vertexDescriptor.attributes[Position.index].offset = 0
        vertexDescriptor.attributes[Position.index].bufferIndex = VertexBuffer.index

        vertexDescriptor.attributes[Normal.index].format = .float3
        vertexDescriptor.attributes[Normal.index].offset = 12
        vertexDescriptor.attributes[Normal.index].bufferIndex = VertexBuffer.index

        vertexDescriptor.attributes[Texture.index].format = .float2
        vertexDescriptor.attributes[Texture.index].offset = 24
        vertexDescriptor.attributes[Texture.index].bufferIndex = VertexBuffer.index
        vertexDescriptor.layouts[VertexBuffer.index].stride = 32

        return vertexDescriptor
    }
}

extension Attributes {
    var index: Int {
        return Int(self.rawValue)
    }
}

extension BufferIndices {
    var index: Int {
        return Int(self.rawValue)
    }
}

extension TextureIndices {
    var index: Int {
        return Int(self.rawValue)
    }
}
