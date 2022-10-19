import CoreGraphics

protocol Camera: Transformable {
    var projectionMatrix: float4x4 { get }
    var viewMatrix: float4x4 { get }
    mutating func update(size: CGSize)
    mutating func update(deltaTime: Float)
}

struct ArcballCamera: Camera {
    var transform = Transform()
    
    var rotationSpeed: Point = Point(x: 0, y: 0)
    var defaultRotation = true
    var aspect: Float = 1.0
    var fov = Float(70).degreesToRadians
    var near: Float = 0.1
    var far: Float = 100
    var projectionMatrix: float4x4 {
        float4x4(
            projectionFov: fov,
            near: near,
            far: far,
            aspect: aspect)
    }
    
    let minDistance: Float = 5
    var maxDistance: Float = 20
    var target: float3 = [0, 0, 0]
    var distance: Float = 2.5
    
    mutating func update(size: CGSize) {
        aspect = Float(size.width / size.height)
    }
    
    var viewMatrix: float4x4 {
        let matrix: float4x4
        if target == position {
            matrix = (float4x4(translation: target) * float4x4(rotationYXZ: rotation)).inverse
        } else {
            let up: float3 = rotation.x < -.pi / 2 || rotation.x > .pi / 2 ? [0, -1, 0] : [0, 1, 0]
            matrix = float4x4(eye: position, center: target, up: up)
        }
        return matrix
    }
    
    private func accelerateRotation(mouseDelta: Float, rotationSpeed: Float)->Float {
        var rtSpeed = rotationSpeed
        if abs(mouseDelta) > 0.01
        {
            if sign(mouseDelta) == sign(rtSpeed) || rtSpeed == 0 {
                rtSpeed += mouseDelta * Settings.mousePanSensitivity
            }
            else {
                rtSpeed = sign(rtSpeed) * (abs(rtSpeed) -  abs(mouseDelta) * Settings.mousePanSensitivity)
            }
            return abs(rtSpeed) > Settings.rotationMaxSpeed ? Settings.rotationMaxSpeed * sign(rtSpeed) : rtSpeed
        }
        return rtSpeed
    }
    
    private func decelerateRotation(mouseDelta: Float, rotationSpeed: Float)->Float {
        var rtSpeed = rotationSpeed
        rtSpeed = sign(rtSpeed) * (abs(rtSpeed) - abs(rtSpeed) * 0.01)
        if abs(rtSpeed) < 0.005 {
            rtSpeed = 0
        }
        return rtSpeed
    }
    
    mutating func update(deltaTime: Float) {
        let input = InputController.shared
        let scrollSensitivity = Settings.mouseScrollSensitivity
        distance -= (input.mouseScroll.x + input.mouseScroll.y)
        * scrollSensitivity
        distance = min(maxDistance, distance)
        distance = max(minDistance, distance)
        input.mouseScroll = .zero
        if input.leftMouseDown {
            let sensitivity = Settings.mousePanSensitivity
            defaultRotation = false
            if rotation.x < -.pi / 2 || rotation.x > .pi / 2 {
                input.mouseDelta.x = -input.mouseDelta.x
            }
            rotationSpeed.y = accelerateRotation(mouseDelta: input.mouseDelta.x, rotationSpeed: rotationSpeed.y)
            rotationSpeed.x = accelerateRotation(mouseDelta: input.mouseDelta.y, rotationSpeed: rotationSpeed.x)
            input.mouseDelta = .zero
        }
        else {
            rotationSpeed.y = decelerateRotation(mouseDelta: input.mouseDelta.x, rotationSpeed: rotationSpeed.y)
            rotationSpeed.x = decelerateRotation(mouseDelta: input.mouseDelta.y, rotationSpeed: rotationSpeed.x)
        }
        rotation.y += rotationSpeed.y
        rotation.x += rotationSpeed.x
        if rotation.x > ((3 * .pi) / 2) {
            rotation.x = -.pi / 2
        }
        if rotation.x < ((3 * -.pi) / 2) {
            rotation.x = .pi / 2
        }
        if defaultRotation {
            rotation.y = sin(deltaTime)
            rotation.x = sin(deltaTime)
        }
        let rotateMatrix = float4x4(
            rotationYXZ: [-rotation.x, rotation.y, 0])
        let distanceVector = float4(0, 0, -distance, 0)
        let rotatedVector = rotateMatrix * distanceVector
        position = target + rotatedVector.xyz
        
    }
}
