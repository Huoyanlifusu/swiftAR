//
//  ViewControllerB.swift
//  archess
//
//  Created by 张裕阳 on 2023/2/14.
//
import Foundation
import UIKit
import ARKit
import SceneKit

class ViewControllerB: UIViewController, ARSessionDelegate {
    
    @IBOutlet weak var sceneView: ARSCNView!
    
    var originNode: SCNNode?
    
    var camera: ARCamera?
    
    
    //chessGameLogicVariable
    var canPlaceBoard = true
    var firstClick = false
    
    private let infoLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0,
                                          y: 0,
                                          width: 200,
                                          height: 40))
        label.font = UIFont(name: "hongleisim-Regular", size: 30)
        label.text = ""
        return label
    }()
    
    private let deviceLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0,
                                          y: 0,
                                          width: 200,
                                          height: 40))
        label.font = UIFont(name: "hongleisim-Regular", size: 30)
        label.text = ""
        return label
    }()
    
    //退出按钮
    private let exitButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0,
                                            y: 0,
                                            width: 60,
                                            height: 60))
        button.backgroundColor = .black
        button.layer.cornerRadius = 30
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.3
        //button.layer.masksToBounds = true
        let image = UIImage(systemName: "arrow.left.circle",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 32,
                                                                           weight: .medium))
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    //重启按钮
    private let restartButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0,
                                            y: 0,
                                            width: 60,
                                            height: 60))
        button.backgroundColor = .black
        button.layer.cornerRadius = 30
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.3
        
        let image = UIImage(systemName: "arrow.clockwise",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 32,
                                                                           weight: .medium))
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
        
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("do not support ar world tracking")
        }
        
        //disable some buttons
        
        //set ARSession
        //niSession?.setARSession(sceneView.session)
        
        //set delegate
        sceneView.session.delegate = self
        sceneView.automaticallyUpdatesLighting = false
        
        //add light to show color
        sceneView.autoenablesDefaultLighting = true
        sceneView.automaticallyUpdatesLighting = true
        
        //start ar session
        
        //make configuration
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravity
        configuration.isCollaborationEnabled = true
        configuration.environmentTexturing = .automatic
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration)
        print("AR Session Started!")
        
        view.addSubview(exitButton)
        view.addSubview(restartButton)
        
        //show feature points in ar experience, usually not used
        //sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        
        //暂时不用辅助界面
//        setupCoachingOverlay()
        
        
        //disable idletimer cause user may not touch screen for a long time
        UIApplication.shared.isIdleTimerDisabled = true
        
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //suspend session
        sceneView.session.pause()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        //退出按钮
        exitButton.frame = CGRect(x: view.frame.size.width - 70,
                                  y: view.frame.size.height - 100,
                                  width: 60,
                                  height: 60)
        exitButton.addTarget(self, action: #selector(didExit), for: .touchUpInside)
        //重启按钮
        restartButton.frame = CGRect(x: 30,
                                     y: view.frame.size.height - 100,
                                     width: 60,
                                     height: 60)
        restartButton.addTarget(self, action: #selector(didRestart), for: .touchUpInside)
        //label
        infoLabel.frame = CGRect(x: view.frame.size.width/2,
                                 y: view.frame.size.height/2 - 40,
                                 width: 200,
                                 height: 40)
        deviceLabel.frame = CGRect(x: view.frame.size.width/2,
                                   y: view.frame.size.height/2 - 80,
                                   width: 200,
                                   height: 40)
    }
    
    @objc private func didExit() {
        let alert = UIAlertController(title: "提醒",
                                      message: "是否返回主界面，当前所有内容都会丢失",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确认",
                                      style: .destructive){ (action) in
            resetMyChessInfo()
            //perform segue
            self.performSegue(withIdentifier: "viewBExitToMain", sender: self)
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
    
    @objc private func didRestart() {
        let alert = UIAlertController(title: "警告",
                                      message: "您确定要重启本局游戏吗",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确认",
                                      style: .destructive) { (action) in
            self.restart()
        })
        alert.addAction(UIAlertAction(title: "取消",
                                      style: .cancel))
        present(alert, animated: true)
    }
    
    
    func restart() {
        resetMyChessInfo()
        firstClick = false
        canPlaceBoard = true
        
        
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravity
        configuration.isCollaborationEnabled = true
        configuration.environmentTexturing = .automatic
        configuration.planeDetection = .horizontal
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    //渲染器
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        //渲染棋盘
        if let name = anchor.name, name.hasPrefix(Constants.chessBoardName) {
            DispatchQueue.main.async {
                self.renderChessBoard(for: node)
                self.infoLabel.text = "渲染结束"
            }
            return
        }
    }
    
    //第一种渲染方法
    func renderChessBoard(for node: SCNNode) {
        guard let url = Bundle.main.url(forResource: "chessBoard", withExtension: "usdz") else { fatalError("can not find resource url") }
        
        guard let boardNode = SCNReferenceNode(url: url) else { fatalError("cannot create chessboard node") }
        originNode = boardNode
        boardNode.load()
        
        //调整棋盘参数
        boardNode.scale = SCNVector3(0.3,0.3,0.3)
        //添加棋盘节点
        node.addChildNode(originNode!)
        MyChessInfo.couldInit = true
        initChessGame()
    }
    
    func initChessGame() {
        view.addSubview(infoLabel)
        view.addSubview(deviceLabel)
        if MyChessInfo.couldInit {
            //randomly pick order
            MyChessInfo.myChessOrder = randomlyPickChessOrder()
            
            //randomly pick color
            MyChessInfo.myChessColor = randomlyPickChessColor()
            
            MyChessInfo.couldInit = false
                 
            if MyChessInfo.myChessOrder == 1 {
                MyChessInfo.canIPlaceChess = true
                setInfoLabel(with: "请您落子")
            }
            if MyChessInfo.myChessOrder == 2 {
                setInfoLabel(with: "等待对方落子")
            }
        }
    }
    
    func loadBlackChess(with pos: simd_float4) -> SCNNode {
        guard let url = Bundle.main.url(forResource: "blackChess", withExtension: "usdz") else { fatalError("can not find resource url") }
        guard let node = SCNReferenceNode(url: url) else { fatalError("cannot establish black chess node") }
        
        node.simdTransform.columns.3 = pos
        node.simdScale = simd_float3(0.5,0.2,0.5)
        
        node.load()
        
        return node
    }
    
    func loadWhiteChess(with pos: simd_float4) -> SCNNode {
        guard let url = Bundle.main.url(forResource: "whiteChess", withExtension: "usdz") else { fatalError("can not find resource url") }
        guard let node = SCNReferenceNode(url: url) else { fatalError("cannot establish black chess node") }
        
        node.simdTransform.columns.3 = pos
        node.simdScale = simd_float3(0.5,0.2,0.5)
        
        node.load()
        return node
    }
    
    
    var count: Int = 0
    //monitoring 30fps update
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        camera = frame.camera

    }
    
    //ARSessionDelegate Monitoring NearbyObjects
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if anchor.name == Constants.blackChessName {
                renderChess(with: anchor, and: 1)
            }
            if anchor.name == Constants.whiteChessName {
                renderChess(with: anchor, and: 2)
            }
        }
    }
    
    func renderChess(with anchor: ARAnchor, and color: Int) {
        guard let originAnchor = sceneView.anchor(for: originNode!) else {print("no origin anchor"); return }
        var localTrans = originAnchor.transform.inverse * anchor.transform.columns.3
        localTrans.y = 0.058
        localTrans.x = Float(lroundf(localTrans.x * Constants.scaleFromWorldToLocal * 10)) / Float(10)
        localTrans.z = Float(lroundf(localTrans.z * Constants.scaleFromWorldToLocal * 10)) / Float(10)
        
        //for testing
        print("\(localTrans.x)")
        print("\(localTrans.z)")
        
        let indexOfX: Int = lroundf(localTrans.x * 10)
        let indexOfY: Int = lroundf(localTrans.z * 10)
        
        //for testing
//            print("\(indexOfX)")
//            print("\(indexOfY)")
        
        //判断是否出界
        if indexOfX > 4 || indexOfX < -4 || indexOfY > 4 || indexOfY < -4 {
            setInfoLabel(with: "放置位置超出范围")
            setDeviceLabel(with: "您的回合，请重新放置")
            MyChessInfo.canIPlaceChess = true
            return
        }
        //判断是否已经落子
        if thereIsAChess(indexOfX: indexOfX, indexOfY: indexOfY) == true {
            setInfoLabel(with: "该处已经有棋子")
            setDeviceLabel(with: "您的回合，请重新放置")
            MyChessInfo.canIPlaceChess = true
            return
        }
        if color == 1 {
            originNode!.addChildNode(loadBlackChess(with: localTrans))
        } else {
            originNode!.addChildNode(loadWhiteChess(with: localTrans))
        }
        updateIndexArray(indexOfX: indexOfY, indexOfY: indexOfY, with: color)
        
        if MyChessInfo.myChessNum >= 5 {
            if WhoIsWinner(MyChessInfo.IndexArray) == MyChessInfo.myChessColor {
                setInfoLabel(with: "您胜利了！")
                setDeviceLabel(with: "游戏结束")
                MyChessInfo.canIPlaceChess = false
                return
            } else {
                setInfoLabel(with: "等待对方落子")
                MyChessInfo.canIPlaceChess = false
                
                return
            }
        } else {
            MyChessInfo.canIPlaceChess = false
            DispatchQueue.main.async {
                self.setInfoLabel(with: "等待对方落子")
                self.setDeviceLabel(with: "对方回合")
                
            }
            return
        }
    }
    
    //Hit test function
    @IBAction func handleTap(_ sender: UITapGestureRecognizer) {
        if sender.state == .ended {
            let location = sender.location(in: sceneView)
            guard let arRayCastQuery = sceneView
                .raycastQuery(from: location,
                              allowing: .estimatedPlane,
                              alignment: .horizontal)
            else {
                return
            }
            guard let result = sceneView.session.raycast(arRayCastQuery).first
            else {
                return
            }
            
            if firstClick == false && canPlaceBoard {
                //create and add chessboard anchor
                let anchor = ARAnchor(name: Constants.chessBoardName, transform: result.worldTransform)
                sceneView.session.add(anchor: anchor)
                
                
                guard let cam = self.camera else { return }
                
                //unused euler data
    //            guard let eulerData = try? JSONEncoder().encode(cam.eulerAngles) else { fatalError("dont have your cam") }
    //            self.mpc?.sendDataToAllPeers(data: eulerData)
                
                let pos = cam.transform.inverse * result.worldTransform.columns.3
                
                
                //有时arkit会多次检测tap，防止程序崩溃，同时保证此时不会产生新的board
                canPlaceBoard = false
                let _ = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { timer in
                    self.firstClick = true
                })
                
            }
            if firstClick == true && MyChessInfo.canIPlaceChess {
                //create and add chess anchor
                if MyChessInfo.myChessColor == 1 {
                    let anchor = ARAnchor(name: Constants.blackChessName, transform: result.worldTransform)
                    sceneView.session.add(anchor: anchor)
                } else if MyChessInfo.myChessColor == 2 {
                    let anchor = ARAnchor(name: Constants.whiteChessName, transform: result.worldTransform)
                    sceneView.session.add(anchor: anchor)
                } else {
                    fatalError("cannot load chess when you dont have color!!")
                }
                //send anchor data
                
                
                MyChessInfo.canIPlaceChess = false
                setInfoLabel(with: "棋子渲染中")
            }
            
           
        }
    }
    
    func setInfoLabel(with string: String) {
        infoLabel.text = string
    }
    
    func setDeviceLabel(with string: String) {
        deviceLabel.text = string
    }

}
