//
//  Model.swift
//  PipeLine
//
//  Created by Kira on 2019/2/10.
//  Copyright © 2019 Kira. All rights reserved.
//

import MetalKit

class Model:Node {
    
    static var defaultVertexDescriptor: MDLVertexDescriptor = {
        let vertexDescriptor = MDLVertexDescriptor()
        vertexDescriptor.attributes[0] = MDLVertexAttribute(name: MDLVertexAttributePosition,
                                                            format: .float3,
                                                            offset: 0, bufferIndex: 0)

        vertexDescriptor.layouts[0] = MDLVertexBufferLayout(stride: 12)
        return vertexDescriptor
    }()
    
    let vertexBuffer: MTLBuffer
    let pipelineState: MTLRenderPipelineState
    let mesh: MTKMesh
    let submeshes: [Submesh]
    
    init(name: String) {
        guard let assetURL = Bundle.main.url(forResource: name, withExtension: "obj") else {
            fatalError()
        }
        let allocator = MTKMeshBufferAllocator(device: Renderer.device)
        let asset = MDLAsset(url: assetURL, vertexDescriptor: Model.defaultVertexDescriptor,
                             bufferAllocator: allocator)
        let mdlMesh = asset.object(at: 0) as! MDLMesh
        
        let mesh = try! MTKMesh(mesh: mdlMesh, device: Renderer.device)
        self.mesh = mesh
        vertexBuffer = mesh.vertexBuffers[0].buffer
        
        submeshes = mdlMesh.submeshes?.enumerated().compactMap {index, submesh in
            (submesh as? MDLSubmesh).map {
                Submesh(submesh: mesh.submeshes[index],
                        mdlSubmesh: $0)
            }
            } ?? []
        
        pipelineState = Model.buildPipelineState(vertexDescriptor: mdlMesh.vertexDescriptor)
        super.init()
    }
    
    
    private static func buildPipelineState(vertexDescriptor: MDLVertexDescriptor) -> MTLRenderPipelineState {
        let library = Renderer.library
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction = library?.makeFunction(name: "fragment_main")
        
        var pipelineState: MTLRenderPipelineState
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(vertexDescriptor)
        pipelineDescriptor.colorAttachments[0].pixelFormat = Renderer.colorPixelFormat

        do {
            pipelineState = try Renderer.device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            fatalError(error.localizedDescription)
        }
        return pipelineState
    }
}

