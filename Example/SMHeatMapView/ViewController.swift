//
//  ViewController.swift
//  SMHeatMapView
//
//  Created by sangriel on 09/28/2021.
//  Copyright (c) 2021 sangriel. All rights reserved.
//

import UIKit
import SMHeatMapView


struct Data : Codable {
    var point : [[[Int]]]
}



class ViewController: UIViewController {

    var backgroundImage = UIImageView()
    var image = UIImageView()
    
    var Color0 = UIColor.clear
    var Color1 = UIColor.rgb(red: 123, green: 126, blue: 255, alpha: 1)
    var Color2 = UIColor.rgb(red: 102, green: 255, blue: 255, alpha: 1)
    var Color3 = UIColor.rgb(red: 128, green: 238, blue: 100, alpha: 1)
    var Color4 = UIColor.rgb(red: 255, green: 195, blue: 77, alpha: 1)
    var Color5 = UIColor.rgb(red: 255, green: 0, blue: 0, alpha: 1)
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        self.view.backgroundColor = .white
        self.view.addSubview(backgroundImage)
        backgroundImage.translatesAutoresizingMaskIntoConstraints = false
        backgroundImage.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0).isActive = true
        backgroundImage.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        backgroundImage.widthAnchor.constraint(equalToConstant: 200).isActive = true
        backgroundImage.heightAnchor.constraint(equalToConstant: 200).isActive = true
        backgroundImage.backgroundColor = .clear
        backgroundImage.image = UIImage(named: "imgAttention")
        backgroundImage.contentMode = .scaleAspectFill
        
        
        self.view.addSubview(image)
        image.translatesAutoresizingMaskIntoConstraints = false
        image.centerYAnchor.constraint(equalTo: self.view.centerYAnchor, constant: 0).isActive = true
        image.centerXAnchor.constraint(equalTo: self.view.centerXAnchor, constant: 0).isActive = true
        image.widthAnchor.constraint(equalToConstant: 200).isActive = true
        image.heightAnchor.constraint(equalToConstant: 200).isActive = true
        image.backgroundColor = .clear
        
        image.layer.borderWidth = 1
        image.layer.borderColor = UIColor.black.cgColor
        
        let decoder = JSONDecoder()
        
        guard let path = Bundle.main.path(forResource: "data", ofType: ".json") else {
            return
        }
        

        guard let stringData = try? String(contentsOfFile: path, encoding: String.Encoding.utf8) else {
            return
        }
        
        let data = stringData.data(using: .utf8)
        var points : [CGPoint] = []
        if let data = data , let pointData = try? decoder.decode(Data.self, from: data) {
            //just for scaling coordinate to destination gridesize
            let xmax : CGFloat = 480
            let ymax : CGFloat = 640
            points = pointData.point[2].map{ CGPoint(x: 50 + CGFloat($0[0]) * (88 / xmax), y: 50 + CGFloat($0[1]) * (81.0 / ymax)) }
            
            
            
            //processHeatmap image
            image.image = SMHeatMapView().processHeatMapImage(point: points, gridSize: CGSize(width: 200, height: 200), ranges: [0, 0.1, 0.25 , 0.5 ,0.75, 1],
                                                              colors: [Color0,
                                                                       Color1,
                                                                       Color2,
                                                                       Color3,
                                                                       Color4,
                                                                       Color5
                                                                   ])
            
        }
        
        
        
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
        
    }

}


extension UIColor {
   static func rgb(red : CGFloat, green : CGFloat, blue : CGFloat, alpha : CGFloat ) -> UIColor {
       return UIColor(red: red / 255, green: green / 255, blue: blue / 255, alpha: alpha)
    }
}
