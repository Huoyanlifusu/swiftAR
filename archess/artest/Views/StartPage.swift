//
//  StartPage.swift
//  archess
//
//  Created by 张裕阳 on 2023/2/16.
//

import UIKit

class StartPage: UIViewController {
    
    private let imageView: UIImageView = {
        let image = UIImage(named: "gobang")
        
        let view = UIImageView(frame: CGRect(x: 0,
                                             y: 0,
                                             width: StartPageConstants.imageSize,
                                             height: StartPageConstants.imageSize))
        view.image = image
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.view.addSubview(imageView)
        self.view.sendSubviewToBack(imageView)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        imageView.frame = CGRect(x: 0,
                                 y: view.bounds.size.height/2 - imageView.frame.height/2,
                                 width: StartPageConstants.imageSize,
                                 height: StartPageConstants.imageSize)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */
    
    struct StartPageConstants {
        static let imageSize: CGFloat = 700
    }
}
