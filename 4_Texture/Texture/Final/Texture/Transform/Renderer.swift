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
    static var colorPixelFormat: MTLPixelFormat!
    static var library: MTLLibrary?

    var uniforms = Uniforms()
    var fragmentUniforms = FragmentUniforms()
    
    lazy var camera: Camera = {
        let camera = Camera()
        camera.position = [0, 0.5, -3]
        return camera
    }()
    
    var models: [Model] = []

    
    var pipelineState: MTLRenderPipelineState!
    var mesh: MTKMesh!
    
    init(metalView: MTKView) {
        guard let device = metalView.device else {
            fatalError("GPU not available!")
        }
        Renderer.device = device
        Renderer.commandQueue = device.makeCommandQueue()!
        Renderer.colorPixelFormat = metalView.colorPixelFormat
        Renderer.library = device.makeDefaultLibrary()
        
        super.init()
        metalView.clearColor = MTLClearColor(red: 0.8, green: 0.88,
                                             blue: 1.0, alpha: 1)
        metalView.delegate = self
        mtkView(metalView, drawableSizeWillChange: metalView.bounds.size)
        
        let monkey = Model.init(name: "monkey")
        monkey.position = [0, 0, 0]
        models.append(monkey)
        
    }
    
}

extension Renderer: MTKViewDelegate {
    func mtkView(_ view: MTKView, drawableSizeWillChange size: CGSize) {
        camera.aspect = Float(view.bounds.width)/Float(view.bounds.height)
    }
    
    func draw(in view: MTKView) {
        guard let commandBuffer = Renderer.commandQueue.makeCommandBuffer(),
            let descriptor = view.currentRenderPassDescriptor,
            let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor)
            else {
                fatalError()
        }
        
        fragmentUniforms.cameraPosition = camera.position
        uniforms.projectionMatrix = camera.projectionMatrix
        uniforms.viewMatrix = camera.viewMatrix
        
        for model in models {
            uniforms.modelMatrix = model.modelMatrix
            
            renderEncoder.setVertexBytes(&uniforms,
                                         length: MemoryLayout<Uniforms>.stride, index: 1)
            
            renderEncoder.setRenderPipelineState(model.pipelineState)
            renderEncoder.setVertexBuffer(model.vertexBuffer, offset: 0, index: 0)
            //9
            for modelSubmesh in model.submeshes {
                renderEncoder.setFragmentTexture(modelSubmesh.textures.baseColor, index: Int(BaseColorTexture.rawValue))
                let submesh = modelSubmesh.submesh
                renderEncoder.drawIndexedPrimitives(type: .triangle,
                                                    indexCount: submesh.indexCount,
                                                    indexType: submesh.indexType,
                                                    indexBuffer: submesh.indexBuffer.buffer,
                                                    indexBufferOffset: submesh.indexBuffer.offset)
            }
        }
        
        renderEncoder.endEncoding()
        
        guard let drawable = view.currentDrawable else {
            fatalError()
        }
        commandBuffer.present(drawable)
        commandBuffer.commit()
    }
}



extension Renderer {
    func zoomUsing(delta: CGFloat, sensitivity: Float) {
        let cameraVector = camera.modelMatrix.upperLeft().columns.2
        camera.position += Float(delta) * sensitivity * cameraVector
    }
    
    func rotateUsing(translation: float2) {
        let sensitivity: Float = 0.01
        camera.position = float4x4(rotationY: -translation.x * sensitivity).upperLeft() * camera.position
        camera.rotation.y = atan2f(-camera.position.x, -camera.position.z)
    }
}
