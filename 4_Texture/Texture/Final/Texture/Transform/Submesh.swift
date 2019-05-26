//
//  Submesh.swift
//  Transform
//
//  Created by Kira on 2019/2/22.
//  Copyright © 2019 Kira. All rights reserved.
//

import MetalKit

class Submesh {
    struct Textures {
        let baseColor : MTLTexture?
    }
    let textures : Textures
    var submesh: MTKSubmesh
    
    init(submesh: MTKSubmesh, mdlSubmesh: MDLSubmesh) {
        self.submesh = submesh
        self.textures = Textures.init(material: mdlSubmesh.material)
    }
}

extension Submesh : Texturable {
    
}

// Textures 的 init 函数
private extension Submesh.Textures {
    init(material: MDLMaterial?) {
        func property(with semantic:MDLMaterialSemantic) -> MTLTexture? {
            guard let property = material?.property(with: semantic),
            property.type == .string,
            let filename = property.stringValue,
            let texture = try? Submesh.loadTexture(imageName: filename)
            else {
                return nil
            }
            return texture
        }
        baseColor = property(with: MDLMaterialSemantic.baseColor)
    }
}
