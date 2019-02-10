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

