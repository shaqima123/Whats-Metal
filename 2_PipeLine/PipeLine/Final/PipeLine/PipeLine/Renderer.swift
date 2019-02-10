//
//  Renderer.swift
//  PipeLine
//
//  Created by Kira on 2019/2/10.
//  Copyright © 2019 Kira. All rights reserved.
//

import MetalKit

class Renderer: NSObject {
    
    static var device: MTLDevice!
    static var commandQueue: MTLCommandQueue!
    
    var pipelineState: MTLRenderPipelineState!
    var mesh: MTKMesh!
    
    init(metalView: MTKView) {
        guard let device = metalView.device else {
            fatalError("GPU not available!")
        }
        Renderer.device = device
        Renderer.commandQueue = device.makeCommandQueue()!
        
        //1
        let mdlMesh = Model.monkey(device: device)
        mesh = try! MTKMesh(mesh: mdlMesh, device: device)
        
        let library = device.makeDefaultLibrary()
        let vertexFunction = library?.makeFunction(name: "vertex_main")
        let fragmentFunction = library?.makeFunction(name: "fragment_main")
        
        let pipelineDescriptor = MTLRenderPipelineDescriptor()
        pipelineDescriptor.vertexFunction = vertexFunction
        pipelineDescriptor.fragmentFunction = fragmentFunction
        pipelineDescriptor.colorAttachments[0].pixelFormat = metalView.colorPixelFormat
        
        //2
        pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)
        
        do {
            pipelineState = try device.makeRenderPipelineState(descriptor: pipelineDescriptor)
        } catch let error {
            fatalError(error.localizedDescription)
        }
        
        super.init()
        metalView.clearColor = MTLClearColor(red: 1.0, green: 1.0,
                                             blue: 0.8, alpha: 1)
        metalView.delegate = self
    }
    
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
    }
    
    func draw(in view: MTKView) {
        guard let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
            let descriptor = view.currentRenderPassDescriptor,
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
            else {
                fatalError()
        }
        
        renderEncoder.setRenderPipelineState(pipelineState)
        //3
        renderEncoder.setVertexBuffer(mesh.vertexBuffers[0].buffer,
                                      offset: 0, index: 0)
        renderEncoder.setTriangleFillMode(.lines)

        //4
        
        for submesh in mesh.submeshes {
            renderEncoder.drawIndexedPrimitives(type: .triangle,
                                                indexCount: submesh.indexCount,
                                                indexType: submesh.indexType,
                                                indexBuffer: submesh.indexBuffer.buffer,
                                                indexBufferOffset: submesh.indexBuffer.offset
            )
        }

        
        renderEncoder.endEncoding()
        
        guard let drawable = view.currentDrawable else {
            fatalError()
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}
