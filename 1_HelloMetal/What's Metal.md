#啥是馒头(Metal)

## What's Metal

> The Metal framework supports GPU-accelerated advanced 3D graphics rendering and data-parallel computation workloads.

- Metal 框架是一套专门给图形处理器(GPU)定制的API。它可以尽可能发挥GPU的3D图形渲染以及并行数据计算能力。Metal 给开发者提供的是非常底层的可以操作到GPU的接口，并且，Metal 对数据的并行计算能力以及对资源的预编译能力可以极大的减少CPU的负担。所以 Metal 同时具备了 low-level 和 low-overhead 的特点。

## Why Metal

>Deprecation of OpenGL and OpenCL
Apps built using OpenGL and OpenCL will continue to run in macOS 10.14, but these legacy technologies are deprecated in macOS 10.14. Games and graphics-intensive apps that use OpenGL should now adopt Metal. Similarly, apps that use OpenCL for computational tasks should now adopt Metal and Metal Performance Shaders.

- 在 MacOS 10.14 的更新文档中，苹果表示使用 OpenGL 和 OpenCL 构建的应用可以继续在 macOS 10.14 中运行，但这些遗留技术在 macOS 10.14 中不推荐使用。现在使用 OpenGL 的游戏和应用应转向 Metal。总体来说，苹果爸爸已经表示要弃用 OpenGL/CL，并且推荐使用 Metal 作为替代。


## Where Metal

- Metal 作为一个能够高效地利用 GPU 对数据的并行处理能力以及对数据的图形化接口，它可以解决很多由于高计算量带来的问题。在机器学习、图像视频处理以及图形渲染领域，Metal 都能发挥出它的优势。

- 当你遇到以下的情况时，Metal 也许是你最好的选择：

1. 你想要尽可能高效的渲染3D模型
2. 你想要在处理图像或者视频的时候，类似对每一帧每一个像素进行数据集中处理的情况。
3. 你碰到一些数据量很大的计算问题时，可以运用 Metal 的高并发处理能力，将数据量分解为很多子数据集进行处理。
4. 你想要在自己的游戏中制作一些独特的效果，比如自定义 shading 和 lighting。

## Hello Metal
在我们学习一门编程语言的时候，往往第一句代码就是打印 "Hello world" 字符串。那么作为渲染框架的入门第一课，学会在界面上渲染出第一个三角形是最合适不过的了。

首先我们来介绍一下使用 Metal 来渲染一个模型的大致流程：
Initialize Metal -> Load Model -> Set up pipeline -> Render

直接上手，我们先从创建一个新的项目 HelloMetal 开始，选择iOS开发平台，语言用 swift。

### Initialize Metal

在 ViewController 中将 MetalKit 框架导入

```
import MetalKit
```
声明 MTLDevice 属性 device，在 viewdidload 中初始化device。

```
var device: MTLDevice!
```

```
device = MTLCreateSystemDefaultDevice()
```

你可以理解 MTLDevice 为你和GPU的直接连接的一个抽象。你将通过使用 MTLDevice 创建所有其他你需要的Metal对象（像是command queues，buffers，textures）。

    PS:注意如果是在 iOS 的模拟器环境下，是取不到 device 的

随后初始化 MTKView 供显示渲染后的图像

```
let frame = CGRect(x: 0, y: 0, width: self.view.frame.size.width , height:self.view.frame.size.height)
let view = MTKView(frame: frame, device: device)
view.clearColor = MTLClearColor(red: 1, green: 1, blue: 0.8, alpha: 1)
self.view.addSubview(view)
```

MTKView 是 UIView 的一个子类，用于在 Metal 中展示渲染结果，同时提供一些方便的属性和代理。

设置 clearColor 使得 view 的默认背景被 clearcolor 填充。

### Load Model
由于现在要绘制的是一个平面三角形，所以这里简单地 hardcode 三角形的顶点数据作为数据源，后续会介绍如何通过 Model I/O 框架来 load 基本 3D 模型，以及加载 obj 模型。

首先添加声明一个顶点的常量数组以及声明 一个 MTLBuffer 变量
vertexBuffer。

```
let vertexData: [Float] = [
        0.0, 1.0, 0.0,
        -1.0, -1.0, 0.0,
        1.0, -1.0, 0.0
    ]
    
var vertexBuffer: MTLBuffer!

```
然后在 viewdidload 中接着初始化 vertexBuffer

```
let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options:[])
```

### Set up pipeline
#### pipeline 渲染管线
在上手写 pipeline 相关的代码之前，我们先来简单了解一下什么是 pipeline，更加详细的针对 pipeline 的解说会在后续教程中给出。

pipeline 就是渲染管线，是在渲染处理过程中顺序执行的一系列操作。这一套渲染流程在理论层面上都是统一的，所以不论是 OpenGL ES 的渲染管线还是 Metal 的渲染管线，在理解上都是相同的。pipeline 来源于生产车间的流水线作业，在渲染过程中，一个操作接一个操作进行，就如同流水线一样，这样的实现可以极大地提高渲染效率。整个渲染管线如同下图所示：

![pipeline.png](https://github.com/shaqima123/Resource/raw/master/WhatsMetal/pipeline.png)

渲染管线的大致流程为：顶点数据来源 -> 顶点着色器 -> 图元装配 ->
光栅化 -> 片元着色器 -> 拿到FrameBuffer 

图中标红的 Vertex Proccesing 和 Fragment Proccessing 是可编程管线，一般是通过写着色器语言(Shader Language)脚本实现。在 Metal 中使用的 Metal Shading Language，同样也是 C++ 的一个子集。

#### queues,buffer and encoders
GPU 渲染出来的每一帧都是通过你发送给 GPU 的指令来生成的。在 Metal 中，每一帧的渲染我们都将用一个 render command encoder 包裹这些相关的指令。而 command buffer 是用于管理这些 encoders，再上一层， command queue 用于管理这些 command buffers。

在整个渲染过程中，只需要创建一个 command queue 来管理 command buffers，以及上文提到过的 device、vertex buffer 也只需要创建一次。还有顶点着色器、片元着色器、pipelineState 都是。需要多次创建的是那些和帧的变化具备强关联的东西，比如 command buffer，command encoder。每一帧的渲染都需要 encoder 去设置pipelineState，去设置 vertex buffer 以及绘制指令。

![pipeline2.png](https://github.com/shaqima123/Resource/raw/master/WhatsMetal/pipeline2.png)

#### shader
shader 是运行在GPU上的脚本，它是 C++ 的一种子集语言。一般来说我们可以在 xcode 中创建 .metal 格式的 shader 脚本文件，但是其实直接在主文件中将 shader 以 string 的形式赋值保存也可以。以下就是两个最简单的 shader 函数，顶点处理器 vertex_main 以及片元处理器 fragment_main：

```
let shader = """
#include <metal_stdlib>
using namespace metal;

vertex float4 vertex_main(constant packed_float3* vertex_array[[buffer(0)]],
unsigned int vid[[vertex_id]]) {
return float4(vertex_array[vid], 1.0);
}

fragment float4 fragment_main() {
return float4(0, 1, 0, 1);
}
"""
```
简单来讲，顶点处理器顾名思义就是对CPU传输过来的顶点数据做处理，当然也可以什么都不做，直接返回，就和这里的 vertex_main 一样。而片元处理器是用来确定一个像素的着色，它决定了像素的颜色表现。

然后我们通过这个 shader 的 string 或者 .metal 文件来初始化两个函数，并将它们设置给一个渲染管道描述器（renderPipelineDescriptor），用于后续初始化 pipelineState。


```
 let library = try! device.makeLibrary(source: shader, options: nil)
        let vertexFunction = library.makeFunction(name: "vertex_main")
        let fragmentFunction = library.makeFunction(name: "fragment_main")
        
```

#### pipeline state

在 Metal 中，我们需要给 GPU 设置渲染管线状态，以此告诉 GPU 在 pipeline state 发生改变之前，其他的都不会有变化，从而使 GPU 的工作更加高效。pipelineState 包含了所有 GPU 需要知道的信息，包括像素格式以及刚刚创建的 shader 函数等。pipeline state 是通过一个 pipeline descriptor 创建的，我们可以通过设置 descriptor 的相关属性来改变 pipeline state。

```
 let pipelineDescriptor = MTLRenderPipelineDescriptor()
 pipelineDescriptor.vertexFunction = vertexFunction
 pipelineDescriptor.fragmentFunction = fragmentFunction
 pipelineDescriptor.colorAttachments[0].pixelFormat = .bgra8Unorm

 pipelineState = try! device.makeRenderPipelineState(descriptor: pipelineDescriptor)
```

这里需要注意的一点是，创建一个 pipelineState 是耗时的操作，所以我们应该一次性创建 pipelineState。在实际项目中，或许我们需要一次性创建多个 pipelineState 以调用不同的 shader 函数，或者使用不同的顶点布局等等。

### Render

终于到了渲染这步，从这一步开始，我们所写的代码针对的是每一帧的渲染，也就是每一帧都要调用这部分的代码。

MTKView 的一个代理方法 public func draw(in view: MTKView) 会在每一帧绘制的时候进行调用，所以一般来说，我们可以在这个代理中去绘制每一帧的内容。但是本节的需求只是绘制一个不会动的三角形，所以没有必要每帧渲染，直接在 viewdidload 中接着往下写。

```
guard let commandBuffer = commandQueue.makeCommandBuffer(),
let descriptor = view.currentRenderPassDescriptor,
let renderEncoder = commandBuffer.makeRenderCommandEncoder(descriptor: descriptor) else { 
             fatalError() 
             }
            
```

在这里，我们通过 commandQueue 创建 commandBuffer。commandBuffer 中保存着这一帧中所有你需要让 GPU 给你渲染的指令。
同时，我们创建了一个 renderPassDescriptor，用于 commandEncoder 的创建。

接下来，我们需要给 commandEncoder 设置当前的 pipelineState，告诉 GPU 有关像素格式以及 shader 函数等信息已经包含在这个 pipelinestate 中了，在 state 发生改变之前，以上的信息都不会有任何变化，你放心地去处理渲染。 

```
renderEncoder.setRenderPipelineState(pipelineState)

```
然后给 commandEncoder 设置顶点数据，这里的顶点数据就是上文创建的 vertexbuffer，告诉它需要处理的顶点数据来自哪里。

```
renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
```
最后是要 draw 的部分了

```
renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
```
在这一步告诉 GPU 的是，去将那些顶点数据按照给出的顶点顺序数目渲染成一个三角形。当然，这一步也不是真正的渲染，在 GPU 接收到所有的 commandbuffer 的指令之后，它才会去做真正的渲染过程。

```
//1
renderEncoder.endEncoding() 
//2
guard let drawable = view.currentDrawable else {
            fatalError()
        } 
// 3    
commandBuffer.present(drawable)
commandBuffer.commit()
```
步骤1 告诉 renderEncoder 已经没有更多的指令了，步骤2 是从 MTKView 中拿到一个 CAMetalDrawable 类实例，这个 drawable 持有着一个可供 Metal 读写的可绘制 texture。步骤3 就是要求 commandBuffer 将指令提交给 GPU 并且将结果渲染展示到 drawable 上面。这一步触发了真正的渲染，编译运行代码可以看到在屏幕上出现了一个全屏的绿色三角形，而背景部分则是被 clearColor 覆盖的米黄色。
如图所示：

![result.png](https://github.com/shaqima123/Resource/raw/master/WhatsMetal/triangle.PNG)

通过绘制一个简单的三角形我们熟悉了 Metal 渲染的整体流程，这也是学习 Metal 的第一步而已，后续会继续介绍更多有关 Metal、图形学以及线代方面的东西。下一章主要介绍 3D 模型的渲染以及详细的 render pipeline 渲染管线工作流程。

### Demo地址
[点击查看 Whats Metal 第一节Demo](https://github.com/shaqima123/Whats-Metal)

