
import Foundation

struct SceneLighting {
  static func buildDefaultLight() -> Light {
    var light = Light()
    light.position = [0, 0, 0]
    light.color = [1, 1, 1]
    light.specularColor = float3(repeating: 0.8)
    light.attenuation = [1, 0, 0]
    light.type = Sun
    return light
  }

  let sunlight: Light = {
    var light = Self.buildDefaultLight()
    light.position = [0, 10, -10]
    return light
  }()

  var lights: [Light] = []

  init() {
    lights.append(sunlight)
  }
}
