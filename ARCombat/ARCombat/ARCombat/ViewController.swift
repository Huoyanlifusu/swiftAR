//
//  ViewController.swift
//  ARCombat
//
//  Created by 张裕阳 on 2023/2/17.
//

import UIKit
import SceneKit
import ARKit

class ViewController: UIViewController, ARSCNViewDelegate {

    @IBOutlet var sceneView: ARSCNView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = true
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Create a session configuration
        let configuration = ARWorldTrackingConfiguration()

        // Run the view's session
        sceneView.session.run(configuration)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    
    
    func renderer(_ renderer: SCNSceneRenderer, didAdd node: SCNNode, for anchor: ARAnchor) {
        if anchor.name != nil {
            if anchor.name!.hasPrefix("scene") {
                renderScene()
            }
        }
    }
    
    func renderScene() {
        let scene = SCNScene()
        sceneView.scene = scene
        
        //create terrain
        let terrain = SCNNode(geometry: SCNFloor())
        terrain.geometry?.firstMaterial?.diffuse.contents = UIColor.green
        scene.rootNode.addChildNode(terrain)
        
        //create tree
        let tree = SCNTube(innerRadius: 0.1, outerRadius: 0.2, height: 1)
        tree.firstMaterial?.diffuse.contents = UIColor.brown
        let treeNode = SCNNode(geometry: tree)
        treeNode.position = SCNVector3(x: 2, y: 0, z: 2)
        scene.rootNode.addChildNode(treeNode)
        
        //add some lighting
        let ambientLight = SCNLight()
        ambientLight.type = .ambient
        let ambientNode = SCNNode()
        ambientNode.light = ambientLight
        scene.rootNode.addChildNode(ambientNode)
        
        let directionalLight = SCNLight()
        directionalLight.type = .directional
        let directionalNode = SCNNode()
        directionalNode.light = directionalLight
        scene.rootNode.addChildNode(directionalNode)
    }
    
    var onlyCreateOnce: Bool = true
    @IBAction func handleTap(_ sender: UIGestureRecognizer) {
        if sender.state == .ended {
            let location = sender.location(in: sceneView)
            guard let arRayCastQuery = sceneView
                .raycastQuery(from: location,
                              allowing: .estimatedPlane,
                              alignment: .horizontal)
            else { return }
            guard let result = sceneView.session.raycast(arRayCastQuery).first
            else { return }
            
            if onlyCreateOnce {
                sceneView.session.add(anchor: ARAnchor(name: "scene", transform: result.worldTransform))
                onlyCreateOnce = false
            }
            
        }
    }
    
    
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
}



