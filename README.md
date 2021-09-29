# SMHeatMapView

[![CI Status](https://img.shields.io/travis/sangriel/SMHeatMapView.svg?style=flat)](https://travis-ci.org/sangriel/SMHeatMapView)
[![Version](https://img.shields.io/cocoapods/v/SMHeatMapView.svg?style=flat)](https://cocoapods.org/pods/SMHeatMapView)
[![License](https://img.shields.io/cocoapods/l/SMHeatMapView.svg?style=flat)](https://cocoapods.org/pods/SMHeatMapView)
[![Platform](https://img.shields.io/cocoapods/p/SMHeatMapView.svg?style=flat)](https://cocoapods.org/pods/SMHeatMapView)

## Example
![Alt text](https://github.com/sangriel/SMHeatMapView/master/Readme_img/demoImag.png)
=======
![Alt text](https://github.com/sangriel/SMHeatMapView/blob/master/Readme_img/demoImag.png)
>>>>>>> c20c7dcfec862d9950c1abf1471d0e6787b3c333


To run the example project, clone the repo, and run `pod install` from the Example directory first.

## Usage
no delegates or callbacks it just return UIImage? right away

```Swift
import SMHeatMapView

//processHeatmap image
image.image = SMHeatMapView().processHeatMapImage(point: points,
                                                  gridSize: CGSize(width: 200, height: 200),
                                                  ranges: [0, 0.1, 0.25 , 0.5 ,0.75, 1],
                                                  colors: [Color0,
                                                           Color1,
                                                           Color2,
                                                           Color3,
                                                           Color4,
                                                           Color5
                                                       ])
```

## WeightCustomization
this part of code is responsible for calculating heatmap weight


customize as your own taste 
```Swift
for y in 0..<Int(gridSize.height) {
    for x in 0..<Int(gridSize.width)  {
        var totalWeight : CGFloat = 0
        for innerpoints in inputs {
            let distance = CGPoint(x: x, y: y).distance(to: innerpoints)
            //dropout weights for distance longer than radius
            totalWeight += max(0, (radius - distance)  )
        }
        //normalize weight to 0 ~ 1
        weight[x][y] = totalWeight / CGFloat(inputs.count)
        
    }
}
```


## Installation

SMHeatMapView is available through [CocoaPods](https://cocoapods.org). To install
it, simply add the following line to your Podfile:

```ruby
pod 'SMHeatMapView'
```

## Author

sangriel, sangriel3@gmail.com

## License

SMHeatMapView is available under the MIT license. See the LICENSE file for more info.
