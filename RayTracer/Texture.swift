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
import Cocoa
import simd

class Texture {
    
    private let image: NSBitmapImageRep
    
    init(filename: String) {
        guard let url = NSBundle.mainBundle().URLForResource(filename, withExtension: "bmp"),
            let data = NSData(contentsOfURL: url),
            let image = NSBitmapImageRep(data: data) else {
            fatalError("Could not read texture \(filename)! Does it exist?")
        }
        self.image = image
    }
    
    func colorAt(coords: vector_float2) -> vector_float3 {
        let x = min(Int(coords.x * Float(image.pixelsWide)), image.pixelsWide-1)
        let y = min(Int((1 - coords.y) * Float(image.pixelsHigh)), image.pixelsHigh-1)
        guard let color = image.colorAtX(x, y: y) else {
            fatalError("Out of textures range!")
        }
        return vector_float3(Float(color.redComponent), Float(color.greenComponent), Float(color.blueComponent)
        )
    }
}