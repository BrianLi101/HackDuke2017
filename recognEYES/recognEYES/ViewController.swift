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
    // Outlets
    @IBOutlet var sceneView: ARSCNView!
    
    // Variables
    let activityIndicator = UIActivityIndicatorView()
    var isLoading: Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Create a new scene
        let scene = SCNScene()
        
        // Set the scene to the view
        sceneView.scene = scene
        
        // initiate activityIndiator and add to view
        activityIndicator.hidesWhenStopped = true
        activityIndicator.center = self.view.center
        sceneView.addSubview(activityIndicator)
        
        // Programatically create resetButton at top left corner of screen
        let resetButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        resetButton.setImage(UIImage(named: "ResetIcon"), for: .normal)
        resetButton.addTarget(self, action: #selector(resetButtonTapped), for: UIControlEvents.touchUpInside)
        sceneView.addSubview(resetButton)
        resetButton.center = CGPoint(x: resetButton.frame.width, y: resetButton.frame.height)
        
        // Programatically create settingsButton at top right corner of screen
        let settingsButton = UIButton(frame: CGRect(x: 0, y: 0, width: 44, height: 44))
        settingsButton.setImage(UIImage(named: "SettingsIcon"), for: .normal)
        settingsButton.addTarget(self, action: #selector(settingsButtonTapped), for: UIControlEvents.touchUpInside)
        sceneView.addSubview(settingsButton)
        settingsButton.center = CGPoint(x: self.view.frame.width - settingsButton.frame.width, y: settingsButton.frame.height)
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
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
    }
    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
    }

    // Method to remove all previously placed label nodes from the ARScene
    @objc func resetButtonTapped() {
        
        guard let sceneView = self.sceneView else {
            return
        }
        
        // Iterate through all nodes and remove
        for node in sceneView.scene.rootNode.childNodes {
            node.removeFromParentNode()
        }
    }
    
    // Method to programatically call segue for settings window
    @objc func settingsButtonTapped() {
        self.performSegue(withIdentifier: "openSettings", sender: self)
    }
    
    // Method to identify touches on the screen
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        // Check isLoading condition to make sure new call cannot be activated prior to previous one ending
        if(!isLoading) {
            isLoading = true
            animateLoading(run: isLoading)
            
            // attempt to access sceneView
            guard let sceneView = self.sceneView else {
                return
            }
            
            // Create anchor using the camera's current position
            if let currentFrame = sceneView.session.currentFrame {
                DispatchQueue.global(qos: .background).async {
                    do {
                        // Obtain screenshot of the AR Scene
                        var image = sceneView.snapshot()
                        
                        // Pass image to getData method for Microsoft API call
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
    }
    
    // Method for converting text into speech depending on language settings
    func textToSpeech(text: String) {
        let string = text
        let utterance = AVSpeechUtterance(string: string)
        
        // Obtain voice from global variables established in settings
        utterance.voice = AVSpeechSynthesisVoice(language: Constants.Languages.labelLang[Constants.Languages.targetLang]!)
        
        let synth = AVSpeechSynthesizer()
        synth.speak(utterance)
    }
    
    // Method that passes image to Microsoft Vision API for object recognition
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
    
    // Method that handles language translations through Microsoft Translate API
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

    // Helper method to extract XML data into String formate
    private func translationFromXML(XML: String) -> String {
        let translation = XML.replacingOccurrences(of: "<string xmlns=\"http://schemas.microsoft.com/2003/10/Serialization/\">", with: "")
        return translation.replacingOccurrences(of: "</string>", with: "")
    }
 
    // Method to draw AR labels for vocabulary words
    func drawLabel(descrip: String) {
        let text = SCNText(string: descrip, extrusionDepth: 0.01)
        text.firstMaterial?.diffuse.contents = UIColor.white
        text.font = UIFont(name: "Arial", size: 0.2)
        
        let textNode = SCNNode(geometry: text)
        
        
        let camera = self.sceneView.pointOfView!
        let position = SCNVector3(x: -Float(Double(descrip.count) / 2 * 0.1), y: -1.5, z: -5)
        textNode.position = camera.convertPosition(position, to: nil)
        textNode.rotation = camera.rotation
        
        sceneView.scene.rootNode.addChildNode(textNode)
        
        // Call main thread to change UI
        DispatchQueue.main.async {
            self.isLoading = false
            self.animateLoading(run: self.isLoading)
        }
    }
    
    // Method to change status of activityIndicator
    func animateLoading(run: Bool) {
        
        if(run) {
            activityIndicator.startAnimating()
        } else {
            activityIndicator.stopAnimating()
        }
    }
}

