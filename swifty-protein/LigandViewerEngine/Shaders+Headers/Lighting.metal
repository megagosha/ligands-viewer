
#include "Lighting.h"
#include <metal_stdlib>

using namespace metal;

float3 phongLighting(
                     float3 normal,
                     float3 position,
                     constant Params &params,
                     constant Light *lights,
                     float3 color) {
                         float3 baseColor = color;
                         float3 diffuseColor = 0;
                         float3 ambientColor = 0;
                         float3 specularColor = 0;
                         
                         float materialShininess = 32;
                         float3 materialSpecularColor = baseColor * float3(0.5, 0.5, 0.5);
                         for (uint i = 0; i < params.lightCount; i++) {
                             Light light = lights[i];
                             float3 lightDirection = normalize(-light.position);
                             float diffuseIntensity =
                               saturate(-dot(lightDirection, normal));
                             diffuseColor += light.color * baseColor * diffuseIntensity;
                             if (diffuseIntensity > 0) {
                               float3 reflection =
                                   reflect(lightDirection, normal);
                               float3 viewDirection =
                                   normalize(params.cameraPosition);
                               float specularIntensity =
                                   pow(saturate(dot(reflection, viewDirection)),
                                       materialShininess);
                               specularColor +=
                                   light.specularColor * materialSpecularColor
                                     * specularIntensity;
                             }
                         }
                         return diffuseColor + specularColor + ambientColor;
                         
                         //    return diffuseColor + specularColor + ambientColor;
                     }

