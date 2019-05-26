//
//  Texturable.swift
//  Transform
//
//  Created by 沙琪玛 on 2019/5/26.
//  Copyright © 2019 Kira. All rights reserved.
//

import MetalKit

protocol Texturable {}

extension Texturable {
    static func loadTexture(imageName: String) throws -> MTLTexture? {
        //5
        let textureLoader = MTKTextureLoader(device: Renderer.device)
        
        //6
        let textureLoaderOptions : [MTKTextureLoader.Option : Any] =
            [.origin:
                MTKTextureLoader.Origin.bottomLeft]
        
        //7
        let fileExtension = URL(fileURLWithPath: imageName).pathExtension.isEmpty ? "png" : nil
        
        //8
        guard let url = Bundle.main.url(forResource: imageName, withExtension: fileExtension) else {
            print("Failed to load")
            return nil
        }
        
        let texture = try textureLoader.newTexture(URL: url, options: textureLoaderOptions)
        print("loaded texture")
        return texture;
    }
}
