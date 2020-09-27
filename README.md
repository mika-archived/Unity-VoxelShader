# Voxel Shader for Unity and VRChat

Mesh Voxelization Shader for Unity and VRChat.

## Limitations

This shader owns pretty mush the same features as Natsuneko uses in VRChat, but there are a few differences to be exact.

## Requirements

- Unity 2018.4.20f1
- GPU that supporting Geometry Shader Stage

## Installation (Not Yet Provided)

1. Download UnityPackage from BOOTH (Recommended)
2. Install via NPM Scoped Registry

### Download UnityPackage

You can download latest version of UnityPackage from BOOTH (Not Yet Provided).  
Extract downloaded zip package and install UnityPackage into your project.

### Install via NPM

Please add the following section to the top of the package manifest file (`Packages/manifest.json`).  
If the package manifest file already has a `scopedRegistries` section, it will be added there.

```json
{
  "scopedRegistries": [
    {
      "name": "Mochizuki",
      "url": "https://registry.npmjs.com",
      "scopes": ["moe.mochizuki"]
    }
  ]
}
```

And the following line to the `dependencies` section:

```json
"moe.mochizuki.voxel-shader": "VERSION"
```

## How to use (Documentation / Japanese)

https://docs.mochizuki.moe/Unity/VoxelShader/ (Not Yet Provided)

## License

MIT by [@MikazukiFuyuno](https://twitter.com/MikazukiFuyuno) and [@6jz](https://twitter.com/6jz)
