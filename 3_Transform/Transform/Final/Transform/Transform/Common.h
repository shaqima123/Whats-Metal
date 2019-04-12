//
//  Common.h
//  Transform
//
//  Created by Kira on 2019/2/22.
//  Copyright © 2019 Kira. All rights reserved.
//

#ifndef Common_h
#define Common_h

#import <simd/simd.h>

typedef struct {
    matrix_float4x4 modelMatrix;
    matrix_float4x4 viewMatrix;
    matrix_float4x4 projectionMatrix;
    matrix_float3x3 normalMatrix;
} Uniforms;

typedef struct {
    vector_float3 cameraPosition;
} FragmentUniforms;

#endif /* Common_h */
