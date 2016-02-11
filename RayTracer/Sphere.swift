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
        //FIXME: Not yet implemented!
        
        return false
    }
    
}