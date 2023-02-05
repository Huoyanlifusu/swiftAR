//
//  Utilities.swift
//  artest
//
//  Created by 张裕阳 on 2022/9/29.
//

import Foundation
import ARKit
import UIKit
import VideoToolbox


func isHigher(from elevation: Float) -> Bool {
    if elevation > 0 {
        return true
    } else {
        return false
    }
}

func collectData(with refFrame: ARFrame) {
    guard let featurePoints = refFrame.rawFeaturePoints?.points else { return }
    
    
    //利用列表存储信息
    var featurePointsIn2D: [CGPoint] = []
    
    for i in 0..<featurePoints.count {
        var featurePointIn2D = refFrame.camera.projectPoint(featurePoints[i], orientation: .portrait, viewportSize: CGSize(width: 360, height: 780))
        
        //强制转换类型，便于python处理
        if featurePointIn2D.x >= 0 && featurePointIn2D.y >= 0 {
            let x = Int(featurePointIn2D.x / 360 * 1440)
            let y = Int(featurePointIn2D.y / 780 * 1920)
            let newFeaturePoint = CGPoint(x: x, y: y)
            featurePointsIn2D.append(newFeaturePoint)
        }
        
    }
    
    print(featurePointsIn2D)
    
    
    for j in 0..<refFrame.anchors.count {
        let anchorPosition = refFrame.anchors[j].transform.columns.3
        print("\(anchorPosition)")
    }
    print("---------------------")
    
    
    // Save UIImage to Photos Album
    guard let uiImage = UIImage(pixelBuffer: refFrame.capturedImage, scale: 1.0, orientation: .right) else { return }
    UIImageWriteToSavedPhotosAlbum(uiImage, nil, nil, nil)
    
    
    
    
}


extension UIImage {
    public convenience init?(pixelBuffer: CVPixelBuffer, scale: CGFloat, orientation: UIImage.Orientation) {
            var image: CGImage?
            VTCreateCGImageFromCVPixelBuffer(pixelBuffer, options: nil, imageOut: &image)

            guard let cgImage = image else { return nil }

            self.init(cgImage: cgImage, scale: scale, orientation: orientation)
        }
    }

