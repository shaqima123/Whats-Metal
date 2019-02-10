//
//  Model.swift
//  PipeLine
//
//  Created by Kira on 2019/2/10.
//  Copyright © 2019 Kira. All rights reserved.
//

import MetalKit

class Model {
    class func monkey(device: MTLDevice) -> MDLMesh {
        let allocator = MTKMeshBufferAllocator(device: device)
        guard let assetURL = Bundle.main.url(forResource: "monkey", withExtension: "obj") else {
            fatalError()
        }
        let vertexDescriptor = MTLVertexDescriptor()
        vertexDescriptor.attributes[0].format = .float3
        vertexDescriptor.attributes[0].offset = 0
        vertexDescriptor.attributes[0].bufferIndex = 0
        
        vertexDescriptor.layouts[0].stride = MemoryLayout<float3>.stride
        
        let meshDescriptor =
            MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)
        
        (meshDescriptor.attributes[0] as! MDLVertexAttribute).name =
        MDLVertexAttributePosition
        
        let asset = MDLAsset(url: assetURL,
                             vertexDescriptor: meshDescriptor,
                             bufferAllocator: allocator)
        let mdlMesh = asset.object(at: 0) as! MDLMesh
        
        return mdlMesh
    }
}

