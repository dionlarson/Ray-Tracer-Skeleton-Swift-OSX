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

class Box {
    var min: vector_float3
    var max: vector_float3
    
    init() {
        self.min = vector_float3()
        self.max = vector_float3()
    }
    
    init(min: vector_float3, max: vector_float3) {
        self.min = min
        self.max = max
    }
    
    static func overlap(inout a: Box, inout b: Box) -> Bool {
        for i in 0..<3 {
            if a.max[i] < b.min[i] { return false }
            if a.min[i] > b.max[i] { return false }
        }
        return true
    }
    
    static func inside(a: Box, b: Box) -> Bool {
        for dim in 0..<3 {
            if a.min[dim] < b.min[dim] || a.max[dim] > b.max[dim] {
                return false
            }
        }
        return true
    }
    
    static func triangle(t: Triangle) -> Box {
        let b = Box()
        b.min = t[0]
        b.max = t[0]
        for i in 1..<3 {
            for dim in 0..<3 {
                if b.min[dim] > t[i][dim] {
                    b.min[dim] = t[i][dim]
                }
                if b.max[dim] < t[i][dim] {
                    b.max[dim] = t[i][dim]
                }
            }
        }
        return b
    }
}

class OctNode {
    
    var triangles = [Triangle]()
    var child = [OctNode]()
    var box = Box()
    var isTerminal: Bool {
        return child.isEmpty
    }
}

class Octree: Hitable {
    
    let maxTriangles = 7
    let root = OctNode()
    let maxLevel: Int
    
    init(m: TriangleMesh, maxLevel: Int) {
        self.maxLevel = maxLevel
        build(mesh: m)
    }
    
    func build(mesh m: TriangleMesh) {
        root.box.min = m.vertices[0]
        root.box.max = m.vertices[0]
        for v in m.vertices {
            for dim in 0..<3 {
                if root.box.min[dim] >= v[dim] {
                    root.box.min[dim] = v[dim]
                }
                if root.box.max[dim] <= v[dim] {
                    root.box.max[dim] = v[dim]
                }
            }
        }
        buildNode(root, triangles: m.triangles, level: 0)
    }
    
    func buildNode(parent: OctNode, triangles: [Triangle], var level: Int) {
        if triangles.count <= maxTriangles || level > maxLevel {
            parent.triangles = triangles
            return
        }
        
        level += 1
        
        let min = parent.box.min
        let max = parent.box.max
        let mid = (min + max) * Float(0.5)
        
        let childBoxes = [
            Box(min: min, max: mid),
            Box(min: vector_float3(min.x, min.y, mid.z), max: vector_float3(mid.x, mid.y, max.z)),
            Box(min: vector_float3(min.x, mid.y, min.z), max: vector_float3(mid.x, max.y, mid.z)),
            Box(min: vector_float3(min.x, mid.y, mid.z), max: vector_float3(mid.x, max.y, max.z)),
            Box(min: vector_float3(mid.x, min.y, min.z), max: vector_float3(max.x, mid.y, mid.z)),
            Box(min: vector_float3(mid.x, min.y, mid.z), max: vector_float3(max.x, mid.y, max.z)),
            Box(min: vector_float3(mid.x, mid.y, min.z), max: vector_float3(max.x, max.y, mid.z)),
            Box(min: mid, max: max)
        ]
        
        var added = Array<Bool>(count: triangles.count, repeatedValue: false)
        
        for i in 0..<8 {
            let child = OctNode()
            child.box = childBoxes[i]
            var childTriangles = [Triangle]()
            for j in 0..<triangles.count {
                let t = triangles[j]
                var tBox = Box.triangle(t)
                if Box.inside(tBox, b: child.box) || Box.overlap(&tBox, b: &child.box) {
                    childTriangles.append(t)
                    added[j] = true
                }
            }
            parent.child.append(child)
            buildNode(child, triangles: childTriangles, level: level)
        }
    }
    
    func firstNode(t t: vector_float3, tm: vector_float3) -> Int {
        var bits: Int = 0
        if t.x > t.y {
            if t.x > t.z {
                if tm.y < t.x { bits |= 2 }
                if tm.z < t.x { bits |= 1 }
                return bits
            }
        } else if t.y > t.z {
            if tm.x < t.z { bits |= 4 }
            if tm.z < t.y { bits |= 1 }
            return bits
        }
        if tm.x < t.z { bits |= 4 }
        if tm.y < t.z { bits |= 2 }
        return bits
    }
    
    func newNode(t t: vector_int3, tm: vector_float3) -> Int {
        if tm.x < tm.y {
            if tm.x < tm.z {
                return Int(t.x)
            }
        } else {
            if tm.y < tm.z {
                return Int(t.y)
            }
        }
        return Int(t.z)
    }
    
    func processSubtree(args: (r: Ray, tMin: Float, h: Hit), t0: vector_float3, t1: vector_float3, node: OctNode, aa: Int) -> Bool {
        var intersected = false
        if t1.x < 0 || t1.y < 0 || t1.z < 0 { return false }
        if node.isTerminal {
            for t in node.triangles {
                intersected = t.intersect(ray: args.r, tMin: args.tMin, hit: args.h) || intersected
            }
            return intersected
        }
        let tm = (t0 + t1) * Float(0.5)
        var currentNode = firstNode(t: t0, tm: tm)
        repeat {
            let index = currentNode^aa
            switch currentNode {
            case 0:
                intersected = processSubtree(args, t0: t0, t1: tm, node: node.child[index], aa: aa) || intersected
                currentNode = newNode(t: vector_int3(4, 2, 1), tm: tm)
            case 1:
                intersected = processSubtree(args, t0: vector_float3(t0.x, t0.y, tm.z),
                    t1: vector_float3(tm.x, tm.y, t1.z), node: node.child[index], aa: aa) || intersected
                currentNode = newNode(t: vector_int3(5, 3, 8), tm: vector_float3(tm.x, tm.y, t1.z))
            case 2:
                intersected = processSubtree(args, t0: vector_float3(t0.x, tm.y, t0.z),
                    t1: vector_float3(tm.x, t1.y, tm.z), node: node.child[index], aa: aa) || intersected
                currentNode = newNode(t: vector_int3(6, 8, 3), tm: vector_float3(tm.x, t1.y, tm.z))
            case 3:
                intersected = processSubtree(args, t0: vector_float3(t0.x, tm.y, tm.z),
                    t1: vector_float3(tm.x, t1.y, t1.z), node: node.child[index], aa: aa) || intersected
                currentNode = newNode(t: vector_int3(7, 8, 8), tm: vector_float3(tm.x, t1.y, t1.z))
            case 4:
                intersected = processSubtree(args, t0: vector_float3(tm.x, t0.y, t0.z),
                    t1: vector_float3(t1.x, tm.y, tm.z), node: node.child[index], aa: aa) || intersected
                currentNode = newNode(t: vector_int3(8, 6, 5), tm: vector_float3(t1.x, tm.y, tm.z))
            case 5:
                intersected = processSubtree(args, t0: vector_float3(tm.x, t0.y, tm.z),
                    t1: vector_float3(t1.x, tm.y, t1.z), node: node.child[index], aa: aa) || intersected
                currentNode = newNode(t: vector_int3(8, 7, 8), tm: vector_float3(t1.x, tm.y, t1.z))
            case 6:
                intersected = processSubtree(args, t0: vector_float3(tm.x, tm.y, t0.z),
                    t1: vector_float3(t1.x, t1.y, tm.z), node: node.child[index], aa: aa) || intersected
                currentNode = newNode(t: vector_int3(8, 8, 7), tm: vector_float3(t1.x, t1.y, tm.z))
            case 7:
                intersected = processSubtree(args, t0: tm, t1:
                    t1, node: node.child[index], aa: aa) || intersected
                currentNode = 8
            default:
                break
            }
        } while currentNode < 8
        return intersected
    }
    
    func intersect(ray r: Ray, tMin: Float, hit h: Hit) -> Bool {
        var rd = normalize(r.direction)
        var ro = r.origin
        var aa = 0
        
        let size = root.box.max + root.box.min
        if rd.x < 0 {
            ro.x = size.x - ro.x
            rd.x = -rd.x
            aa |= 4
        }
        if rd.y < 0 {
            ro.y = size.y - ro.y
            rd.y = -rd.y
            aa |= 2
        }
        if rd.z < 0 {
            ro.z = size.z - ro.z
            rd.z = -rd.z
            aa |= 1
        }
        
        let t0 = (root.box.min - ro) / rd
        let t1 = (root.box.max - ro) / rd
        
        let args: (r: Ray, tMin: Float, h: Hit) = (r, tMin, h)
        
        var intersected = false
        if reduce_max(t0) <= reduce_min(t1) {
            intersected = processSubtree(args, t0: t0, t1: t1, node: root, aa: aa) || intersected
        }
        return intersected
    }
}