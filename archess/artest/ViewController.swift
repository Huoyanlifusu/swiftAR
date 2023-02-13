//
//  ViewController.swift
//  artest
//
//  Created by 张裕阳 on 2022/9/22.
//

// 发送码及意义
//  1——收到该信号表示开始游戏，已经建立棋盘
//  2——收到该信号表示对方先手，己方后手
//  3——收到该信号表示己方先手，对方后手
//  4——收到该信号表示己方执白，对方执黑
//  5——收到该信号表示己方执黑，对方执白
//  6--收到该信号表示对方回合已经结束，己方回合开始
//  7--收到该信号表示对方获胜，您输了


import Foundation
import UIKit
import ARKit
import NearbyInteraction
import MultipeerConnectivity
import RealityKit
import SceneKit
import SceneKit.ModelIO


@available(iOS 16.0, *)
class ViewController: UIViewController, NISessionDelegate, ARSessionDelegate, ARSCNViewDelegate {
    
    //Main scene
    @IBOutlet weak var sceneView: ARSCNView!
    
    //some labels
    @IBOutlet weak var deviceLable: UILabel!
    
    @IBOutlet weak var infoLabel: UILabel!
    
    @IBOutlet weak var cameraCoordinateRelativePositionLabel: UILabel!
    
    
    
    
    
    
//    //eularAngle & worldPositionDetail
//    @IBOutlet weak var eularangleLabel: UILabel!
//    @IBOutlet weak var worldPositionLabel: UILabel!
    
    //detail view
    @IBOutlet weak var DetailView: UIView!
//    @IBOutlet weak var DetailUpArrow: UIImageView!
//    @IBOutlet weak var DetailDownArrow: UIImageView!
    
    let coachingOverlayView = ARCoachingOverlayView()
    
    //NISession variable
    var niSession: NISession?
    var peerDiscoveryToken: NIDiscoveryToken?
    var sharedTokenWithPeers = false
    var currentState: DistanceDirectionState = .unknown
    enum DistanceDirectionState {
        case unknown, closeUpInFOV, notCloseUpInFOV, outOfFOV
    }
    
    //MPCSession variable
    var mpc: MPCSession?
    var connectedPeer: MCPeerID?
    var peerDisplayName: String?
    var peerSessionIDs = [MCPeerID: String]()
    
    var sessionIDObservation: NSKeyValueObservation?
    
    
    //some conditional variable
    var alreadyAdd = false
    var couldCollectFeature = false
    var firstClick = false
    
    //chessGameLogicVariable
    var canPlaceBoard = true
    
    //some mathematical data
    var camera: ARCamera?
    var objPos: simd_float4?
    
    var peerTrans: simd_float4x4?
    var peerTransFromARKit: simd_float4x4?
    
    var anchorFromPeer: ARAnchor?
    var chessBoardAnchorFromPeer: ARAnchor?
    var chessAnchorFromPeer: ARAnchor?
    
    var eulerangleForSending: simd_float3?
    var peerEulerangle: simd_float3?
    var peerPos: simd_float4?
    
    //var couldCreateObj: Bool = true
    var peerAnchor: ARAnchor?
    var peerDirection: simd_float3?
    var peerDistance: Float?
    
    //var of chessGame
    var originNode: SCNNode?
    
    //启动画面 暂时停用
//    var imageView: UIImageView = {
//        let imageView = UIImageView(frame: CGRect(x: 0, y: 0, width: 200, height: 200))
//        imageView.image = UIImage(named: "logo")
//        return imageView
//    }()
    
    //退出按钮
    private let exitButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0,
                                            y: 0,
                                            width: 60,
                                            height: 60))
        button.backgroundColor = .systemBlue
        button.layer.cornerRadius = 30
        button.layer.shadowRadius = 10
        button.layer.shadowOpacity = 0.3
        //button.layer.masksToBounds = true
        let image = UIImage(systemName: "arrowshape.turn.up.backward.fill",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 32,
                                                                           weight: .medium))
        button.setImage(image, for: .normal)
        button.tintColor = .white
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private let myTurnLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0,
                                          y: 0,
                                          width: 180,
                                          height: 30))
        label.font = UIFont(name: "hongleisim-Regular", size: 30)
        label.text = "您的回合"
        return label
    }()
    
    private let peerTurnLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0,
                                          y: 0,
                                          width: 180,
                                          height: 30))
        label.text = "对方回合"
        label.font = UIFont(name: "hongleisim-Regular", size: 30)
        return label
    }()
    
    private let playImageView: UIImageView = {
        let image = UIImage(systemName: "play.fill",
                            withConfiguration: UIImage.SymbolConfiguration(pointSize: 28,
                                                                           weight: .medium))
        let view = UIImageView(frame: CGRect(x: 0,
                                             y: 0,
                                             width: 25,
                                             height: 25))
        view.image = image
        return view
    }()
    
    func rotateView(for imageView: UIImageView) {
        imageView.transform = CGAffineTransform(rotationAngle: .pi)
    }
    
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
//        view.addSubview(imageView)
        for family in UIFont.familyNames.sorted() {
            let names = UIFont.fontNames(forFamilyName: family)
            print(family, names)
        }
        startup()
    }
    
//    override func viewDidLayoutSubviews() {
//        super.viewDidLayoutSubviews()
//        DispatchQueue.main.asyncAfter(deadline: .now()+1, execute: {
//
//        })
//    }
    
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //make sure support arworldtracking
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
        
        //show feature points in ar experience, usually not used
        //sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        
        setupCoachingOverlay()
        
        
        //disable idletimer cause user may not touch screen for a long time
        UIApplication.shared.isIdleTimerDisabled = true
        
        sessionIDObservation = observe(\.sceneView.session.identifier, options: [.new]) { object, change in
            print("SessionID changed to: \(change.newValue!)")
            // Tell all other peers about your ARSession's changed ID, so
            // that they can keep track of which ARAnchors are yours.
            guard let multipeerSession = self.mpc else { return }
            self.sendARSessionIDTo(peers: multipeerSession.connectedPeers)
        }
        
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //suspend session
        sceneView.session.pause()
        
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        exitButton.frame = CGRect(x: view.frame.size.width - 70,
                                  y: view.frame.size.height - 100,
                                  width: 60,
                                  height: 60)
        exitButton.addTarget(self, action: #selector(didExit), for: .touchUpInside)
        //您的回合label位置
        myTurnLabel.frame = CGRect(x: 50,
                                   y: 30,
                                   width: 180,
                                   height: 30)
        peerTurnLabel.frame = CGRect(x: 200,
                                     y: 30,
                                     width: 180,
                                     height: 30)
        playImageView.frame = CGRect(x: 170,
                                     y: 35,
                                     width: 25,
                                     height: 25)
        
    }
    
    
    func startup() {
        //create Session
        if niSession == nil {
            niSession = NISession()
            print("create NIsession")
            
            //set a delegate
            niSession?.delegate = self
            sharedTokenWithPeers = false
        }
        
        if mpc == nil {
            
            startupMPC()
            currentState = .unknown
        }
        
        if mpc != nil && connectedPeer != nil {
            startupNI()
        }
    }
    
    func startupMPC() {
        if mpc == nil {
            #if targetEnvironment(simulator)
            mpc = MPCSession(service: "zyy-artest", identity: "zyy-artest.simulator", maxPeers: 1)
            #else
            mpc = MPCSession(service: "zyy-artest", identity: "zyy-artest.realdevice", maxPeers: 1)
            #endif
            mpc?.peerConnectedHandler = connectedToPeer
            mpc?.peerDisConnectedHandler = disconnectedToPeer
            mpc?.peerDataHandler = dataReceiveHandler
        }
        mpc?.invalidate()
        mpc?.start()
        setInfoLabel(with: "正在寻找同伴")
        setDeviceLabel(with: "未连接")
    }
    
    func startupNI() {
        //create a session
        
        if let mytoken = niSession?.discoveryToken {
            //share your token
            if !sharedTokenWithPeers {
                shareTokenWithPeers(token: mytoken)
            }
            
            //make sure have peerToken
            guard let peerToken = peerDiscoveryToken else {
                return
            }
            
            // set config
            let configuration = NINearbyPeerConfiguration(peerToken: peerToken)
            configuration.isCameraAssistanceEnabled = false
        
            //run session
            niSession?.run(configuration)
            
            
        } else {
            fatalError("Could not catch your token.")
        }
    }
    
    @objc private func didExit() {
        let alert = UIAlertController(title: "提醒",
                                      message: "是否返回主界面，当前所有内容都会丢失",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "确认",
                                      style: .destructive){ (action) in
            //暂停mpc
            if self.mpc != nil {
                self.mpc?.suspend()
                self.mpc = nil
            }
            
            self.performSegue(withIdentifier: "exitToMain", sender: self)
        })
        alert.addAction(UIAlertAction(title: "取消", style: .cancel))
        present(alert, animated: true)
    }
    
    //handler of connection
    func connectedToPeer(peer: MCPeerID) {
        guard let myToken = niSession?.discoveryToken else {
            fatalError("Can not find your token while connecting")
        }
        
        if connectedPeer != nil {
            fatalError("already connected")
        }
        
        if !sharedTokenWithPeers {
            shareTokenWithPeers(token: myToken)
        }
        
        connectedPeer = peer
        peerDisplayName = peer.displayName
        
        
        DispatchQueue.main.async {
            self.setInfoLabel(with: "已连接，请您点击并开始游戏")
            self.setDeviceLabel(with: "链接对象" + peer.displayName)
        }
    }
    
    //handle to disconnect
    func disconnectedToPeer(peer: MCPeerID) {
        if connectedPeer == peer {
            connectedPeer = nil
            sharedTokenWithPeers = false
        }
    }
    
    //share token
    func shareTokenWithPeers(token: NIDiscoveryToken) {
        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true) else {
            fatalError("cannot encode your token")
        }
        self.mpc?.sendDataToAllPeers(data: data)
        sharedTokenWithPeers = true
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
        //渲染同伴
        if let participant = anchor as? ARParticipantAnchor {
            node.addChildNode(loadModel())
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
    
//    func loadBoardAsScene()  {
//        //第二种渲染方法
//        let path = FileManager.default.urls(for: .documentDirectory,
//                                             in: .userDomainMask)[0]
//        .appendingPathComponent("chessBoard.usdz")
//        let asset = MDLAsset(url: path)
//
//        asset.loadTextures()
//        let scene = SCNScene(mdlAsset: asset)
//        sceneView.scene = scene
//
//    }
    
    //渲染棋子
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
                sendCodeToPeer(with: 7)
                return
            } else {
                setInfoLabel(with: "等待对方落子")
                sendCodeToPeer(with: 6)
                
                DispatchQueue.main.async {
                    self.myTurnLabel.alpha = 0.2
                    self.peerTurnLabel.alpha = 1
                    self.rotateView(for: self.playImageView)
                }
                return
            }
        } else {
            setInfoLabel(with: "等待对方落子")
            setDeviceLabel(with: "对方回合")
            sendCodeToPeer(with: 6)
            
            DispatchQueue.main.async {
                self.myTurnLabel.alpha = 0.2
                self.peerTurnLabel.alpha = 1
                self.rotateView(for: self.playImageView)
            }
            return
        }
    }
    
    //load object model
    func loadModel() -> SCNNode {
        let sphere = SCNSphere(radius: 0.05)
        sphere.firstMaterial?.diffuse.contents = "worldmap.jpg"
        let node = SCNNode(geometry: sphere)
        return node
    }
    
    //指定位置放置棋子
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
    
    
    //decrepted
//    func loadBlackChess() -> SCNNode {
//        guard let url = Bundle.main.url(forResource: "blackChess", withExtension: "usdz") else { fatalError("can not find resource url") }
//        guard let node = SCNReferenceNode(url: url) else { fatalError("cannot establish black chess node") }
//        node.load()
//        return node
//    }
//
//    func loadWhiteChess() -> SCNNode {
//        guard let url = Bundle.main.url(forResource: "whiteChess", withExtension: "usdz") else { fatalError("can not find resource url") }
//        guard let node = SCNReferenceNode(url: url) else { fatalError("cannot establish black chess node") }
//        node.load()
//        return node
//    }
        
    
    func session(_ session: ARSession, didOutputCollaborationData data: ARSession.CollaborationData) {
        guard let multipeerSession = mpc else { return }
        if !multipeerSession.connectedPeers.isEmpty {
            guard let encodedData = try? NSKeyedArchiver.archivedData(withRootObject: data, requiringSecureCoding: true)
            else { fatalError("Unexpectedly failed to encode collaboration data.") }
            // Use reliable mode if the data is critical, and unreliable mode if the data is optional.
            let dataIsCritical = data.priority == .critical
            multipeerSession.sendDataToAllPeers(data: encodedData)
        } else {
            print("Deferred sending collaboration to later because there are no peers.")
        }
    }
    
    //NISessionDelegate Monitoring NearbyObjects
    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        //当处理数据时停止实时测量
        
        guard let peerToken = peerDiscoveryToken else {
            fatalError("don't have peer token")
        }
        let nearbyOject = nearbyObjects.first { (obj) -> Bool in
            return obj.discoveryToken == peerToken
        }
        guard let nearbyObjectUpdate = nearbyOject else {
            return
        }
        peerTrans = session.worldTransform(for: nearbyObjectUpdate)
        visualisationUpdate(with: nearbyObjectUpdate)
    }
    
    
    func session(_ session: NISession, didRemove nearbyObjects: [NINearbyObject], reason: NINearbyObject.RemovalReason) {
        guard let peerToken = peerDiscoveryToken else {
            fatalError("don't have peer token")
        }
        // Find the right peer.
        let peerObj = nearbyObjects.first { (obj) -> Bool in
            return obj.discoveryToken == peerToken
        }

        if peerObj == nil {
            return
        }
        
        currentState = .unknown

        switch reason {
        case .peerEnded:
            // The peer token is no longer valid.
            peerDiscoveryToken = nil
            
            // The peer stopped communicating, so invalidate the session because
            // it's finished.
            session.invalidate()
            
            // Restart the sequence to see if the peer comes back.
            startup()
            
            // Update the app's display.
            //infoLabel.text = "Peer Ended"
        case .timeout:
            
            // The peer timed out, but the session is valid.
            // If the configuration is valid, run the session again.
            if let config = session.configuration {
                session.run(config)
            }
            //infoLabel.text = "Peer Timeout"
        default:
            fatalError("Unknown and unhandled NINearbyObject.RemovalReason")
        }
    }
    
    
    
    var count: Int = 0
    //monitoring 30fps update
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        
        camera = frame.camera
        
        //decrepted 显示相机参数
//        DispatchQueue.main.async {
//            self.eularangleLabel.text = "欧拉角 x " + String(format: "%.2f", eularAngles.x) + " "
//                                    + "y " + String(format: "%.2f", eularAngles.y) + " "
//                                    + "z " + String(format: "%.2f", eularAngles.z)
//            if let worldPositions = session.currentFrame?.camera.transform {
//                let x: Float = worldPositions.columns.3.x
//                let y: Float = worldPositions.columns.3.y
//                let z: Float = worldPositions.columns.3.z
//                self.worldPositionLabel.text = "距离世界原点 x:" + String(format: "%.2f", x)
//                    + String("y:") + String(format: "%.2f", y)
//                    + String("z:") + String(format: "%.2f", z)
//                sendMyPositionToPeer(with: simd_make_float3(x, y, z))
//            }
//        }
        guard let multipeer = mpc else { return }
        
        switch frame.worldMappingStatus {
        case .notAvailable, .limited:
            return
        case .extending:
            return
        case .mapped:
            return
        @unknown default:
            return
        }

    }
    
    //ARSessionDelegate Monitoring NearbyObjects
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
        for anchor in anchors {
            if let participantAnchor = anchor as? ARParticipantAnchor {
                //messageLabel.displayMessage("Established joint experience with a peer.")
                peerTransFromARKit = participantAnchor.transform
                //add the peer anchor to the session
                sceneView.session.add(anchor: participantAnchor)
                
                print("do receive peer anchor in session")
            }
            if anchor.name == Constants.blackChessName {
                renderChess(with: anchor, and: 1)
            }
            if anchor.name == Constants.whiteChessName {
                renderChess(with: anchor, and: 2)
            }
        }
    }
    
    
    func session(_ session: ARSession, didUpdate anchors: [ARAnchor]) {
        for anchor in anchors {
            if anchor.name == "peer" {
                session.remove(anchor: anchor)
                session.add(anchor: anchor)
            }
        }
    }
    
    //handler to connect
    
    var mapProvider: MCPeerID?
    //handler to data receive
    func dataReceiveHandler(data: Data, peer: MCPeerID) {
        if let collaborationData = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARSession.CollaborationData.self, from: data) {
            sceneView.session.update(with: collaborationData)
        }
        
        if let worldmap = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARWorldMap.self, from: data)
        {
            let configuration = ARWorldTrackingConfiguration()
            configuration.initialWorldMap = worldmap
            configuration.planeDetection = .horizontal
            
            sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
            
            mapProvider = peer
        }

        
        
        if let discoverytoken = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: data) {
            peerDidShareDiscoveryToken(peer: peer, token: discoverytoken)
        }
        if let pos = try? JSONDecoder().decode(simd_float4.self, from: data) {
            if canPlaceBoard == true {
                guard let boardAnchor = chessBoardAnchorFromPeer else { print("未收到棋盘anchor信息"); return }
                addPeerAnchor(with: boardAnchor, and: pos)
                
                canPlaceBoard = false
                setInfoLabel(with: "渲染完成，等待初始化")
            } else {
                guard let chessAnchor = chessAnchorFromPeer else { print("未收到棋子anchor信息"); return }
                addPeerAnchor(with: chessAnchor, and: pos)
            }
            
            
               
                
        }
        if let anchor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARAnchor.self, from: data) {
            if anchor.name == Constants.chessBoardName {
                chessBoardAnchorFromPeer = anchor
            }
            if anchor.name == Constants.blackChessName {
                chessAnchorFromPeer = anchor
            }
            if anchor.name == Constants.whiteChessName {
                chessAnchorFromPeer = anchor
            }
            anchorFromPeer = anchor
        }
        
        if let code = try? JSONDecoder().decode(Int.self, from: data) {
            switch code {
            case 1:
                firstClick = true
                MyChessInfo.couldInit = false
                setInfoLabel(with: "初始化已完成")
                return
            case 2:
                setInfoLabel(with: "等待对方落子")
                myTurnLabel.alpha = 0.2
                peerTurnLabel.alpha = 1
                MyChessInfo.myChessOrder = 2
                return
            case 3:
                MyChessInfo.canIPlaceChess = true
                setInfoLabel(with: "请您放置棋子")
                //rotate play image
                
                rotateView(for: playImageView)
                myTurnLabel.alpha = 1
                peerTurnLabel.alpha = 0.2
                MyChessInfo.myChessOrder = 1
                return
            case 4:
                MyChessInfo.myChessColor = 2
                return
            case 5:
                MyChessInfo.myChessColor = 1
                return
            case 6:
                MyChessInfo.canIPlaceChess = true
                setInfoLabel(with: "请您放置棋子")
                
                rotateView(for: playImageView)
                myTurnLabel.alpha = 1
                peerTurnLabel.alpha = 0.2
                
                return
            case 7:
                setInfoLabel(with: "您输了！")
                setDeviceLabel(with: "游戏结束！")
                return
                
            default:
                return
            }
            
        }
        
        //unused
//        if let eulerangle = try? JSONDecoder().decode(simd_float3.self, from: data) {
//            peerEulerangle = eulerangle
//            resetWorldOrigin(with: eularangle, and: peerEulerangle)
//        }
    }
    
    func addPeerAnchor(with anchor: ARAnchor, and pos: simd_float4) {
        //使用NI数据进行两次位姿转换 Pcam->MyCam->MyWorld
        guard let cam = camera else { return }
        guard let direction = peerDirection else { return }
        guard let distance = peerDistance else { return }
        
        let peerPos = alignDistanceWithNI(distance: distance, direction: direction)
        
        //使用NI库自带的peer位姿矩阵 和 peercam坐标系坐标 求解世界坐标系坐标
        guard let peerT = peerTransFromARKit else { print("not peerT!");return }
        
        let peerTrans: simd_float4x4 = simd_float4x4(peerT.columns.0,
                                                 peerT.columns.1,
                                                 peerT.columns.2,
                                                 Constants.weight * peerT.columns.3 + (1 - Constants.weight) * peerPos)
        
        let objPos = cam.transform * peerTrans * pos
        let objTrans = simd_float4x4(anchor.transform.columns.0,
                                     anchor.transform.columns.1,
                                     anchor.transform.columns.2,
                                     objPos)
        
        let newAnchor = ARAnchor(name: anchor.name!, transform: objTrans)
        
        print("成功添加peer传来的" + "\(anchor.name!)" + "物体")
        sceneView.session.add(anchor: newAnchor)
    }
    
    func resetWorldOrigin(with myEuler: simd_float3, and peerEuler: simd_float3) {
        let newWorldTransform = correctPose(with: peerEuler, using: myEuler)
        sceneView.session.setWorldOrigin(relativeTransform: newWorldTransform)
    }
    
    //receive peer token
    func peerDidShareDiscoveryToken(peer: MCPeerID, token: NIDiscoveryToken) {
        if connectedPeer != peer {
            fatalError("receive token from unexpected token")
        }
        
        peerDiscoveryToken = token
        //create a config
        
        startupNI()
        
    }
    
    //handling interruption and suspension
    func sessionWasSuspended(_ session: NISession) {
        //infoLabel.text = "Session was suspended"
    }
    
    func sessionSuspensionEnded(_ session: NISession) {
        if let config = self.niSession?.configuration {
            session.run(config)
        } else {
            // Create a valid configuration.
            startup()
        }
        DispatchQueue.main.async {
            //self.infoLabel.text = "已连接"
            //self.infoLabel.text = "链接对象" + self.peerDisplayName!
        }
    }
    
    
    func sendCodeToPeer(with number: Int) {
        guard let multipeer = mpc else { fatalError("No peer connected") }
        guard let codeData = try? JSONEncoder().encode(number) else { fatalError("cannot encode this data") }
        multipeer.sendDataToAllPeers(data: codeData)
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
                guard let anchorData = try? NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true)
                else { fatalError("can't encode anchor") }
                //send anchor data
                self.mpc?.sendDataToAllPeers(data: anchorData)
                
                //change the state that you hit the first click
                sendCodeToPeer(with: 1)
                
                guard let cam = self.camera else { return }
                
                //unused euler data
    //            guard let eulerData = try? JSONEncoder().encode(cam.eulerAngles) else { fatalError("dont have your cam") }
    //            self.mpc?.sendDataToAllPeers(data: eulerData)
                
                let pos = cam.transform.inverse * result.worldTransform.columns.3
                guard let posData = try? JSONEncoder().encode(pos) else { fatalError("cannot encode simd_float3x3") }
                self.mpc?.sendDataToAllPeers(data: posData)
                
                
                //有时arkit会多次检测tap，防止程序崩溃，同时保证此时不会产生新的board
                canPlaceBoard = false
                let _ = Timer.scheduledTimer(withTimeInterval: 0.3, repeats: false, block: { timer in
                    self.firstClick = true
                })
                
            }
            if firstClick == true && MyChessInfo.canIPlaceChess {
                //create and add chess anchor
                let anchor = ARAnchor(name: Constants.blackChessName, transform: result.worldTransform)
                
                
                sceneView.session.add(anchor: anchor)
                guard let anchorData = try? NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true)
                else { fatalError("can't encode anchor") }
                //send anchor data
                self.mpc?.sendDataToAllPeers(data: anchorData)
                
                guard let cam = self.camera else { return }
                
                //unused euler data
    //            guard let eulerData = try? JSONEncoder().encode(cam.eulerAngles) else { fatalError("dont have your cam") }
    //            self.mpc?.sendDataToAllPeers(data: eulerData)
                
                let pos = cam.transform.inverse * result.worldTransform.columns.3
                guard let posData = try? JSONEncoder().encode(pos) else { fatalError("cannot encode simd_float3x3") }
                self.mpc?.sendDataToAllPeers(data: posData)
                
                MyChessInfo.canIPlaceChess = false
                setInfoLabel(with: "棋子渲染中")
            }
            
            
            

           
        }
    }
    
    
    @IBAction func shareSession(_ sender: Any) {
        sceneView.session.getCurrentWorldMap(completionHandler: {
            worldmap, error in
            guard let map = worldmap else { print("Error: \(error!.localizedDescription)"); return }
            guard let data = try? NSKeyedArchiver.archivedData(withRootObject: map, requiringSecureCoding: true) else {
                fatalError("Cannot archive world map!")
            }
            self.mpc?.sendDataToAllPeers(data: data)
        })
    }
    
    //get distance&direction state
    func getDistanceDirectionState(from nearbyObject: NINearbyObject) -> DistanceDirectionState {
        if nearbyObject.distance == nil && nearbyObject.direction == nil {
            return .unknown
        }

        let isNearby = nearbyObject.distance.map(isNearby(_:)) ?? false
        let directionAvailable = nearbyObject.direction != nil

        if isNearby && directionAvailable {
            return .closeUpInFOV
        }

        if !isNearby && directionAvailable {
            return .notCloseUpInFOV
        }

        return .outOfFOV
    }
    
    func isNearby(_ distance: Float) -> Bool {
        return distance < Constants.distanceThereshold
    }

    //decrepted
//    func loadRobot() -> SCNNode {
//        let url = URL(fileURLWithPath: "Materials/biped_robot.usdz")
//        let node = SCNReferenceNode(url: url)!
//        node.load()
//        return node
//    }
    
    
    
    
    
    //update visualization information
    func visualisationUpdate(with peer: NINearbyObject) {
        // Animate into the next visuals.
        guard let direction = peer.direction else { return }
        peerDirection = direction
        guard let distance = peer.distance else { return }
        peerDistance = distance
        
//        DispatchQueue.main.async {
//            self.distanceLabel.text = "距离:" + String(format: "%.2f", distance)
//            self.directionLabel.text = "方向 x:" + String(format: "%.2f", direction.x) + " "
//            + "y:" + String(format: "%.2f", direction.y) + " "
//            + "z:" + String(format: "%.2f", direction.z)
//        }
        
        //使用ar的collaboration数据时无法使用该变量
//        guard let transform = niSession?.worldTransform(for: peer) else { return }
//        peerTrans = transform
//        print("NI data is ready")
    }
    
    
    //NI的方向数据
    func updateCameraCoordinateRelativePositionLabel(_ direction: SCNVector3) {
        DispatchQueue.main.async {
            self.cameraCoordinateRelativePositionLabel.text = String("East:") + String(format: "%.2f", direction.x)
            + String("Up:") + String(format: "%.2f", direction.y)
            + String("South:") + String(format: "%.2f", direction.z)
        }
    }
    
    
    @IBAction func setWorldOrigin(_ sender: Any) {
        guard let cam = camera else { return }
        let euler = simd_make_float4(cam.eulerAngles, 100)
        guard let data = try? JSONEncoder().encode(euler) else {
            print("cannot encode your eulerangle!")
            return
        }
        self.mpc?.sendDataToAllPeers(data: data)
    }
    
    //animation function example
//    private func animated(from currentState: DistanceDirectionState, to nextState: DistanceDirectionState, with peer: NINearbyObject) {
//    }
//                dx = relativeDirection.x
//                dy = relativeDirection.y
//                dz = relativeDirection.z
//                // some label data
//                let azumith = azumith(from: relativeDirection)
//                let elevation = elevation(from: relativeDirection)
//
//                let Dx: Float = dx! * relativeDistance
//                let Dy: Float = dy! * relativeDistance
//                let Dz: Float = dz! * relativeDistance
//
//                cameraCoordinateRelativePositionLabel.text = String("Right") + String(format: "%.2f", Dx)
//                                                            + String("Up") + String(format: "%.2f", Dy)
//                                                            + String("Front") + String(format: "%.2f", Dz)
//
//                distanceLabel.text = String(format: "%.3f", relativeDistance)
                
                //how we put anchor into peer's device
//                if let eularAngles, let camera {
//                    let angles = relativePosition(eularAngle: eularAngles, azumith: azumith, elevation: elevation)
//                    let cameraTransform = camera.transform
//                    let relativePosition = simd_float3(relativeDistance*cos(angles.y)*cos(angles.x),
//                                                       relativeDistance*cos(angles.y)*sin(angles.x),
//                                                       relativeDistance*sin(angles.y))
//                    let peerTransform = translation(from: cameraTransform, with: relativePosition)
//                    peerAnchor = ARAnchor(name: "peer", transform: peerTransform)
//                    if !alreadyAdd && peerAnchor != nil {
//                        scenevView.session.add(anchor: peerAnchor!)
//                        alreadyAdd = true
//                    }
//                }
                
                
//                if elevation < 0 {
//                    DetailDownArrow.alpha = 1.0
//                    DetailUpArrow.alpha = 0.0
//                } else {
//                    DetailDownArrow.alpha = 0.0
//                    DetailUpArrow.alpha = 1.0
//                }
//
//            } else {
//                distanceLabel.text = String(format: "0.3f", relativeDistance)
//                print("no direction data")
//            }
//        } else {
//            print("no distance data")
//        }
    internal func setInfoLabel(with string: String) {
        DispatchQueue.main.async {
            self.infoLabel.text = string
        }
    }
    
    internal func setDeviceLabel(with string: String) {
        DispatchQueue.main.async {
            self.deviceLable.text = string
        }
    }
    

    
    
    
    
    
    @IBAction func collectFeature(_ sender: Any) {
        couldCollectFeature = true
    }
    
    
    
    
    //use button to reset tracking
    @IBAction func resetTracking(_ sender: UIButton?) {
        let configuration = ARWorldTrackingConfiguration()
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration, options: [.removeExistingAnchors, .resetTracking])
    }
    
    //use coachingoverlayview to reset tracking
    @IBAction func resetTracking() {
        guard let configuration = sceneView.session.configuration as? ARWorldTrackingConfiguration else { print("A configuration is required"); return }
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    
    func restartByButton() {
        
    }
    
    
    //清理自己创造的棋子和棋盘
    @IBAction func removeAllAnchorsYouCreated(_ sender: UIButton?) {
        guard let frame = sceneView.session.currentFrame else { return }
        for anchor in frame.anchors {
            guard let anchorSessionID = anchor.sessionIdentifier else { continue }
            if anchorSessionID.uuidString == sceneView.session.identifier.uuidString {
                sceneView.session.remove(anchor: anchor)
            }
        }
        //couldCreateObj = true
    }
    
    private func removeAllAnchorsOriginatingFromARSessionWithID(_ identifier: String) {
        guard let frame = sceneView.session.currentFrame else { return }
        for anchor in frame.anchors {
            guard let anchorSessionID = anchor.sessionIdentifier else { continue }
            if anchorSessionID.uuidString == identifier {
                sceneView.session.remove(anchor: anchor)
            }
        }
        //couldCreateObj = true
    }
    
    private func sendARSessionIDTo(peers: [MCPeerID]) {
        guard let multipeerSession = mpc else { return }
        let idString = sceneView.session.identifier.uuidString
        let command = "SessionID:" + idString
        //将字符串类型转为data
        if let commandData = command.data(using: .utf8) {
            multipeerSession.sendDataToAllPeers(data: commandData)
        }
    }
    
    
    func initChessGame() {
        var code1: Int?
        var code2: Int?
        if MyChessInfo.couldInit {
            //randomly pick order
            MyChessInfo.myChessOrder = randomlyPickChessOrder()
            view.addSubview(myTurnLabel)
            view.addSubview(peerTurnLabel)
            view.addSubview(playImageView)
            if MyChessInfo.myChessOrder == 1 {
                code1 = 2
            }
            if MyChessInfo.myChessOrder == 2 {
                code1 = 3
            }
            
            //randomly pick color
            MyChessInfo.myChessColor = randomlyPickChessColor()
            if MyChessInfo.myChessColor == 1 {
                code2 = 4
            }
            if MyChessInfo.myChessColor == 2 {
                code2 = 5
            }
            
            MyChessInfo.couldInit = false
           
            print("\(code1!),\(code2!)")
            
            initCodeReceiver(code1!, code2!)
            
            
            if MyChessInfo.myChessOrder == 1 {
                MyChessInfo.canIPlaceChess = true
                setInfoLabel(with: "请您落子")
                peerTurnLabel.alpha = 0.2
                myTurnLabel.alpha = 1
                rotateView(for: playImageView)
            }
            if MyChessInfo.myChessOrder == 2 {
                setInfoLabel(with: "等待对方落子")
                myTurnLabel.alpha = 0.2
                peerTurnLabel.alpha = 1
            }
        }
    }
    
    
    func initCodeReceiver(_ code1: Int, _ code2: Int) {
        sendCodeToPeer(with: code1)
        sendCodeToPeer(with: code2)
    }
    
    

}

struct Constants {
    //obj name
    static let ObjectName = "Object"
    
    //ChessBoard&Chess Name
    static let chessBoardName = "ChessBoard"
    
  
    
    static let blackChessName = "BlackChess"
    static let whiteChessName = "WhiteChess"
    
    //mathmatic constant
    static let distanceThereshold: Float = 0.4
    static let frameNum: Int = 2
    static let weight: Float = 0.8
    
    static let scaleFromWorldToLocal: Float = 3.3
    
    //UI界面参数
    static let myLabelAlpha = 1
    static let peerLabelAlpha = 0.2
}
