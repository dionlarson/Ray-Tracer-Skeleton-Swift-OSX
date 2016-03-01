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

protocol Light {
    func getIllumination(point p: vector_float3) -> (direction: vector_float3, color: vector_float3)
}


class DirectionalLight: Light {
    
    let direction: vector_float3
    let color: vector_float3
    
    init(direction: vector_float3, color: vector_float3) {
        self.direction = normalize(direction)
        self.color = color
    }
    
    func getIllumination(point p: vector_float3) -> (direction: vector_float3, color: vector_float3) {
        let direction = -self.direction
        let color = self.color
        return (direction, color)
    }
}

class PointLight: Light {
    
    let position: vector_float3
    let color: vector_float3
    
    init(position: vector_float3, color: vector_float3) {
        self.position = position
        self.color = color
    }
    
    // Fall off not implemented yet, will come in second half of class
    func getIllumination(point p: vector_float3) -> (direction: vector_float3, color: vector_float3)  {
        let pointToLight = self.position - p
        let direction = normalize(pointToLight)
        let color = self.color
        return (direction, color)
    }
}
