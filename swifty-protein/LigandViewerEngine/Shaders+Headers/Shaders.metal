#include <metal_stdlib>
using namespace metal;
#import "Lighting.h"

struct VertexIn {
    float4 position [[attribute(Position)]];
    float3 normal [[attribute(Normal)]];
    float2 textureCord [[attribute(Texture)]];
};

struct VertexOut {
    float4 position [[position]];
    //    float3 normal;
    float3 color;
    float3 worldPosition;
    float3 worldNormal;
};

float3x3 topLeft(constant float4x4 &matrix) {
    float3x3 res(matrix[0][0], matrix[0][1], matrix[0][2],
                 matrix[1][0], matrix[1][1], matrix[1][2],
                 matrix[2][0], matrix[2][1], matrix[2][2]);
    return res;
}

vertex VertexOut vertex_main(
                             const VertexIn in [[stage_in]],
                             constant float3 &color [[buffer(ColorBuffer)]],
                             constant Uniforms &uniforms [[buffer(UniformsBuffer)]])
{
    float4 position =
    uniforms.projectionMatrix * uniforms.viewMatrix
    * uniforms.modelMatrix * in.position;
    float3 normal = in.normal * uniforms.normalMatrix;
    VertexOut out {
        .position = position,
        .color = color,
        .worldPosition = (uniforms.modelMatrix * in.position).xyz,
        .worldNormal = normal,
    };
    return out;
}

fragment float4 fragment_main(
                              constant Params &params [[buffer(ParamsBuffer)]],
                              texture2d<uint> idTexture [[texture(11)]],
                              constant Light *lights [[buffer(LightBuffer)]],
                              constant Uniforms &uniforms[[buffer(UniformsBuffer)]],
                              VertexOut in [[stage_in]])
{
//    return float4(in.worldNormal, 1);
    float3 normalDirection = normalize(in.worldNormal);
    float3 color = phongLighting(normalDirection, in.worldPosition, params, lights, in.color);
    if (!is_null_texture(idTexture)) {
        uint2 coord = uint2(params.posX, params.posY);
        uint objectID = idTexture.read(coord).r;
        if (params.objectId != 0 && objectID == params.objectId) {
            float tint_factor = 0.25;
            float newR = color.x + (1 - color.x) * tint_factor;
            float newG = color.y + (1 - color.y) * tint_factor;
            float newB = color.z + (1 - color.z) * tint_factor;
//            return float4(color.x + 0.2, color.y + 0.2, color.z + 0.2, 1);
            return float4(newR, newG, newB, 1);
        }
    }
    
    return float4(color, 1);
}
