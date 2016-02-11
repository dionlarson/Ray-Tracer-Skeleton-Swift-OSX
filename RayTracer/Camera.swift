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

protocol Camera {
    func generateRay(point point: vector_float2) -> Ray
    var tMin: Float { get }
    var center: vector_float3 { get }
    var direction: vector_float3 { get }
    var up: vector_float3 { get }
    var horizontal: vector_float3 { get }
}

class PerspectiveCamera : Camera {
    
    internal let center: vector_float3
    internal let direction: vector_float3
    internal let up: vector_float3
    internal let horizontal: vector_float3
    internal let tMin: Float = 0
    internal let fieldOfView: Float
    internal let aspect: Float

    init(center: vector_float3, direction: vector_float3, up: vector_float3, fieldOfView: Float, w: Int, h: Int) {
        //FIXME: Not yet implemented!
        self.center = vector_float3()
        self.direction = vector_float3()
        self.horizontal = vector_float3()
        self.up = vector_float3()
        self.fieldOfView = 0
        self.aspect = 0
    }
    
    func generateRay(point point: vector_float2) -> Ray {
        //FIXME: Not yet implemented!
        return Ray(origin: vector_float3(), direction: vector_float3())
    }
}