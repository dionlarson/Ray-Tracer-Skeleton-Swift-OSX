//
// Ray caster/tracer skeleton code and scene files adapted from starter code
// provided by MIT 6.837 on OCW.
//
// All additional code written by Dion Larson unless noted otherwise.
//
// Original skeleton code available for free here (assignments 4 & 5):
// http://ocw.mit.edu/courses/electrical-engineering-and-computer-science/6-837-computer-graphics-fall-2012/
//
// Licensed under Creative Commons 4.0 (Attribution, Noncommercial, Share Alike)
// http://creativecommons.org/licenses/by-nc-sa/4.0/
//


import Foundation
import simd

class Triangle: ObjectType, Equatable {
    
    let a: vector_float3
    let b: vector_float3
    let c: vector_float3
    let normals: [vector_float3]
    private var textureCoords: [vector_float2]?
    internal let material: Material
    
    internal var description: String {
        get {
            return "Triangle <\(a), \(b), \(c)>"
        }
    }
    
    subscript(index: Int) -> vector_float3 {
        get {
            switch index {
            case 0:
                return a
            case 1:
                return b
            case 2:
                return c
            default:
                fatalError("Out of bounds of triangle vertices!")
            }
            
        }
    }
    
    convenience init(vertices v: [(v: vector_float3, n: vector_float3, t: vector_float2)], material: Material) {
        self.init(vertices: v, material: material, smoothed: true)
    }
    
    init(vertices v: [(v: vector_float3, n: vector_float3, t: vector_float2)], material: Material, smoothed: Bool) {
        self.a = v[0].v
        self.b = v[1].v
        self.c = v[2].v
        if smoothed {
            self.normals = v.map({ $0.n })
        } else {
            let s0 = v[1].v - v[0].v
            let s1 = v[2].v - v[0].v
            let normal = cross(s0, s1)
            self.normals = [normal, normal, normal]
        }
        self.material = material
        if material.hasTexture {
            self.textureCoords = v.map({ $0.t })
        }
    }
    
    func intersect(ray r: Ray, tMin: Float, hit h: Hit) -> Bool {
        //FIXME: Not yet implemented!
        
        return false
    }
    
}

func ==(lhs: vector_float3, rhs: vector_float3) -> Bool {
    return lhs.x == rhs.x && lhs.y == rhs.y && lhs.z == rhs.z
}

func ==(lhs: Triangle, rhs: Triangle) -> Bool {
    return lhs.a == rhs.a && lhs.b == rhs.b && lhs.c == rhs.c
}
