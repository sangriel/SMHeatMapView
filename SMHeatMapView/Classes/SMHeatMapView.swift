
import Foundation
import UIKit
import CoreGraphics

public class SMHeatMapView : NSObject {
    
    /**
     radius unit is in pixel
     so this mean the targetPixels weight will be affected by pixels around 15 distance in circle
     */
    private var radius : CGFloat = 15
    
    /**
     ranges are level of colors and datas
     set this values between 0 ~ 1
     and have to be equal length with the colors
     */
    private var ranges : [CGFloat] = []
    /**
     colors are corresponding to ranges
     */
    private var colors : [UIColor] = []
    /**
     the size of UIimage you want to make
     */
    private var gridSize : CGSize = .zero
    
    
    /**
     inital method of creating heatmapImage
     
     
     - Parameter point : the datas to be represented
     - Parameter gridSize : the size of Uiimage which you want to make
     - Parameter radius : radius unit is in pixel, so this mean the targetPixels weight will be affected by pixels around 15 distance in circle, default 15
     - Parameter ranges : ranges are level of colors and datas, set this values between 0 ~ 1
     - Parameter colors : to make null data area to be transparent, set colors[0] to UIColor.clear
     
     - returns : heatMapImage( optional )
     */
    open func processHeatMapImage(point : [CGPoint], gridSize : CGSize, radius : CGFloat = 15, ranges : [CGFloat] , colors : [UIColor]) -> UIImage? {
        self.gridSize = gridSize
        self.radius = radius *  min((gridSize.width / 100 ), 1)
        self.ranges = ranges
        self.colors = colors
        
        if ranges.count == 0 || colors.count == 0 || ranges.count != colors.count {
            print("please set equal length of ranges and colors")
            return nil
        }
        return calculateWeightsAndColor(inputs : point, gridSize : gridSize)
        
    }
    
    
    private func calculateWeightsAndColor(inputs : [CGPoint], gridSize : CGSize) -> UIImage? {
        
        var colorsForBitmap : [[UIColor]] = Array(repeating: Array(repeating: .clear, count: Int(gridSize.height)), count: Int(gridSize.width))
        
        
        var weight : [[CGFloat]] = Array(repeating: Array(repeating: 0, count: Int(gridSize.height)), count: Int(gridSize.width))
        
        
        for y in 0..<Int(gridSize.height) {
            for x in 0..<Int(gridSize.width)  {
                var totalWeight : CGFloat = 0
                for innerpoints in inputs {
                    let distance = CGPoint(x: x, y: y).distance(to: innerpoints)
                    totalWeight += max(0, (radius - distance)  )
                }
                weight[x][y] = totalWeight / CGFloat(inputs.count)
                
            }
        }
        
        

        
        for y in 0..<Int(gridSize.height) {
            for x in 0..<Int(gridSize.width)  {
                colorsForBitmap[x][y] = getHeatMapColor(intensity: weight[x][y])
            }
        }
        
        return drawPixel(colorForBitmap : colorsForBitmap)
        
    }
    
    
    private func getHeatMapColor(intensity : CGFloat) -> UIColor {
        
        
        if intensity <= ranges[0] {
            return .clear
        }
        if let lastofRange = ranges.last , let lastofColor = colors.last {
            if intensity >= lastofRange {
                return lastofColor
            }
        }
        
        
        for (index) in 0..<colors.count {
            
            if intensity < ranges[index] {
                
                let dist_from_lower_point = intensity - ranges[index-1]
                let size_of_point_range = ranges[index] - ranges[index - 1]
                
                let ratio_over_lower_point = dist_from_lower_point / size_of_point_range
                var red : [CGFloat] = Array(repeating: 0, count: 2)
                var green : [CGFloat] = Array(repeating: 0, count: 2)
                var blue : [CGFloat] = Array(repeating: 0, count: 2)
                var alpha : [CGFloat] = Array(repeating: 0, count: 2)
                
                if colors[index].getRed(&red[0], green: &green[0], blue: &blue[0], alpha: &alpha[0]) {
                    red[0] = red[0] * 255
                    blue[0] = blue[0] * 255
                    green[0] = green[0] * 255
                    alpha[0] = alpha[0] * 255
                    
                }
                
                if colors[index - 1].getRed(&red[1], green: &green[1], blue: &blue[1], alpha: &alpha[1]) {
                    red[1] = red[1] * 255
                    blue[1] = blue[1] * 255
                    green[1] = green[1] * 255
                    alpha[1] = alpha[1] * 255
                    
                }
                
                let color_range : [CGFloat] = [red[0] - red[1],green[0] - green[1],blue[0] - blue[1],alpha[0] - alpha[1]]
            
                let color_contribution = color_range.map{ $0 * ratio_over_lower_point }
                
                var newRed : CGFloat = red[1] + color_contribution[0]
                if newRed < 0 {
                    newRed = 0
                }
                else if newRed > 255 {
                    newRed = 255
                }
                
                
                var newGreen : CGFloat = green[1] + color_contribution[1]
                if newGreen < 0 {
                    newGreen = 0
                }
                else if newGreen > 255 {
                    newGreen = 255
                }
                
                
                var newBlue : CGFloat = blue[1] + color_contribution[2]
                if newBlue < 0 {
                    newBlue = 0
                }
                else if newBlue > 255 {
                    newBlue = 255
                }
                
                var newAlpha : CGFloat = alpha[1] + color_contribution[3]
                if newAlpha < 0 {
                    newAlpha = 0
                }
                else if newAlpha > 255 {
                    newAlpha = 255
                }
                
               
                
                
                return UIColor.init(red: newRed / 255, green: newGreen / 255, blue: newBlue / 255, alpha: newAlpha / 255)
            }
        }
        
        
        return colors[0]
    }
    
    private func drawPixel(colorForBitmap : [[UIColor]]) -> UIImage? {
        let width = Int(self.gridSize.width)
        let height = Int(self.gridSize.height)
        let rawData = UnsafeMutableBufferPointer<RGBAPixel>.allocate(capacity: width * height)
        let pixels = UnsafeMutableBufferPointer<RGBAPixel>(start: rawData.baseAddress, count: width * height)
        
        for y in 0..<height {
            for x in 0..<width {
                pixels[x + y*width] = RGBAPixel(raw: colorForBitmap[x][y].hex)
            }
        }
        
        let bitspreComponent = 8
        let bytesPerRow = 4 * width
        let colorSpace : CGColorSpace = CGColorSpaceCreateDeviceRGB()
        let bitmapInfo : UInt32 = CGBitmapInfo.byteOrder32Big.rawValue | CGImageAlphaInfo.premultipliedLast.rawValue
        let context = CGContext.init(data: pixels.baseAddress, width: width, height: height, bitsPerComponent: bitspreComponent, bytesPerRow: bytesPerRow, space: colorSpace, bitmapInfo: bitmapInfo)
        
        if let context = context, let image = context.makeImage() {
            let outImage = UIImage(cgImage: image )
//            testImage.image = outImage
            return outImage
        }
        return nil
        
    }
    
    
    
    
}

extension UIColor {
    var hex : UInt32 {
        var  red : CGFloat = 0 , blue : CGFloat = 0 , green : CGFloat = 0, alpha : CGFloat = 0
        getRed(&red, green: &green, blue: &blue, alpha: &alpha)
        var  value : UInt32 = 0
        value = UInt32(alpha * 255 ) << 24 | UInt32(blue * 255) << 16  | UInt32(green * 255 ) << 8 | UInt32(red * 255 )
        return value
    }
}

extension CGPoint {
    func distance(to : CGPoint) -> CGFloat {
        let x = self.x - to.x
        let y = self.y - to.y
        return CGFloat(sqrtf(Float(x*x + y*y)))
        
    }
}

struct RGBAPixel {
    public var raw : UInt32
    
    init( raw : UInt32) {
        self.raw = raw
    }
    public var red : UInt8 {
        get { return UInt8(raw & 0xFF) }
        set { raw = UInt32(newValue) | (raw & 0xFFFFFF00)}
    }
    
    
    public var green : UInt8 {
        get { return UInt8(raw & 0xFF00) >> 8 }
        set { raw = (UInt32(newValue) << 8) | (raw & 0xFFFF00FF)}
    }
    
    public var blue : UInt8 {
        get { return UInt8(raw & 0xFF0000) >> 16 }
        set { raw = (UInt32(newValue) << 16) | (raw & 0xFF00FFFF)}
    }
    
    public var alpha : UInt8 {
        get { return UInt8(raw & 0xFF000000) >> 24 }
        set { raw = (UInt32(newValue) << 24) | (raw & 0x00FFFFFF) }
    }
    
}


