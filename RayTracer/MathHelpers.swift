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

// Power shorthand from:
// http://nshipster.com/swift-operators/
infix operator ** { associativity left precedence 160 }
func ** (left: Float, right: Float) -> Float {
    return pow(left, right)
}

func degreesToRadians(degrees: Float) -> Float {
    return degrees * Float(M_PI) / 180
}

extension vector_float2: CustomStringConvertible {
    public var description: String {
        return "<\(x), \(y)>"
    }
}

extension vector_float3: CustomStringConvertible {
    public var description: String {
        return "<\(x), \(y), \(z)>"
    }
}

extension vector_float4 {
    var xyz: vector_float3 {
        return vector_float3(x, y, z)
    }
}

extension matrix_float3x3 {
    
    var rows: (vector_float3, vector_float3, vector_float3) {
        let row0 = vector_float3(columns.0.x, columns.0.y, columns.0.z)
        let row1 = vector_float3(columns.1.x, columns.1.y, columns.1.z)
        let row2 = vector_float3(columns.2.x, columns.2.y, columns.2.z)
        return (row0, row1, row2)
    }
    
}

func determinant(m: matrix_float3x3) -> Float {
    return matrix_determinant(m)
}

func determinant(m: matrix_float4x4) -> Float {
    return matrix_determinant(m)
}

extension matrix_float4x4 {
    
    var inverse: matrix_float4x4 {
        return matrix_invert(self)
    }
    
    var transpose: matrix_float4x4 {
        return matrix_transpose(self)
    }
    
    init(
        _ a1: Float, _ b1: Float, _ c1: Float, _ d1: Float,
        _ a2: Float, _ b2: Float, _ c2: Float, _ d2: Float,
        _ a3: Float, _ b3: Float, _ c3: Float, _ d3: Float,
        _ a4: Float, _ b4: Float, _ c4: Float, _ d4: Float
        )
    {
        let a = vector_float4(a1, a2, a3, a4)
        let b = vector_float4(b1, b2, b3, b4)
        let c = vector_float4(c1, c2, c3, c4)
        let d = vector_float4(d1, d2, d3, d4)
        self.columns = (a, b, c, d)
    }
    
    static func ones() -> matrix_float4x4 {
        return matrix_float4x4(
            1, 1, 1, 1,
            1, 1, 1, 1,
            1, 1, 1, 1,
            1, 1, 1, 1
        )
    }
    
    static func identity() -> matrix_float4x4 {
        return matrix_float4x4(
            1, 0, 0, 0,
            0, 1, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1
        )
    }
    
    static func translation(x x: Float, y: Float, z: Float) -> matrix_float4x4 {
        return matrix_float4x4(
            1, 0, 0, x,
            0, 1, 0, y,
            0, 0, 1, z,
            0, 0, 0, 1
        )
    }
    
    static func translation(t: vector_float3) -> matrix_float4x4 {
        return matrix_float4x4.translation(x: t.x, y: t.y, z: t.z)
    }
    
    static func rotationX(radians: Float) -> matrix_float4x4 {
        let c = cos(radians)
        let s = sin(radians)
        
        return matrix_float4x4(
            1, 0, 0, 0,
            0, c, -s, 0,
            0, s, c, 0,
            0, 0, 0, 1
        )
    }
    
    static func rotationY(radians: Float) -> matrix_float4x4 {
        let c = cos(radians)
        let s = sin(radians)
        
        return matrix_float4x4(
            c, 0, s, 0,
            0, 1, 0, 0,
            -s, 0, c, 0,
            0, 0, 0, 1
        )
    }
    
    static func rotationZ(radians: Float) -> matrix_float4x4 {
        let c = cos(radians)
        let s = sin(radians)
        
        return matrix_float4x4(
            c, -s, 0, 0,
            s, c, 0, 0,
            0, 0, 1, 0,
            0, 0, 0, 1
        )
    }
    
    static func rotation(direction: vector_float3, radians: Float) -> matrix_float4x4 {
        let normalizedDirection = normalize(direction)
        let c = cos(radians)
        let ci = 1 - c
        let s = sin(radians)
        let x = normalizedDirection.x
        let y = normalizedDirection.y
        let z = normalizedDirection.z
        
        return matrix_float4x4(
            x * x * ci + c,     y * x * ci - z * s, z * x * ci + y * s, 0,
            x * y * ci + z * s, y * y * ci + c,     z * y * ci - x * s, 0,
            x * z * ci - y * s, y * z * ci + x * s, z * z * ci + c,     0,
            0,                  0,                  0,                  1
        )
    }
    
    static func scaling(x x: Float, y: Float, z: Float) -> matrix_float4x4 {
        return matrix_float4x4(
            x, 0, 0, 0,
            0, y, 0, 0,
            0, 0, z, 0,
            0, 0, 0, 1
        )
    }
    
    static func uniformScaling(s: Float) -> matrix_float4x4 {
        return matrix_float4x4.scaling(x: s, y: s, z: s)
    }
}

func *(lhs: matrix_float4x4, rhs: matrix_float4x4) -> matrix_float4x4 {
    return matrix_multiply(lhs, rhs)
}

func *(lhs: matrix_float4x4, rhs: vector_float4) -> vector_float4 {
    return matrix_multiply(lhs, rhs)
}

func *=(inout lhs: matrix_float4x4, rhs: matrix_float4x4) {
    lhs = lhs * rhs
}

func ==(lhs: matrix_float4x4, rhs: matrix_float4x4) -> Bool {
    return matrix_equal(lhs, rhs)
}

func transformPoint(m: matrix_float4x4, p: vector_float3) -> vector_float3 {
    return (m * vector_float4(p.x, p.y, p.z, 1)).xyz
}

func transformDirection(m: matrix_float4x4, dir: vector_float3) -> vector_float3 {
    return ( m * vector_float4(dir.x, dir.y, dir.z, 0) ).xyz
}














