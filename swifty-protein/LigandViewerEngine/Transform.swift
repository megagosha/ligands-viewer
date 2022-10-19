import Foundation

struct Keyframe<Value> {
  var time: Float = 0
  var value: Value
}

struct Transform {
    var position: float3 = [0, 0, 0]
    var rotation: float3 = [0, 0, 0]
    var rotationMatrix: float4x4 = float4x4(rotation: float3())
    var scale: Float = 1
}

extension Transform {
    var modelMatrix: matrix_float4x4 {
        let translation = float4x4(translation: position)
        let scale = float4x4(scaling: scale)
        return  translation * rotationMatrix  * scale
       
    }
}

protocol Transformable {
    var transform: Transform { get set }
}

extension Transformable {
    var position: float3 {
        get { transform.position }
        set { transform.position = newValue }
    }
    var rotation: float3 {
        get { transform.rotation }
        set { transform.rotation = newValue }
    }
    var scale: Float {
        get { transform.scale }
        set { transform.scale = newValue }
    }
    var rotationMatrix: float4x4 {
        get { transform.rotationMatrix }
        set { transform.rotationMatrix = newValue }
    }
}
