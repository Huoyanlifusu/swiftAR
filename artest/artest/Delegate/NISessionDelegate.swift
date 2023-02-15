//参考

//import ARKit
//import NearbyInteraction
//import MultipeerConnectivity
//
//@available(iOS 16.0, *)
//class NearbySessionDelegate: NSObject, ObservableObject, ARSessionDelegate, NISessionDelegate {
//    // information details
//    @IBOutlet weak var deviceLable: UILabel!
//    @IBOutlet weak var infoLabel: UILabel!
//    @IBOutlet weak var distanceLabel: UILabel!
//    @IBOutlet weak var cameraCoordinateRelativePositionLabel: UILabel!
//    var peerDisplayName: String = "No Device Connected"
//
//    // some variabels
//    var niSession: NISession?
//    var mpc: MPCSession?
//    var peerDiscoveryToken: NIDiscoveryToken?
//
//    @Published var connectedPeer: MCPeerID?
//    @Published var sharedToeknWithPeers: Bool = false
//    @Published var latestNearbyObject: NINearbyObject?
//
//
//    override init() {
//        super.init()
//        startup()
//    }
//
//    deinit {
//        niSession?.invalidate()
//        mpc?.invalidate()
//    }
//
//    func startup() {
//        niSession = NISession()
//        print("create NISession")
//        niSession?.delegate = self
//        sharedToeknWithPeers = false
//
//        if mpc == nil {
//            startupMPC()
//        }
//
//        if mpc != nil && connectedPeer != nil {
//            startupNI()
//        }
//    }
//
//    func startupMPC() {
//        if mpc == nil {
//            mpc = MPCSession(service: "zyy-artest", identity: "zyy-artest.realdevice", maxPeers: 1)
//            mpc?.peerConnectedHandler = connectedToPeer
//            mpc?.peerDisConnectedHandler = disconnectedToPeer
//            mpc?.peerDataHandler = dataReceivedHandler
//        }
//        mpc?.start()
//        mpc?.invalidate()
//    }
//
//    func startupNI() {
//        if let mytoken = niSession?.discoveryToken {
//            if !sharedToeknWithPeers {
//                shareTokenWithPeers(token: mytoken)
//            }
//
//
//            guard let peerToken = peerDiscoveryToken else {
//                return
//            }
//
//            let config = NINearbyPeerConfiguration(peerToken: peerToken)
//            config.isCameraAssistanceEnabled = true
//
//            niSession?.run(config)
//            print("welldone!")
//        } else {
//            fatalError("connot catch your token.")
//        }
//    }
//
//    func connectedToPeer(peer: MCPeerID) {
//        guard let myToken = niSession?.discoveryToken else {
//            fatalError("Can not find your token while connecting")
//        }
//        if connectedPeer != nil {
//            fatalError("already connected")
//        }
//        if !sharedToeknWithPeers {
//            shareTokenWithPeers(token:myToken)
//        }
//
//        connectedPeer = peer
//        peerDisplayName = peer.displayName
//        deviceLable.text = peerDisplayName
//        infoLabel.text = String("已连接")
//    }
//
//    func disconnectedToPeer(peer: MCPeerID) {
//        if connectedPeer == peer {
//            connectedPeer = nil
//            sharedToeknWithPeers = false
//        }
//    }
//
//    func dataReceivedHandler(data: Data, peer: MCPeerID) {
//        if let discoverytoken = try? NSKeyedUnarchiver.unarchivedObject(ofClass: NIDiscoveryToken.self, from: data) {
//            peerDidShareDiscoveryToken(peer: peer, token: discoverytoken)
//        }
//        if let anchor = try? NSKeyedUnarchiver.unarchivedObject(ofClass: ARAnchor.self, from: data) {
//
//        }
//    }
//
//    func peerDidShareDiscoveryToken(peer: MCPeerID, token: NIDiscoveryToken) {
//
//    }
//
//    func shareTokenWithPeers(token: NIDiscoveryToken) {
//        guard let data = try? NSKeyedArchiver.archivedData(withRootObject: token, requiringSecureCoding: true) else {
//            fatalError("connot encode your token")
//        }
//        mpc?.sendDataToAllPeers(data: data)
//        sharedToeknWithPeers = true
//        print("token shared")
//    }
//
//    //NISessionDelegate Monitoring NearbyObjects
//    func session(_ session: NISession, didUpdate nearbyObjects: [NINearbyObject]) {
//        guard let peerToken = peerDiscoveryToken else {
//            fatalError("don't have peer token")
//        }
//        let nearbyOject = nearbyObjects.first { (obj) -> Bool in
//            return obj.discoveryToken == peerToken
//        }
//        guard let nearbyObjectUpdate = nearbyOject else {
//            return
//        }
//
////        let nextState = getDistanceDirectionState(from: nearbyObjectUpdate)
//        print("2")
//
//        distanceLabel.text = String(format: "%.2f", nearbyObjectUpdate.distance!) + String("m")
//
//        guard let direction = nearbyObjectUpdate.direction else { return }
//        updateCameraCoordinateRelativePositionLabel(direction)
//
//
////        visualisationUpdate(from: currentState, to: nextState, with: nearbyObjectUpdate)
////        currentState = nextState
//    }
//
//    func updateCameraCoordinateRelativePositionLabel(_ direction: simd_float3) {
//        cameraCoordinateRelativePositionLabel.text = String("Right:") + String(format: "%.2f", direction.x)
//        + String("Up:") + String(format: "%.2f", direction.y)
//        + String("Front:") + String(format: "%.2f", direction.z)
//    }
//
//
//
//
//
//
//
//
//    func sessionWasSuspended(_ session: NISession) {
//    }
//
//    func sessionSuspensionEnded(_ session: NISession) {
//        // Session suspension ends. You can run the session again.
//        if let config = self.niSession?.configuration {
//            session.run(config)
//        } else {
//            // Create a valid configuration.
//            startup()
//        }
//    }
//
//    func session(_ session: NISession, didInvalidateWith error: Error) {
//        // If the app lacks user approval for Nearby Interaction, present
//        // an option to go to Settings where the user can update the access.
//        if case NIError.userDidNotAllow = error {
//            return
//        }
//
//        if case NIError.invalidARConfiguration = error {
//            return
//        }
//
//        // Recreate a valid session in other failure cases.
//        startup()
//    }
//
//    func sessionShouldAttemptRelocalization(_ session: ARSession) -> Bool {
//        return false
//    }
//
//}
