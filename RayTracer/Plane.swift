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

class Plane: ObjectType, CustomStringConvertible {
    
    private let normal: vector_float3
    private let d: Float
    internal let material: Material
    
    internal var description: String {
        get {
            return "Plane <\(d), \(normal)>"
        }
    }
    
    init(normal: vector_float3, d: Float, material: Material) {
        self.normal = normal
        self.d = d
        self.material = material
    }
    
    func intersect(ray r: Ray, tMin: Float, hit h: Hit) -> Bool {
        let dotProd = dot(normal, r.direction)
        if dotProd == 0 { return false }
        let t = -(d + dot(normal, r.origin)) / dotProd
        if t <= tMin || t >= h.t { return false }
        h.set(t: t, material: material, normal: normal)
        return true
    }
}