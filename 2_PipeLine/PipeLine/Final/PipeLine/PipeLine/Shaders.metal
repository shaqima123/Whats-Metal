//
//  Shaders.metal
//  PipeLine
//
//  Created by Kira on 2019/2/10.
//  Copyright © 2019 Kira. All rights reserved.
//

#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[ attribute(0) ]];
};

vertex float4 vertex_main(const VertexIn vertex_in [[ stage_in ]]) {
    return vertex_in.position;
}

fragment float4 fragment_main() {
    return float4(0, 1, 0, 1);
}

