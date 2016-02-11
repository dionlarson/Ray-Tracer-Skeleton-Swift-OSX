//
// Ray caster/tracer skeleton code and scene files adapted from starter code
// provided by MIT 6.837 on OCW.
//
// All additional code written by Dion Larson unless noted otherwise.
//
// Original skeleton code available for free with here (assignments 4 & 5):
// http://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-837-computer-graphics-fall-2012/
//
// Licensed under Creative Commons 4.0 (Attribution, Noncommercial, Share Alike)
// http://creativecommons.org/licenses/by-nc-sa/4.0/
//

import Foundation
import simd

let SMOOTH_ALL = true

class Scene {
    
    private(set) var camera: Camera
    let lights: [Light]
    let materials: [Material]
    private(set) var group: Group
    private(set) var backgroundColor: vector_float3
    private(set) var ambientLight: vector_float3
    
    init(camera: Camera, lights: [Light], backgroundColor: vector_float3, ambientLight: vector_float3, materials: [Material], group: Group) {
        self.camera = camera
        self.lights = lights
        self.backgroundColor = backgroundColor
        if lights.isEmpty {
            print("Warning! No lights defined in the scene. Setting ambient light to white.")
            self.ambientLight = vector_float3(1, 1, 1)
        } else {
            self.ambientLight = ambientLight
        }
        self.materials = materials
        self.group = group
    }
    
    static func parseScene(sceneFile: SceneFile, w: Int, h: Int, useOctree: Bool) throws -> Scene {
        guard let path = NSBundle.mainBundle().URLForResource(sceneFile.rawValue, withExtension: "plist"),
            let data = NSDictionary(contentsOfURL: path) else {
                fatalError("Error reading in scene file! Does it exist?")
        }
        guard let camera = parseCamera(data.objectForKey("Camera"), w: w, h: h) else {
            fatalError("There was a problem with the camera definition!")
        }
        
        guard let lights = parseLights(data.objectForKey("Lights")) else {
            fatalError("There was a problem with the lights definition!")
        }
        
        guard let background = parseBackground(data.objectForKey("Background")) else {
            fatalError("There was a problem with the background definition!")
        }
        
        guard let materials = parseMaterials(data.objectForKey("Materials")) else {
            fatalError("There was a problem with the materials definition!")
        }
        
        let group = parseGroup(data.objectForKey("Group"), materials: materials, useOctree: useOctree)
        
        return Scene(camera: camera, lights: lights, backgroundColor: background.color, ambientLight: background.ambientLight, materials: materials, group: group)
    }
    
    static private func parseCamera(cameraData: AnyObject?, w: Int, h: Int) -> Camera? {
        guard let data = cameraData as? Dictionary<String, String>, let type = data["type"] else {
            return nil
        }
        
        if type == "PerspectiveCamera" {
            let center = readVector3f(data["center"])
            let direction = readVector3f(data["direction"])
            let up = readVector3f(data["up"])
            let angle = degreesToRadians(readFloat(data["angle"]))
            return PerspectiveCamera(center: center, direction: direction, up: up, fieldOfView: angle, w: w, h: h)
        } else {
            fatalError("Camera type is not known!")
        }
    }
    
    static private func parseLights(lightsData: AnyObject?) -> [Light]? {
        guard let data = lightsData as? [Dictionary<String, String>] else {
            return nil
        }
        return data.map(parseLight)
    }
    
    static private func parseLight(data: Dictionary<String, String>) -> Light {
        guard let type = data["type"] else {
            fatalError("There was a problem with one of the lights!")
        }
        let color = readVector3f(data["color"])
        if type == "PointLight" {
            let position = readVector3f(data["position"])
            return PointLight(position: position, color: color)
        }
        if type == "DirectionalLight" {
            let direction = readVector3f(data["direction"])
            return DirectionalLight(direction: direction, color: color)
        }
        fatalError("Light type is not known!")
    }
    
    static private func parseBackground(backgroundData: AnyObject?) ->
        (color: vector_float3, ambientLight: vector_float3)? {
            guard let data = backgroundData as? Dictionary<String, String> else {
                return nil
            }
            let color = readVector3f(data["color"])
            let ambientLight = readVector3f(data["ambientLight"])
            return (color, ambientLight)
    }
    
    static private func parseMaterials(materialsData: AnyObject?) -> [Material]? {
        guard let data = materialsData as? [Dictionary<String, String>] else {
            return nil
        }
        return data.map(parseMaterial)
    }
    
    static private func parseMaterial(data: Dictionary<String, String>) -> Material {
        let diffuseColor = readVector3f(data["diffuseColor"] ?? "1 1 1")
        let specularColor = readVector3f(data["specularColor"] ?? "0 0 0")
        let shininess = readFloat(data["shininess"] ?? "0")
        let texture = data["texture"]
        
        return Material(diffuseColor: diffuseColor, specularColor: specularColor, shininess: shininess, textureName: texture)
    }
    
    static private func parseGroup(groupData: AnyObject?, materials: [Material], useOctree: Bool) -> Group {
        guard let data = groupData as? [Dictionary<String, AnyObject>] else {
            fatalError("There is a problem with the group data!")
        }
        var objects = [Hitable]()
        for objectData in data {
            guard let type = objectData["type"] as? String else {
                fatalError("There was a problem with one of the objects!")
            }
            if let materialIndex = objectData["materialIndex"] as? String {
                let material = materials[readInt(materialIndex)]
                objects.append(parseObject(type, data: objectData, material: material, useOctree: useOctree))
            } else if type == "Group" {
                objects.append(parseGroup(objectData["Group"], materials: materials, useOctree: useOctree))
            } else {
                fatalError("There is a problem with one of the objects!")
            }
            
        }
        return Group(objects: objects)
    }
    
    static private func parseObject(type: String, data: Dictionary<String, AnyObject>, material: Material, useOctree: Bool) -> Hitable {
        if type == "Transform" {
            return parseTransform(data, material: material, useOctree: useOctree)
        }
        guard let data = data as? Dictionary<String, String> else {
            fatalError("There was a problem with one of the objects!")
        }
        switch type {
        case "Plane":
            return parsePlane(data, material: material)
        case "Sphere":
            return parseSphere(data, material: material)
        case "TriangleMesh":
            return parseTriangleMesh(data, material: material, useOctree: useOctree)
        default:
            break
        }
        fatalError("Cannot parse objects of type \(type)!")
    }
    
    static private func parsePlane(objectData: Dictionary<String, String>, material: Material) -> Plane {
        let normal = readVector3f(objectData["normal"])
        let offset = readFloat(objectData["offset"])
        return Plane(normal: normal, d: offset, material: material)
    }
    
    static private func parseSphere(objectData: Dictionary<String, String>, material: Material) -> Sphere {
        let center = readVector3f(objectData["center"])
        let radius = readFloat(objectData["radius"])
        return Sphere(center: center, radius: radius, material: material)
    }
    
    static private func parseTriangleMesh(objectData: Dictionary<String, String>, material: Material, useOctree: Bool) -> TriangleMesh {
        guard let objFile = objectData["objFile"] else {
            fatalError("No obj file specified!")
        }
        
        let texture = material.hasTexture
        var vData = [vector_float3]()
        var tData = [vector_float2]()
        var nData = [vector_float3]()
        var indices = [[(v: Int, n: Int, t: Int)]]()
        
        let bundle = NSBundle.mainBundle()
        guard let url = bundle.URLForResource(objFile, withExtension: "obj") else {
            fatalError("Cannot find \(objFile).obj!")
        }
        do {
            let s = try String(contentsOfURL: url)
            s.enumerateLines({ (line, stop) -> () in
                let data = line.stringByTrimmingCharactersInSet(NSCharacterSet.whitespaceAndNewlineCharacterSet()).componentsSeparatedByString(" ")
                switch data[0] {
                case "v":
                    let v = readVector3f(data[1...3].joinWithSeparator(" "))
                    vData.append(v)
                case "f":
                    let f = data[1..<data.count].map({ parseFaceIndices($0, hasTexture: texture, hasNormal: !nData.isEmpty) })
                    indices.append(f)
                case "vt":
                    let vt = readVector2f(data[1...2].joinWithSeparator(" "))
                    tData.append(vt)
                case "vn":
                    let vn = readVector3f(data[1...3].joinWithSeparator(" "))
                    nData.append(vn)
                default:
                    print("Unknown character \"\(data[0])\" found in \(objFile)!")
                }
            })
        } catch {
            fatalError("Cannot read \(objFile).obj!")
        }
        
        let shouldSmooth = SMOOTH_ALL || vData.count > 25
        
        if shouldSmooth && nData.isEmpty {
            nData = Array<vector_float3>(count: vData.count, repeatedValue: vector_float3(0,0,0))
            for f in indices {
                let a = vData[f[1].v] - vData[f[0].v]
                let b = vData[f[2].v] - vData[f[0].v]
                let normal = cross(a, b)
                for i in 0..<3 {
                    nData[f[i].n] += normal
                }
            }
            
            for i in 0..<nData.count {
                nData[i] = normalize(nData[i])
            }
        }
        
        
        
        var triangles = [Triangle]()
        
        for f in indices {
            let vertices: [(v: vector_float3, n: vector_float3, t: vector_float2)]
            let triangle: Triangle
            if shouldSmooth {
                vertices = f.map({ (v: vData[$0.v], n: nData[$0.n], t: material.hasTexture ? tData[$0.t] : vector_float2()) })
                triangle = Triangle(vertices: vertices, material: material)
            } else {
                vertices = f.map({ (v: vData[$0.v], n: vector_float3(), t: material.hasTexture ? tData[$0.t] : vector_float2()) })
                triangle = Triangle(vertices: vertices, material: material, smoothed: false)
            }
            triangles.append(triangle)
        }
        
        if useOctree {
            return TriangleMesh(triangles: triangles, vertices: vData)
        }
        
        return TriangleMesh(triangles: triangles)
    }
    
    static private func parseFaceIndices(faceData: String, hasTexture: Bool, hasNormal: Bool) -> (v: Int, n: Int, t: Int) {
        let data = faceData.componentsSeparatedByString("/").filter({ (s) -> Bool in
            !(s.isEmpty)
        }).map({readInt($0)-1})
        switch data.count {
        case 1:
            return (v: data[0], n: data[0], t: -1)
        case 2:
            if hasTexture {
                return (v: data[0], n: data[0], t: data[1])
            } else if hasNormal {
                return (v: data[0], n: data[1], t: -1)
            }
        case 3:
            return (v: data[0], n: data[1], t: data[2])
        default:
            break
        }
        
        fatalError("Cannot parse face indices!")
    }
    
    static private func parseTransform(objectData: Dictionary<String, AnyObject>, material: Material, useOctree: Bool) -> Transform {
        guard let transforms = objectData["transforms"] as? [String], let transformed = objectData["transformed"] as? Dictionary<String, String>, let type = transformed["type"] else {
            fatalError("Transform is not formatted correctly!")
        }
        
        var m = matrix_float4x4.identity()
        
        for t in transforms {
            let tData = t.componentsSeparatedByString(" ")
            let floats = tData[1..<tData.count].map(readFloat)
            switch tData[0] {
            case "scale":
                m = m * matrix_float4x4.scaling(x: floats[0], y: floats[1], z: floats[2])
            case "uniformScale":
                m = m * matrix_float4x4.uniformScaling(floats[0])
            case "translate":
                m = m * matrix_float4x4.translation(x: floats[0], y: floats[1], z: floats[2])
            case "xRotate":
                m = m * matrix_float4x4.rotationX(degreesToRadians(floats[0]))
            case "yRotate":
                m = m * matrix_float4x4.rotationY(degreesToRadians(floats[0]))
            case "zRotate":
                m = m * matrix_float4x4.rotationZ(degreesToRadians(floats[0]))
            case "rotate":
                m = m * matrix_float4x4.rotation(vector_float3(floats[0], floats[1], floats[2]), radians: degreesToRadians(floats[3]))
            default:
                fatalError("Encountered \(tData) while parsing transform and not sure how to procede...")
            }
        }
        
        return Transform(object: parseObject(type, data: transformed, material: material, useOctree: useOctree), transform: m)
    }
    
}



private func readInt(data: String?) -> Int {
    guard let data = data, let intValue = Int(data) else {
        fatalError("Error converting data to Int!")
    }
    return intValue
}

private func readFloat(data: String?) -> Float {
    guard let data = data, let floatValue = Float(data) else {
        fatalError("Error converting data to Float!")
    }
    return floatValue
}

private func readVector2f(data: String?) -> vector_float2 {
    guard let data = data else {
        fatalError("Error converting data to vector_float2!")
    }
    let values = data.componentsSeparatedByString(" ").map(readFloat)
    return vector_float2(values[0], values[1])
}

private func readVector3f(data: String?) -> vector_float3 {
    guard let data = data else {
        fatalError("Error converting data to vector_float3!")
    }
    let values = data.componentsSeparatedByString(" ").map(readFloat)
    return vector_float3(values[0], values[1], values[2])
}