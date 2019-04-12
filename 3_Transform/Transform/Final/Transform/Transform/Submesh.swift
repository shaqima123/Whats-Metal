//
//  Submesh.swift
//  Transform
//
//  Created by Kira on 2019/2/22.
//  Copyright © 2019 Kira. All rights reserved.
//

import MetalKit

class Submesh {
    var submesh: MTKSubmesh
    
    init(submesh: MTKSubmesh, mdlSubmesh: MDLSubmesh) {
        self.submesh = submesh
    }
}
