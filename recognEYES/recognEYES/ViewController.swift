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
        
        let button = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        button.backgroundColor = UIColor.red
        button.addTarget(self, action: #selector(resetButtonTapped), for: UIControlEvents.touchUpInside)
        sceneView.addSubview(button)
        button.center = CGPoint(x: button.frame.width, y: button.frame.height)
        
        let settingsButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        settingsButton.backgroundColor = UIColor.blue
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: UIControlEvents.touchUpInside)
        sceneView.addSubview(settingsButton)
        settingsButton.center = CGPoint(x: self.view.frame.width - settingsButton.frame.width, y: settingsButton.frame.height)
    }
    
    @objc func resetButtonTapped() {
        print("shoudl reset")
        
        guard let sceneView = self.sceneView else {
            return
        }
        
        for node in sceneView.scene.rootNode.childNodes {
            node.removeFromParentNode()
        }
        
        //sceneView.scene.rootNode.enumerateChildNodes((node, stop) -> Void, in
           // node.removeFromParentNode())
    }
    
    @objc func settingsButtonTapped() {
        print("shoudl perform sgue")
        self.performSegue(withIdentifier: "openSettings", sender: self)
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

                    var image = sceneView.snapshot()
                    
                    self.getData(image: image)
                    
                
                    
                    /*
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
 */
                } catch {}
            }
        }
    }
    
    
    func textToSpeech(text: String) {
        print("for transkation" + text)
        let string = text
        let utterance = AVSpeechUtterance(string: string)
        utterance.voice = AVSpeechSynthesisVoice(language: Constants.Languages.labelLang[Constants.Languages.targetLang]!)
        
        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)
    }
    
    
    func getData(image: UIImage) {

        // We need to specify that we want to retrieve tags for our image as a parameter to the URL.
        var urlString = "https://westcentralus.api.cognitive.microsoft.com/vision/v1.0/describe?maxCandidates=1"
        
        let url = URL(string: urlString)
        let request = NSMutableURLRequest(url: url!)
        
        // The subscription key is always added as an HTTP header field.
        request.addValue("b232ea13794a40a68c4325a0953cc3de", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        // We need to specify that we're sending the image as binary data, since it's possible to supply a JSON-wrapped URL instead.
        request.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        
        // Convert the image reference to a JPEG binary to submit to the service. If this ends up being over 4 MB, it'll throw an error
        // on the server side. In a production environment, you would check for this condition and handle it gracefully (either reduce
        // the quality, resize the image or prompt the user to take an action).
        let requestData = UIImageJPEGRepresentation(image, 0.9 as CGFloat)
        request.httpBody = requestData
        request.httpMethod = "POST"
        
        let session = URLSession.shared
        
        let task = session.dataTask(with: request as URLRequest) { (data, response, error) in
            if let error = error {
                // In case of an error, handle it immediately and exit without doing anything else.
                //completion(nil, error as NSError)
                print("there was an error")
                return
            }
            
            if let data = data {
                do {
                    let collectionObject = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                    
                    if let dictionary = collectionObject as? [String: Any] {
                        // Enumerate through the result tags and find those with a high enough confidence rating, disregard the rest.
                        
                        if let tagsCaptions = dictionary["description"] as? [String: Any] {

                            if let tags = tagsCaptions["tags"] as? [String] {
                                // this is the label that is attached to an object and the best achieved singular description
                                if (tags[0] == "indoor" || tags[0] == "outdoor") {
                                    let translated = self.translate(text: tags[1], from: "en", to: Constants.Languages.labelLang[Constants.Languages.targetLang]!, isLabel: true)
                                }
                                else{
                                    let translated = self.translate(text: tags[0], from: "en", to: Constants.Languages.labelLang[Constants.Languages.targetLang]!, isLabel: true)
                                }
                            }
                            
                            if Constants.Settings.phrasesOn {
                                if let captions = tagsCaptions["captions"] as? [Any] {
                                    if let best = captions[0] as? [String: Any] {
                                        let typeString = String(describing: type(of: best))
                                        print(typeString)
                                        if let set = best["text"] as? String {
                                            // this is the best version of a description of what's going on
                                            print("this is the set to be translatied" + set)
                                            self.translate(text: set, from: "en", to: Constants.Languages.labelLang[Constants.Languages.targetLang]!, isLabel: false)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
                catch _ {
                }
            } else {
                return
            }
        }
        
        task.resume()
    }
    
    
    func translate(text: String, from: String, to: String, isLabel: Bool)->String {
        print("received text" + text)
        let toSay = text.replacingOccurrences(of: " ", with: "_")
        let toLanguageComponent = "&to=\(to)"
        let fromLanguageComponent = "&from=\(from)"
        let urlString = "https://api.microsofttranslator.com/v2/Http.svc/Translate?text=\(toSay)\(toLanguageComponent)\(fromLanguageComponent)"
            
        let request = NSMutableURLRequest(url: NSURL(string: urlString)! as URL)
        request.httpMethod = "GET"
        request.addValue("c7ee5095141941e89716a7b3388fce8f", forHTTPHeaderField: "Ocp-Apim-Subscription-Key")
        request.addValue("application/octet-stream", forHTTPHeaderField: "Content-Type")
        var translation = ""

        let task = URLSession.shared.dataTask(with: request as URLRequest) {(data, response, error) in
            if let data = data {
                guard let xmlString = NSString(data: data, encoding: String.Encoding.utf8.rawValue) as? String
                else {
                    return
                }
                
                translation = self.translationFromXML(XML: xmlString)
                
                if Constants.Settings.phrasesOn {
                    self.textToSpeech(text: translation)
                }
                
                if isLabel {
                    self.drawLabel(descrip: translation)
                    if !Constants.Settings.phrasesOn {
                        self.textToSpeech(text: translation)
                    }
                }
                
                do {
                    let dict = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
                } catch {
                }
            } else {
                return
            }
        }
        task.resume()
        
        return translation

    }

    private func translationFromXML(XML: String) -> String {
        let translation = XML.replacingOccurrences(of: "<string xmlns=\"http://schemas.microsoft.com/2003/10/Serialization/\">", with: "")
        return translation.replacingOccurrences(of: "</string>", with: "")
    }
 
    
    func drawLabel(descrip: String) {
        print("this is " + descrip)
        let text = SCNText(string: descrip, extrusionDepth: 0.01)
        text.firstMaterial?.diffuse.contents = UIColor.white
        text.font = UIFont(name: "Arial", size: 0.2)
        
        let textNode = SCNNode(geometry: text)
        
        
        let camera = self.sceneView.pointOfView!
        let position = SCNVector3(x: -Float(Double(descrip.count) / 2 * 0.1), y: -1.5, z: -5)
        textNode.position = camera.convertPosition(position, to: nil)
        textNode.rotation = camera.rotation
        
        sceneView.scene.rootNode.addChildNode(textNode)
        
    }
}

