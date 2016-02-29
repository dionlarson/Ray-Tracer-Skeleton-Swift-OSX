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

class Ray: CustomStringConvertible {
    
    internal let origin: vector_float3
    internal let direction: vector_float3
    
    internal var description: String {
        get {
            return "Ray <\(origin), \(direction)>"
        }
    }
    
    internal init(origin: vector_float3, direction: vector_float3) {
        self.origin = origin
        self.direction = direction
    }
    
    func pointAtParameter(t: Float) -> vector_float3 {
        return origin + t * direction
    }
    
}