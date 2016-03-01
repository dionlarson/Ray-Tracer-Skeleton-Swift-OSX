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

import Cocoa

enum SceneFile: String {
    case C01_Plane = "C01_Plane"
    case C02_Cube = "C02_Cube"
    case C03_Sphere = "C03_Sphere"
    case C04_Axes = "C04_Axes"
    case C05_Bunny_200 = "C05_Bunny_200"
    case C06_Bunny_1k = "C06_Bunny_1k"
    case C07_Shine = "C07_Shine"
    case C08_C = "C08_C"
    case C09_S = "C09_S"
    case C10_Surprise_2_5k = "C10_Surprise_2_5k"
    
    static let planes = [C01_Plane]
    static let spheres = [C01_Plane, C07_Shine]
    static let shading = [C01_Plane, C07_Shine]
    static let transforms = [C03_Sphere]
    static let triangles = [C02_Cube, C04_Axes, C05_Bunny_200, C06_Bunny_1k]
    static let textures = [C08_C, C09_S]
    
    static let allFastValues = [C01_Plane, C02_Cube, C03_Sphere, C04_Axes,
        C07_Shine, C08_C, C09_S]
    static let allValues = [C01_Plane, C02_Cube, C03_Sphere, C04_Axes,
        C05_Bunny_200, C06_Bunny_1k, C07_Shine, C08_C, C09_S, C10_Surprise_2_5k]
}

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    
    // width & heigh in pixels
    let WIDTH = 400
    let HEIGHT = 400
    // array of scenes to parse see SceneFile enum
    let SCENES_TO_PARSE: [SceneFile] = SceneFile.spheres
    // saves images to desktop, overwrites previous copy if exists
    let SAVE_IMAGES = true
    let SAVE_DEPTH = true
    let SAVE_NORMAL = true
    // higher memory use but quicker triangle intersections
    let USE_OCTREE = false
    
    var renderers = [Renderer]()
    func applicationDidFinishLaunching(aNotification: NSNotification) {
        let queue = dispatch_queue_create("Renderers", DISPATCH_QUEUE_SERIAL)
        for scene in SCENES_TO_PARSE {
            dispatch_async(queue) {
                let raycaster = RayCaster(sceneFile: scene, width: self.WIDTH, height: self.HEIGHT, useOctree: self.USE_OCTREE)
                self.renderers.append(raycaster)
                raycaster.render(saveImage: self.SAVE_IMAGES, saveDepth: self.SAVE_DEPTH, saveNormal: self.SAVE_NORMAL)
            }
        }
    }
    
    func applicationShouldTerminateAfterLastWindowClosed(sender: NSApplication) -> Bool {
        return true
    }

    func applicationWillTerminate(aNotification: NSNotification) {
        // Insert code here to tear down your application
    }

}

