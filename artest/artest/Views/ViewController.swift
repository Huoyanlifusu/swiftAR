//
//  ViewController.swift
//  artest
//
//  Created by 张裕阳 on 2022/9/22.
//

import Foundation
import UIKit
import ARKit
import NearbyInteraction
import MultipeerConnectivity
import RealityKit

@available(iOS 16.0, *)
class ViewController: UIViewController, NISessionDelegate, ARSessionDelegate, ARSCNViewDelegate {
    //scene
    @IBOutlet weak var sceneView: ARSCNView!
    
    @IBOutlet weak var infoLabel: UILabel!
    @IBOutlet weak var deviceLable: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var resetButton: UIButton!
    @IBOutlet weak var cameraCoordinateRelativePositionLabel: UILabel!
    
    @IBOutlet weak var directionLabel: UILabel!
    
    
    //eularAngle & worldPositionDetail
    @IBOutlet weak var eularangleLabel: UILabel!
    @IBOutlet weak var worldPositionLabel: UILabel!
    @IBOutlet weak var worldRelativePositionLabel: UILabel!
    
    //some view
    @IBOutlet weak var DetailView: UIView!
    @IBOutlet weak var DetailUpArrow: UIImageView!
    @IBOutlet weak var DetailDownArrow: UIImageView!
    
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

    
    //some mathematical data
    var camera: ARCamera?
    var eularAngle: simd_float3?
    var worldPosition: simd_float4x4?
    var MePointPeerVector: simd_float3?
    var peerPosToHisWorld: simd_float3?
    
    var eulerangleForSending: simd_float4?
    var peerEulerangle: simd_float4?
    
    var calculatedOriginRelativeDistance: Bool = false
    
    //没用到
    var impactFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
    
    //math concerning variable
    var rollDegree: Float?
    var yawDegree: Float?
    
    //var couldCreateObj: Bool = true
    var peerAnchor: ARAnchor?
    var alreadyAdd = false
    
    
    
    //viewdidload happen before viewdidappear
    override func viewDidLoad() {
        super.viewDidLoad()
        startup()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        //make sure support arworldtracking
        guard ARWorldTrackingConfiguration.isSupported else {
            fatalError("do not support ar world tracking")
        }
        
        //set ARSession
        //niSession?.setARSession(sceneView.session)
        
        //set delegate
        sceneView.session.delegate = self
        
        //start ar session
        let configuration = ARWorldTrackingConfiguration()
        configuration.worldAlignment = .gravity
        configuration.isCollaborationEnabled = true
        configuration.userFaceTrackingEnabled = false
        configuration.environmentTexturing = .automatic
        configuration.planeDetection = [.horizontal, .vertical]
        sceneView.session.run(configuration)
        print("AR Session Started!")
        
        sceneView.debugOptions = ARSCNDebugOptions.showFeaturePoints
        
        setupCoachingOverlay()
        
        //disable idletimer cause user may not touch screen for a long time
        UIApplication.shared.isIdleTimerDisabled = true
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        //suspend session
        sceneView.session.pause()
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
            infoLabel.text = "Discovering Peer ..."
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
    }
    
    func startupNI() {
        //create a session
        
        if let mytoken = niSession?.discoveryToken {
            //share your token
            if !sharedTokenWithPeers {
                shareTokenWithPeers(token: mytoken)
                print("share token!")
            }
            
            //make sure have peerToken
            guard let peerToken = peerDiscoveryToken else {
                return
            }
            
            // set config
            let configuration = NINearbyPeerConfiguration(peerToken: peerToken)
            // configuration.isCameraAssistanceEnabled = true
        
            //run session
            niSession?.run(configuration)
            print("welldone")
            
            
        } else {
            fatalError("Could not catch your token.")
        }
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
        
        infoLabel.text = "已连接"
        deviceLable.text = "链接对象:" + peerDisplayName!
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
        mpc?.sendDataToAllPeers(data: data)
        sharedTokenWithPeers = true
    }
    
    
    
    //put new anchor into node
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if let name = anchor.name, name.hasPrefix(Constants.ObjectName) {
            node.addChildNode(loadModel())
            return
        }
        if let name = anchor.name, name == "Coordinate" {
        }
    }
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
    }
    
    //NISessionDelegate Monitoring NearbyObjects
    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
        guard let peerToken = peerDiscoveryToken else {
            fatalError("don't have peer token")
        }
        let nearbyOject = nearbyObjects.first { (obj) -> Bool in
            return obj.discoveryToken == peerToken
        }
        guard let nearbyObjectUpdate = nearbyOject else {
            return
        }
        
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
            infoLabel.text = "Peer Ended"
        case .timeout:
            
            // The peer timed out, but the session is valid.
            // If the configuration is valid, run the session again.
            if let config = session.configuration {
                session.run(config)
            }
            infoLabel.text = "Peer Timeout"
        default:
            fatalError("Unknown and unhandled NINearbyObject.RemovalReason")
        }
    }
    
    //monitoring 30fps update
    func session(_ session: ARSession, didUpdate frame: ARFrame) {
        let eularAngles = frame.camera.eulerAngles
        eularAngle = eularAngles
        eularangleLabel.text = "x分量 " + String(format: "%.2f", eularAngles.x) + " "
                                + "y分量 " + String(format: "%.2f", eularAngles.y) + " "
        + "z分量 " + String(format: "%.2f", eularAngles.z)
        
        if let worldPositions = session.currentFrame?.camera.transform {
            worldPosition = worldPositions
            let x: Float = worldPositions.columns.3.x
            let y: Float = worldPositions.columns.3.y
            let z: Float = worldPositions.columns.3.z
            worldPositionLabel.text = "WP 东:" + String(format: "%.2f", x)
                + String("天:") + String(format: "%.2f", y)
                + String("南:") + String(format: "%.2f", z)
            sendMyPositionToPeer(with: simd_make_float3(x, y, z))
        }

    }
    
    func sendMyPositionToPeer(with position: simd_float3) {
        guard let data = try? JSONEncoder().encode(position) else { return }
        mpc?.sendDataToAllPeers(data: data)
    }
    
    //ARSessionDelegate Monitoring NearbyObjects
    func session(_ session: ARSession, didAdd anchors: [ARAnchor]) {
//        guard let anchor = anchors.last else { return }
//        if anchor.name == Constants.ObjectName {
//            renderAnchor(for: anchor)
//        }
    }
    
    private func renderAnchor(for anchor: ARAnchor) {
        guard let camera = sceneView.pointOfView else { return }
        let transform = anchor.transform
        let objectNode = loadModel()

        let (min, max) = (objectNode.boundingBox)
        let w = Float(max.x - min.x)
        let h = Float(max.y - min.y)
        objectNode.pivot = SCNMatrix4MakeTranslation(w/2 + min.x, h/2 + min.y, 0)
        let position = SCNVector3(transform.columns.3.x, transform.columns.3.y, transform.columns.3.z)
        objectNode.position = camera.convertPosition(position, to: nil)
        objectNode.eulerAngles = camera.eulerAngles
        sceneView.scene.rootNode.addChildNode(objectNode)
        
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

    
    //handler to data receive
    func dataReceiveHandler(data: Data, peer: MCPeerID) {
        if let discoverytoken = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: data) {
            peerDidShareDiscoveryToken(peer: peer, token: discoverytoken)
        }
        if let anchor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARAnchor.self, from: data) {
            let pos = updateAnchorPosition(for: anchor)
            var newTrans = anchor.transform
            newTrans.columns.3 = pos
//            let transform = updateAnchorOrientation(for: anchor, with: pos)
            let newAnchor = ARAnchor(name: Constants.ObjectName, transform: newTrans)
            sceneView.session.add(anchor: newAnchor)
        }
        if let position = try? JSONDecoder().decode(simd_float3.self, from: data) {
            peerPosToHisWorld = position
        }
        if let eulerangle = try? JSONDecoder().decode(simd_float4.self, from: data) {
            peerEulerangle = eulerangle
            if let eularangle = eularAngle {
                resetWorldOrigin(with: eularangle, and: peerEulerangle!)
            }
        }
    }
    
    func resetWorldOrigin(with myEuler: simd_float3, and peerEuler: simd_float4) {
        let newWorldTransform = correctPose(with: peerEuler, using: myEuler)
        sceneView.session.setWorldOrigin(relativeTransform: newWorldTransform)
    }
    
    //update anchor position
    func updateAnchorPosition(for anchor: ARAnchor) -> simd_float4 {
        //现在求myworld-obj向量 = myworld-mycam + mycam-peercam + peercam-peerworld + peerworld-obj
        if let Vpp = MePointPeerVector, let Vpo = worldPosition, let Vpw = peerPosToHisWorld {
            let newPosition: simd_float4 = simd_make_float4(Vpo.columns.3.x + Vpp.x + anchor.transform.columns.3.x - Vpw.x,
                                                            Vpo.columns.3.y + Vpp.y + anchor.transform.columns.3.y - Vpw.y,
                                                            Vpo.columns.3.z + Vpp.z + anchor.transform.columns.3.z - Vpw.z,
                                                            1)
            return newPosition
        }
        else {
            return anchor.transform.columns.3
        }
    }
    
    //update anchor orientation
//    func updateAnchorOrientation(for anchor: ARAnchor, with pos: simd_float4) -> simd_float4x4 {
//        return
//    }
    
    func addAnchor(anchor: ARAnchor) {
        sceneView.session.add(anchor: anchor)
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
        infoLabel.text = "Session was suspended"
    }
    
    func sessionSuspensionEnded(_ session: NISession) {
        if let config = self.niSession?.configuration {
            session.run(config)
        } else {
            // Create a valid configuration.
            startup()
        }
        
        infoLabel.text = "已连接"
        infoLabel.text = "链接对象" + peerDisplayName!
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
            //if couldCreateObj {
                let anchor = ARAnchor(name: Constants.ObjectName, transform: result.worldTransform)
                sceneView.session.add(anchor: anchor)
                
                //send anchor data
                guard let data = try? NSKeyedArchiver.archivedData(withRootObject: anchor, requiringSecureCoding: true)
                else { fatalError("can't encode anchor") }
                self.mpc?.sendDataToAllPeers(data: data)
                //couldCreateObj = false
            //}
        }
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
    
    //load object model
    func loadModel() -> SCNNode {
        let sphere = SCNSphere(radius: 0.1)
        sphere.firstMaterial?.diffuse.contents = "worldmap.jpg"
        let node = SCNNode(geometry: sphere)
        return node
    }
    
    func loadRobot() -> SCNNode {
        let url = URL(fileURLWithPath: "Materials/biped_robot.usdz")
        let node = SCNReferenceNode(url: url)!
        node.load()
        return node
    }
    
    
    //update visualization information
    func visualisationUpdate(with peer: NINearbyObject) {
        // Animate into the next visuals.
        UIView.animate(withDuration: 0.3, animations: {
            self.animate(with: peer)
        })
    }
    
    func animate(with peer: NINearbyObject) {
        guard let direction = peer.direction else { return }
        guard let distance = peer.distance else { return }

        distanceLabel.text = "距离:" + String(format: "%.2f", distance)
        directionLabel.text = "方向 x:" + String(format: "%.2f", direction.x) + " "
        + "y:" + String(format: "%.2f", direction.y) + " "
        + "z:" + String(format: "%.2f", direction.z)
        
        CoordinateAlignment(direction, distance)
    }
    
    
    //NI的方向数据
    func updateCameraCoordinateRelativePositionLabel(_ direction: SCNVector3) {
        cameraCoordinateRelativePositionLabel.text = String("East:") + String(format: "%.2f", direction.x)
        + String("Up:") + String(format: "%.2f", direction.y)
        + String("South:") + String(format: "%.2f", direction.z)
    }
    
    
    //AR/NI坐标系校准
    func CoordinateAlignment(_ direction: simd_float3, _ distance: Float) {
        guard let eularAngle = eularAngle else { return }
        let worldRelativePosition = coordinateAlignment(eularAngle: eularAngle, direction: direction, distance: distance)
        MePointPeerVector = worldRelativePosition
        worldRelativePositionLabel.text = String("E:") + String(format: "%.2f", worldRelativePosition.x)
                                        + String("U:") + String(format: "%.2f", worldRelativePosition.y)
                                        + String("S:") + String(format: "%.2f", worldRelativePosition.z)
    }
    
    
    
    //放置世界原点(废弃)
    @IBAction func setWorldOrigin(_ sender: Any) {
        eulerangleForSending = simd_float4(eularAngle!, 0)
        guard let data = try? JSONEncoder().encode(eulerangleForSending) else {
            print("cannot encode your eulerangle!")
            return
        }
        mpc?.sendDataToAllPeers(data: data)
    }
    
    func addCoordinateAnchor(using anchorName: String, with transform: simd_float4x4) {
        let coordinate = ARAnchor(name: anchorName, transform: transform)
        sceneView.session.add(anchor: coordinate)
    }
    //        self.animated(from: currentState, to: nextState, with: peer)
    
    //animation function
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
        if let commandData = command.data(using: .utf8) {
            multipeerSession.sendDataToAllPeers(data: commandData)
        }
    }
    
//    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
//        return false
//    }

}

struct Constants {
    static let ObjectName = "Object"
    static let distanceThereshold: Float = 0.4
}

class PosMessage: NSData {
    var name: String
    var value: simd_float3
    
    init(name: String, value: simd_float3) {
        self.name = name
        self.value = value
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
