//
//  ViewController.swift
//  Spitfire
//
//  Created by seanmcneil on 03/08/2017.
//  Copyright (c) 2017 seanmcneil. All rights reserved.
//

import UIKit
import Spitfire
import Photos

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        var images = [UIImage]()
        for _ in 0..<120 {
            let image = UIImage(named: "testImage")!
            images.append(image)
        }
        
        Spitfire.shared.makeVideo(with: images, progress: { (progress) in
            let percent = (progress.fractionCompleted * 100).roundTo(places: 2)
            print("\(percent)%")
        }, success: { (url) in
            PHPhotoLibrary.shared().performChanges({
                PHAssetChangeRequest.creationRequestForAssetFromVideo(atFileURL: url)
            }) { saved, error in
                if saved {
                    let alertController = UIAlertController(title: NSLocalizedString("Your video was saved", comment: ""), message: nil, preferredStyle: .alert)
                    let defaultAction = UIAlertAction(title: NSLocalizedString("OK", comment: ""), style: .default, handler: nil)
                    alertController.addAction(defaultAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
}

extension Double {
    func roundTo(places:Int) -> Double {
        let divisor = pow(10.0, Double(places))
        return (self * divisor).rounded() / divisor
    }
}
