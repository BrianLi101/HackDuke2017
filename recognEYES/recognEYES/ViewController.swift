//
//  ViewController.swift
//  recognEYES
//
//  Created by Brian Li on 10/28/17.
//  Copyright © 2017 recognEYES. All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import CoreML
import Vision
import AVFoundation

class ViewController: UIViewController, ARSCNViewDelegate, ARSKViewDelegate {
    
    
    @IBOutlet var sceneView: ARSCNView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        // sceneView.showsStatistics = true
        
        // Create a new scene
        // let scene = SCNScene(named: "art.scnassets/ship.scn")!
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
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
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Release any cached data, images, etc that aren't in use.
    }
    
    // MARK: - ARSCNViewDelegate
    
    /*
     // Override to create and configure nodes for anchors added to the view's session.
     func renderer(_ renderer: SCNSceneRenderer, nodeFor anchor: ARAnchor) -> SCNNode? {
     let node = SCNNode()
     
     return node
     }
     */
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        
        // attempt to access sceneView
        guard let sceneView = self.sceneView else {
            return
        }
        
        // Create anchor using the camera's current position
        if let currentFrame = sceneView.session.currentFrame {
            DispatchQueue.global(qos: .background).async {
                do {
                    let model = try VNCoreMLModel(for: VGG16().model)
                    let request = VNCoreMLRequest(model: model, completionHandler: { (request, error) in
                        // Jump onto the main thread
                        DispatchQueue.main.async {
                            
                            // Access the first result in the array after casting the array as a VNClassificationObservation array
                            
                            
                            guard let results = request.results as? [VNClassificationObservation], let result = results.first else {
                                print ("No results?")
                                return
                            }
                            
                            let text = SCNText(string: result.identifier, extrusionDepth: 0.01)
                            text.firstMaterial?.diffuse.contents = UIColor.white
                            text.font = UIFont(name: "Arial", size: 0.2)
                            
                            let textNode = SCNNode(geometry: text)
                            
                            
                            let camera = self.sceneView.pointOfView!
                            let position = SCNVector3(x: -Float(Double(result.identifier.count) / 2 * 0.1), y: -1.5, z: -5)
                            textNode.position = camera.convertPosition(position, to: nil)
                            textNode.rotation = camera.rotation
                            
                            sceneView.scene.rootNode.addChildNode(textNode)
                            self.textToSpeech(text: result.identifier)
                            
                            //sceneView.pointOfView?.addChildNode(textNode)
                            print(result.identifier)
                            // Create a transform with a translation of 0.2 meters in front of the camera
                            //var translation = matrix_identity_float4x4
                            //translation.columns.3.z = -0.4
                            //let transform = simd_mul(currentFrame.camera.transform, translation)
                            
                            // Add a new anchor to the session
                            //let anchor = ARAnchor(transform: transform)
                            
                            // Set the identifier
                            //ARBridge.shared.anchorsToIdentifiers[anchor] = result.identifier
                            
                            //sceneView.session.add(anchor: anchor)
                        }
                    })
                    
                    let handler = VNImageRequestHandler(cvPixelBuffer: currentFrame.capturedImage, options: [:])
                    try handler.perform([request])
                } catch {}
            }
        }
    }
    
    
    func textToSpeech(text: String) {
        let string = text
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: "en-US")
        
        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)
    }
    
}

