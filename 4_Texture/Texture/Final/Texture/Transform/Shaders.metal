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

//3
struct VertexIn {
    float4 position [[ attribute(Position) ]];
    float2 uv [[ attribute(UV) ]];
};

struct VertexOut {
    float4 position [[ position ]];
    float3 worldPosition;
    float2 uv;
};

vertex VertexOut vertex_main(const VertexIn vertexIn [[ stage_in ]],
                             constant Uniforms &uniforms [[ buffer(1) ]])
{
    VertexOut out;
    out.position = uniforms.projectionMatrix * uniforms.viewMatrix
    * uniforms.modelMatrix * vertexIn.position;
    out.worldPosition = (uniforms.modelMatrix * vertexIn.position).xyz;

    //4
    out.uv = vertexIn.uv;
    return out;
}


fragment float4 fragment_main(VertexOut in [[stage_in]],
                              texture2d<float> baseColorTexture [[ texture(BaseColorTexture)]]) {
    constexpr sampler textureSampler;
    float3 baseColor = baseColorTexture.sample(textureSampler, in.uv).rgb;
    return float4(baseColor ,1);
}

