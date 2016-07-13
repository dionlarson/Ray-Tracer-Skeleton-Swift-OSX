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
import Cocoa

protocol Renderer {
    func render()
    func render(saveImage saveImage: Bool, saveDepth: Bool, saveNormal: Bool)
}

class RayCaster: Renderer {
    
    var windowController : ResultsWindowController
    let sceneFile: SceneFile
    var image: Image!
    var depthImage: Image!
    var normalsImage: Image!
    var scene: Scene!
    let width: Int
    let height: Int
    
    convenience init(sceneFile: SceneFile, width: Int, height: Int) {
        self.init(sceneFile: sceneFile, width: width, height: height, useOctree: false)
    }
    
    init(sceneFile: SceneFile, width: Int, height: Int, useOctree: Bool) {
        self.sceneFile = sceneFile
        self.width = width
        self.height = height
        
        self.image = Image(width: width, height: height)
        self.depthImage = Image(width: width, height: height)
        self.depthImage.setAllPixels(vector_float3(FLT_MAX, FLT_MAX, FLT_MAX))
        self.normalsImage = Image(width: width, height: height)
        self.windowController = ResultsWindowController(windowTitle: sceneFile.rawValue)
        
        windowController.updateStatusLabel("Loading", scene: sceneFile)
        do {
            scene = try Scene.parseScene(sceneFile, w: width, h: height, useOctree: useOctree)
        } catch {
            fatalError("Could not parse scene!")
        }
    }
    
    func render() {
        render(saveImage: false, saveDepth: false, saveNormal: false)
    }
    
    func render(saveImage saveImage: Bool, saveDepth: Bool, saveNormal: Bool) {
        windowController.updateStatusLabel("Ray casting", scene: sceneFile)
        
        //FIXME: Not yet implemented!
        
        // release images and scene to free up memory -- will need to be
        // recreated if rendedered again!
        image = nil
        depthImage = nil
        normalsImage = nil
        scene = nil
    }
    
    func raycastPixel(i: Int, _ j: Int) {
        //FIXME: Not yet implemented!
    }
    
    func shade(ray ray: Ray, hit: Hit) -> vector_float3 {
        //FIXME: Not yet implemented!
        return vector_float3()
    }
    
    func setDepthPixel(x x: Int, y: Int, hit: Hit) {
        let color = vector_float3(hit.t, hit.t, hit.t)
        self.depthImage.setPixel(x: x, y: y, color: color)
    }
    
    func setNormalPixel(x x: Int, y: Int, hit: Hit) {
        self.normalsImage.setPixel(x: x, y: y, color: abs(hit.normal!))
    }
    
    func processDepth(saveImage save: Bool) {
        let result = depthImage.generateDepthNSImage()
        windowController.resultsWindow.depth = result
        
        if save {
            result.savePNGToDesktop("\(sceneFile.rawValue)_depth")
        }
    }
    
    func processNormals(saveImage save: Bool) {
        let result = normalsImage.generateNormalsNSImage()
        windowController.resultsWindow.normals = result
        
        if save {
            result.savePNGToDesktop("\(sceneFile.rawValue)_normal")
        }
    }
    
    func displayResult(saveImage save: Bool) {
        windowController.updateStatusLabel("Processing pixels for", scene: sceneFile)
        let result = image.generateNSImage()
        windowController.resultsWindow.rendered = result
        windowController.updateImageView(result)
        
        if save {
            result.savePNGToDesktop(sceneFile.rawValue)
        }
    }
}