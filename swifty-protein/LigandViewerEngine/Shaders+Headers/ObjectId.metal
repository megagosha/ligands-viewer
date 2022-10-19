#include <metal_stdlib>
#import "Common.h"
using namespace metal;

struct FragmentOut {
    uint objectId [[color(0)]];
};

fragment FragmentOut fragment_objectId(constant Params &params [[buffer(ParamsBuffer)]])
{
    FragmentOut out {
        .objectId = params.objectId
    };
    return out;
}


