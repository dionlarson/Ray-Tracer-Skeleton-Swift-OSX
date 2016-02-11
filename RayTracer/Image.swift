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
import Cocoa

class Image {
    
    let width: Int
    let height: Int
    var data: [vector_float3]
    
    init(width: Int, height: Int) {
        self.width = width
        self.height = height
        self.data = Array<vector_float3>(count: width * height, repeatedValue: vector_float3(0, 0, 0))
    }
    
    func getPixel(x: Int, _ y: Int) -> vector_float3 {
        checkBounds(x, y)
        return data[y * width + x]
    }
    
    func setPixel(x x: Int, y: Int, color: vector_float3) {
        checkBounds(x, y)
        data[y * width + x] = color
    }
    
    func setAllPixels(color: vector_float3) {
        for i in 0..<data.count {
            data[i] = color
        }
    }
    
    func generateDepthNSImage() -> NSImage {
        var min = FLT_MAX
        var max = Float(0)
        for pixel in data {
            let pixelMin = reduce_min(pixel)
            let pixelMax = reduce_max(pixel)
            if pixelMin != 0 && pixelMin < min {
                min = pixelMin
            }
            if pixelMax < 40 && pixelMax > max {
                max = pixelMax
            }
        }
        let spreadInverse = 1 / (max - min)
        let minVector = vector_float3(min, min, min)
        
        func clamp(d: vector_float3) -> vector_float3 {
            return (d - minVector) * spreadInverse
        }
        
        data = data.map(clamp)
        
        return generateNSImage(inverse: true)
    }
    
    func generateNormalsNSImage() -> NSImage {
        return generateNSImage()
    }
    
    func generateNSImage() -> NSImage {
        return generateNSImage(inverse: false)
    }
    
    func generateNSImage(inverse inverse: Bool) -> NSImage {
        var pixelData = [PixelData]()
        for pixel in data {
            var r = clampToUInt8(pixel.x)
            var g = clampToUInt8(pixel.y)
            var b = clampToUInt8(pixel.z)
            if inverse {
                r = 255 - r
                g = 255 - g
                b = 255 - b
            }
            pixelData.append(PixelData(a: 255, r: r, g: g, b: b))
        }
        return NSImageFromARGB32Bitmap(pixelData, width: width, height: height)
    }
    
    private func checkBounds(x: Int, _ y: Int) {
        if x < 0 || y < 0 {
            fatalError("Out of image bounds!")
        }
    }
    
    private func clampToUInt8(x: Float) -> UInt8 {
        return UInt8(max(min(x*255, 255), 0))
    }
}


// See http://blog.human-friendly.com/drawing-images-from-pixel-data-in-swift
public struct PixelData {
    var a: UInt8 = 255
    var r: UInt8
    var g: UInt8
    var b: UInt8
}

private let rgbColorSpace = CGColorSpaceCreateDeviceRGB()
private let bitmapInfo:CGBitmapInfo = CGBitmapInfo(rawValue: CGImageAlphaInfo.PremultipliedFirst.rawValue)



private func NSImageFromARGB32Bitmap(var pixels: [PixelData], width: Int, height: Int) -> NSImage {
    let bitsPerComponent: Int = 8
    let bitsPerPixel: Int = 32
    
    assert(pixels.count == Int(width * height))
    
    let providerRef = CGDataProviderCreateWithCFData(
        NSData(bytes: &pixels, length: pixels.count * sizeof(PixelData))
    )
    
    guard let cgImage = CGImageCreate(
        width,
        height,
        bitsPerComponent,
        bitsPerPixel,
        width * sizeof(PixelData),
        rgbColorSpace,
        bitmapInfo,
        providerRef,
        nil,
        true,
        .RenderingIntentDefault
    ) else {
        fatalError("Failed to create image from pixel data!")
    }
    
    let image = NSImage(CGImage: cgImage, size: NSSize(width: width, height: height))
    
    return image
}

// See http://stackoverflow.com/questions/29262624/nsimage-to-nsdata-as-png-swift
extension NSImage {
    
    var imagePNGRepresentation: NSData {
        return NSBitmapImageRep(data: TIFFRepresentation!)!.representationUsingType(.NSPNGFileType, properties: [:])!
    }
    
    func savePNGToDesktop(filename: String) -> Bool {
        let desktop = NSSearchPathForDirectoriesInDomains(.DesktopDirectory, .UserDomainMask, true)[0]
        let url = NSURL(fileURLWithPath: desktop, isDirectory: true)
            .URLByAppendingPathComponent(filename)
            .URLByAppendingPathExtension("png")
        
        imagePNGRepresentation.writeToURL(url, atomically: true)
        return true
    }
    
}