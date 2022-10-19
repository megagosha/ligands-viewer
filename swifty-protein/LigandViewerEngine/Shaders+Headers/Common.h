
#ifndef Common_h
#define Common_h

#import <simd/simd.h>

typedef enum {
    unused = 0,
    Sun = 1,
    Spot = 2,
    Point = 3,
    Ambient = 4
} LightType;

typedef struct {
    LightType type;
    vector_float3 position;
    vector_float3 color;
    vector_float3 specularColor;
    float radius;
    vector_float3 attenuation;
    float coneAngle;
    vector_float3 condeDirection;
    float coneAttenuation;
} Light;

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
    matrix_float3x3 normalMatrix;
    int   isConnection;
    vector_float3 xAtom;
    vector_float3 yAtom;
} Uniforms;

typedef struct {
    uint width;
    uint height;
    uint tiling;
    uint lightCount;
    uint objectId;
    vector_float3 cameraPosition;
    uint posX;
    uint posY;
} Params;


typedef enum {
    Position = 0,
    Normal = 1,
    Texture = 2,
//    Rotation = 2,
    Color = 3
} Attributes;

typedef enum {
    VertexBuffer = 0,
    ColorBuffer = 14,
    UniformsBuffer = 11,
    ParamsBuffer = 12,
    RotationBuffer = 15,
    LightBuffer = 13,
} BufferIndices;

typedef enum {
    BaseColor = 0
} TextureIndices;

#endif /* Common_h */
