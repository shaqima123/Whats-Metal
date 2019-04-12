//
//  Shaders.metal
//  PipeLine
//
//  Created by Kira on 2019/2/10.
//  Copyright © 2019 Kira. All rights reserved.
//

#include <metal_stdlib>
#import "Common.h"

using namespace metal;

struct VertexIn {
    float4 position [[ attribute(0) ]];
};
struct VertexOut {
    float4 position [[ position ]];
    float3 worldPosition;
};

vertex VertexOut vertex_main(const VertexIn vertexIn [[ stage_in ]],
                             constant Uniforms &uniforms [[ buffer(1) ]])
{
    VertexOut out;
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix
    * uniforms.modelMatrix * vertexIn.position;
    out.worldPosition = (uniforms.modelMatrix * vertexIn.position).xyz;
    return out;
}


fragment float4 fragment_main() {
    return float4(0, 1, 0, 1);
}

