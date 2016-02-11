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

class Hit: CustomStringConvertible {
    private(set) var t = FLT_MAX
    private(set) var normal : vector_float3?
    private(set) var material: Material?
    private(set) var textureCoords: vector_float2?
    
    internal var description: String {
        get {
            return "Hit <\(t), \(normal)>"
        }
    }
    
    func set(t t: Float, material: Material, normal: vector_float3) {
        self.t = t
        self.material = material
        self.normal = normal
        self.textureCoords = nil
    }
    
    func set(t t: Float, material: Material, normal: vector_float3, textureCoords: vector_float2) {
        self.t = t
        self.material = material
        self.normal = normal
        self.textureCoords = textureCoords
    }
    
    func setNormal(normal: vector_float3) {
        self.normal = normal
    }
}