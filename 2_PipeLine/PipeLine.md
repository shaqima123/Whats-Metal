#啥是馒头(Metal)

## 导入 3D 模型
### .obj文件
obj 文件是一种 3D 模型文件格式，一些基本介绍可以自行谷歌。在这里我们主要就是介绍一下 obj 文件内部用于存储顶点数据的方式。我们用文本编辑器打开一个 obj 文件后将会看到类似以下的一些数据：

```
# Apple ModelIO OBJ File: plane
mtllib plane.mtl
g submesh
v 0 0.5 -0.5
v 0 -0.5 -0.5
v 0 -0.5 0.5
v 0 0.5 0.5
vn -1 0 0
vt 1 0
vt 0 0
vt 0 1
vt 1 1
usemtl material_1
f 1/1/1 2/2/1 3/3/1
f 1/1/1 3/3/1 4/4/1
s off
```
第一行是描述文件名，没有实际用处，相当于注释。
mtllib 标注的是该 obj 文件配对的 .mtl 文件的文件名。obj 文件主要记录顶点数据，而 mtl 文件主要用于保存材质和纹理图片数据。

g 就是 group 的缩写，表示一组顶点数据

v 就是 vertex 的缩写，表示单个顶点数据，有多少个 v 的数据就表示存在多少个顶点。

vn 是指 surface normal，面的法向量。

vt 是纹理的 uv 坐标数据，纹理坐标一般使用 uv 坐标系而不是 xy 坐标系。

usemtl 标注的是使用材质的文件名，这个材质的定义保存在 .mtl 文件中。
f 就是 face 的缩写，表示的是一个面。它的数据结构由 v/vt/vn 组成，如 1/1/1 代表的就是 第一个顶点数据/第一个纹理数据/第一个法向量数据，0 0.5 -0.5 / 1 0 / -1 0 0。

s 是 smoothing 的缩写，用于表示表面是否平滑，当前是关闭状态。

### .mtl 文件
mtl 文件保存了模型的材质信息，比如如何渲染模型的顶点，该给它什么样的颜色，是否需要光照反射等等。用文本编辑器打开 mtl 文件的时候同样可以看到一组特殊格式的数据集合。

```
# Apple ModelI/O MTL File: primitive.mtl
newmtl material_1
    Kd 1 1 1
    Ka 0 0 0
    Ks 0
    ao 0
    subsurface 0
    metallic 0
    specularTint 0
    roughness 0.9
    anisotropicRotation 0
    sheen 0.05
    sheenTint 0
    clearCoat 0
    clearCoatGloss 0
```

newmtl 表示一组新的材质数据，可以定义它的颜色光照纹理反射等描述特征。

Kd Ka Ks 是反射描述的三种格式，分别是指漫反射、环境反射、镜面反射。三种反射描述都可以用 RGB 来表示，如 Kd 1 1 1 就是指漫反射光照描述为白色。

当然还有其他很多属性用于描述特征，这里不一一列出了，想了解更多可以直接谷歌 mtl 文件格式详解。

### 导入 3d 模型
在本节的 Resource 文件夹下有我们将要使用到的 3d 模型文件。这个是我用 Blender 制作的一个简单猴子模型，在文件夹中包含 obj 文件，mtl 文件，乱画的纹理贴图以及 blender 的工程文件。当然你也可以自己制作或者从网上搞其他的模型文件导入，这不重要。

打开 Start 文件夹下的 xcode 工程文件，这里和上节有所不同的是不再将所有代码都放在 viewdidload 中，而是把不同职能的代码封装到不同的类中去。其中 Renderer 类负责渲染相关的职能，shaders 文件是后缀为 .metal 的 shader 文件，它是 metal 中专门用来编写 shader 脚本的文件格式。Model 类是模型类，负责 3d 模型的导入工作。

在 Renderer 类的 extension 中，我们遵循了 MTKViewDelegate 协议。在其中的 draw 方法中我们将上节中提到的每一帧都需要创建的 commandbuffer 等代码放在了此处。运行一下工程，就可以得到和上一章节一模一样的原谅色三角形。

**本节正片开始**

在 Model 类中，加入以下代码

```
    class func monkey(device: MTLDevice) -> MDLMesh {
        let allocator = MTKMeshBufferAllocator(device: device)
        guard let assetURL = Bundle.main.url(forResource: "monkey", withExtension: "obj") else {
            fatalError()
        }
        
    }
```

该方法是 Model 的一个类方法，待会儿我们可以通过调用该方法拿到我们的 monkey 模型。首先我们初始化了 obj 文件所在的路径。

#### 顶点描述器
在 metal 中，我们通过使用顶点描述器来创建一个物体。就和上一章节中通过 pipelineDescriptor 创建 pipelineState 一样，创建物体需要使用 vertex descriptor。顶点描述器可以告诉 metal 在加载这个物体之前，如何去布局那些顶点数据，包括顶点位置、纹理坐标等等。比如我们拿到的顶点数据是 0 1 0 -1 0 0 0.5 0.5。这是一个顶点的相关数据，那么在 metal 直接拿到这么一组数据的时候，它是懵逼的。这些数据表示的是什么意思？我要怎么使用它们呢？通过顶点描述器我们可以告诉 metal ，比如前三个数据 0 1 0 是指 position，表示顶点的三维坐标，接着 -1 0 0 是该点的法向量，然后 0.5 0.5 是纹理坐标。那么 metal 在拿到这组顶点数据后，就可以将该顶点正确地渲染出来。

接着在 monkey 方法最下方添加以下代码：

```
let vertexDescriptor = MTLVertexDescriptor()
vertexDescriptor.attributes[0].format = .float3
vertexDescriptor.attributes[0].offset = 0
vertexDescriptor.attributes[0].bufferIndex = 0
```
在这里我们写了顶点描述器的配置代码，这里需要配置所有你要创建一个物体所需要的属性。一份完整的顶点数据会包含顶点位置，纹理坐标，表面法向量等等信息，但是暂时我们只需要顶点位置信息，其他的在后续章节中再提。一个顶点描述器维护了一个属性的队列，最多可以描述 31 种不同的属性（attribute）。

在这里的配置中，我们告诉描述器顶点的位置信息是用 float3	数据结构描述的，然后这个数据从 offset 为 0 的地方开始获取。最后设置 bufferIndex 为 0 的意思是告诉 GPU 该 buffer 的索引是 0 。什么意思呢？ 当我们通过 render encoder 将顶点数据发送给 GPU 的时候，我们是通过 MTLBuffer 的数据结构发送的，而这个 MTLBuffer 是需要用 index 去标记区分的。Metal 维护了一张 buffer argument table 来跟踪这些属性，最多可以有 31 种 buffer 的存在。所以，用 index 0 可以告诉顶点着色器，使用 buffer 0 来匹配将传送过来的数据并用于顶点布局。

在这之后，加上以下代码：

```
//1
vertexDescriptor.layouts[0].stride = MemoryLayout<float3>.stride

//2
let meshDescriptor =
MTKModelIOVertexDescriptorFromMetal(vertexDescriptor)

//3
(meshDescriptor.attributes[0] as! MDLVertexAttribute).name =
           MDLVertexAttributePosition
```

1. 表示 buffer 0 的读取数据步长，这个步长指的是所有有关顶点信息的数据长度，由于这里我们只关心顶点的位置信息，所以步长只需要一个 float3
的长度。但是如果我们需要纹理数据，法向量数据的话，正和上面提到过的一样，这个步长就得是 float3 + float3 + float2 的步长了。

2. 通过顶点描述器创建一个网格描述器。
3. 告诉网格描述器这是一组顶点位置数据，给网格描述器的属性0赋值 name 为 MDLVertexAttributePosition。

最后加上以下代码：

```
let asset = MDLAsset(url: assetURL,
                     vertexDescriptor: meshDescriptor,
                     bufferAllocator: allocator)
let mdlMesh = asset.object(at: 0) as! MDLMesh
return mdlMesh
```

我们通过模型的路径，网格描述器以及内存创建器拿到一个 MDLAsset，然后通过这个 asset 我们就可以拿到网格数据了。注意一个 asset 中可能存在多个网格，这里我们先只返回第一个 mesh 用于展示。

然后我们回到 Renderer 类，需要作出一些修改。首先去掉之前硬编码的顶点数据及相关代码：

```
	//1
   let vertexData: [Float] = [
        0.0, 1.0, 0.0,
        -1.0, -1.0, 0.0,
        1.0, -1.0, 0.0
    ]
    //2
    var vertexBuffer: MTLBuffer!

	//3
    let dataSize = vertexData.count * MemoryLayout.size(ofValue: vertexData[0])
    vertexBuffer = device.makeBuffer(bytes: vertexData, length: dataSize, options:[])
        
```
然后在 Renderer 类中，//1 处初始化一个 MDLMesh，并且在顶部声明一个 MTKMesh 属性，我们在绘制的时候需要用到的是 MTKMesh，MTKMesh 可以由 MDLMesh 初始化得到。

```
//1
let mdlMesh = Model.monkey(device: device)
mesh = try! MTKMesh(mesh: mdlMesh, device: device)
```

在 //2 处加入以下代码,告诉 pipelineDescriptor 使用 mesh 的顶点描述器。

```//2

pipelineDescriptor.vertexDescriptor = MTKMetalVertexDescriptorFromModelIO(mesh.vertexDescriptor)

```

在去掉硬编码的顶点数据后我们会发现在 //3 的地方产生了报错，在这里将原来的代码

```
renderEncoder.setVertexBuffer(vertexBuffer, offset: 0, index: 0)
```
移除，替换为

```
renderEncoder.setVertexBuffer(mesh.vertexBuffers[0].buffer,
                                      offset: 0, index: 0)
```
告诉 renderEncoder 不再使用硬编码的顶点数据，新的顶点数据从 mesh 中获取。

//4 将原来的绘制代码改为遍历 mesh 中的 submesh 并逐个绘制

```
renderEncoder.drawPrimitives(type: .triangle, vertexStart: 0, vertexCount: 3, instanceCount: 1)
```
移除，替换为

```
for submesh in mesh.submeshes {
            renderEncoder.drawIndexedPrimitives(type: .triangle,
                                                indexCount: submesh.indexCount,
                                                indexType: submesh.indexType,
                                                indexBuffer: submesh.indexBuffer.buffer,
                                                indexBufferOffset: submesh.indexBuffer.offset
            )
        }
```

最后，需要修改一下之前的 shader 文件,告诉顶点着色器只处理顶点位置信息。

```
#include <metal_stdlib>
using namespace metal;

struct VertexIn {
    float4 position [[ attribute(0) ]];
};

vertex float4 vertex_main(const VertexIn vertex_in [[ stage_in ]]) {
    return vertex_in.position;
}

fragment float4 fragment_main() {
    return float4(0, 1, 0, 1);
}

```

编译运行，我们就可以看到如下惨不忍睹的模型 T T。

![result.png](https://i.loli.net/2019/02/10/5c5ff98b176b1.png)

- 到这一步其实模型已经成功导入。由于模型太大以及位置的关系，导致看得不是很清晰。后续在介绍完坐标空间之后，我们可以将整个模型按合适的尺寸显示在我们的屏幕上。现在的模型呈现的形式只是网格的样式，在介绍了纹理和贴图之后我们就可以展示一个完整的模型了～。

### Demo地址
[点击查看 Whats Metal 第二节 导入3D模型 Demo](https://github.com/shaqima123/Whats-Metal/tree/master/2_PipeLine)
