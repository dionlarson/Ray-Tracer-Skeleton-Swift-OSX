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

class Sphere: ObjectType, CustomStringConvertible {
    
    private let center: vector_float3
    private let radius: Float
    internal let material: Material
    
    internal var description: String {
        get {
            return "Sphere <\(center), \(radius)>"
        }
    }
    
    init(center: vector_float3, radius: Float, material: Material) {
        self.center = center
        self.radius = radius
        self.material = material
    }
    
    func intersect(ray r: Ray, tMin: Float, hit h: Hit) -> Bool {
        // TODO: Fix return to return false for negative t values
        let originTranslation = r.origin - center
        let a = length(r.direction) ** 2
        let b = dot(2 * r.direction, originTranslation)
        let c = dot(originTranslation, originTranslation) - (radius ** 2)
        
        let dSquared = (b ** 2) - (4 * a * c)
        guard dSquared > 0 else { return false }
        
        let d = sqrt(dSquared)
        let t0 = (-b - d) / (2 * a)
        let t1 = (-b + d) / (2 * a)
        
        if t0 < t1 && t0 > tMin && t0 < h.t {
            let n = normalize(r.pointAtParameter(t0) - center)
            h.set(t: t0, material: material, normal: n)
        } else if t1 > tMin && t1 < h.t {
            let n = normalize(r.pointAtParameter(t1) - center)
            h.set(t: t1, material: material, normal: n)
        }
        
        return true
    }
    
}