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

class TriangleMesh: Hitable {
    
    let triangles: [Triangle]
    let vertices: [vector_float3]
    var octree: Octree?
    
    init(triangles: [Triangle]) {
        self.triangles = triangles
        self.vertices = [vector_float3]()
    }
    
    init(triangles: [Triangle], vertices: [vector_float3]) {
        self.triangles = triangles
        self.vertices = vertices
        octree = Octree(m: self, maxLevel: 7)
    }
    
    func intersect(ray r: Ray, tMin: Float, hit h: Hit) -> Bool {
        //TODO: Remove this line once you review this method...
        guard let octree = octree else {
            var intersected = false
            for t in triangles {
                intersected = t.intersect(ray: r, tMin: tMin, hit: h) || intersected
            }
            return intersected
        }
        return octree.intersect(ray: r, tMin: tMin, hit: h)
    }
    
}