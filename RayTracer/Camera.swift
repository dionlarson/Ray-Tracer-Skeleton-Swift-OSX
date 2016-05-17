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
        self.center = center
        self.direction = normalize(direction)
        self.horizontal = normalize(cross(direction, up))
        self.up = normalize(cross(horizontal, direction))
        self.fieldOfView = fieldOfView
        self.aspect = Float(h) / Float(w)
    }
    
    func generateRay(point point: vector_float2) -> Ray {
        let d = 1 / tanf(fieldOfView / 2)
        let r = normalize(point.x * horizontal + point.y * aspect * up + d * direction)
        return Ray(origin: center, direction: r)
    }
}

class ApertureCamera : PerspectiveCamera {
    
    internal let apertureSize: Float
    internal let focalLength: Float
    
    init(apertureSize: Float, focalLength: Float, center: vector_float3, direction: vector_float3, up: vector_float3, fieldOfView: Float, w: Int, h: Int) {
        self.apertureSize = apertureSize
        self.focalLength = focalLength
        super.init(center: center, direction: direction, up: up, fieldOfView: fieldOfView, w: w, h: h)
    }
    
//        let theta = Double(random()) / Double(Int.max) * 2 * M_PI
//        let jitterDistance = Double(random()) / Double(Int.max) * Double(camera.apertureSize)
    
    func generateSquareJitteredRay(focalPoint: vector_float3) -> Ray {
        let jitterX = Float(rand() - RAND_MAX/2) / Float(RAND_MAX/2) * apertureSize
        let jitterY = Float(rand() - RAND_MAX/2) / Float(RAND_MAX/2) * apertureSize
        let jitteredCenter = center + horizontal * jitterX + up * jitterY
        let direction = normalize(focalPoint - jitteredCenter)
        return Ray(origin: jitteredCenter, direction: direction)
    }
    
}











