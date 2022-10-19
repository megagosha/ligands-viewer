
import MetalKit

struct Submesh {
  let indexCount: Int
  let indexType: MTLIndexType
  let indexBuffer: MTLBuffer
  let indexBufferOffset: Int
}

extension Submesh {
  init(mdlSubmesh: MDLSubmesh, mtkSubmesh: MTKSubmesh) {
    indexCount = mtkSubmesh.indexCount
    indexType = mtkSubmesh.indexType
    indexBuffer = mtkSubmesh.indexBuffer.buffer
    indexBufferOffset = mtkSubmesh.indexBuffer.offset
  }
}
