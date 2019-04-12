//
//  ViewController.swift
//  Transform
//
//  Created by Kira on 2019/2/22.
//  Copyright © 2019 Kira. All rights reserved.
//

import UIKit
import MetalKit

class ViewController: UIViewController {

    var renderer: Renderer?
    var device: MTLDevice?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        guard let device = MTLCreateSystemDefaultDevice() else {
            fatalError("there is no device to use")
        }
        self.device = device
        let frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width, height: self.view.frame.size.height)
        let view = MTKView(frame: frame, device: self.device)
        self.view.addSubview(view)
        
        renderer = Renderer(metalView: view)
        addGestureRecognizer(to: view)
    }


}

