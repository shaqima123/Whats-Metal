//
//  Shaders.metal
//  PipeLine
//
//  Created by Kira on 2019/2/10.
//  Copyright © 2019 Kira. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

vertex float4 vertex_main(constant packed_float3* vertex_array[[buffer(0)]],
                          unsigned int vid[[vertex_id]]) {
    return float4(vertex_array[vid], 1.0);
}

fragment float4 fragment_main() {
    return float4(0, 1, 0, 1);
}
