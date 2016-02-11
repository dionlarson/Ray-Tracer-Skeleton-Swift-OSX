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

class Material {
    
    private let diffuseColor: vector_float3
    private let specularColor: vector_float3
    private let shininess: Float
    private var texture: Texture?
    var hasTexture: Bool {
        return texture != nil
    }
    
    init(diffuseColor: vector_float3, specularColor: vector_float3, shininess: Float, textureName: String?) {
        self.diffuseColor = diffuseColor
        self.specularColor = specularColor
        self.shininess = shininess
        if let textureName = textureName {
            self.texture = Texture(filename: textureName)
        }
    }
    
    func setupTexture(textureFilename: String) {
        texture = Texture(filename: textureFilename)
    }
    
    func shade(ray: Ray, hit: Hit, lightInfo light: (direction: vector_float3, color: vector_float3)) -> vector_float3 {
        //FIXME: Not yet implemented!

        return vector_float3()
    }
    
}