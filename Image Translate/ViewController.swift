//
//  ViewController.swift
//  Image Translate
//
//  Created by Maxim Kuba on 19.05.2021.
//

import UIKit
import CoreML
import Vision

class ViewController: UIViewController,
                      UIImagePickerControllerDelegate, UINavigationControllerDelegate, UIPickerViewDataSource, UIPickerViewDelegate{

  
  @IBOutlet weak var translationLabel: UILabel!
  
  @IBOutlet weak var pickerView: UIPickerView!
  
  let languages = ["Ukrainian", "German", "Polish"]
  var translationLanguage = "Ukrainian"
  
  func numberOfComponents(in pickerView: UIPickerView) -> Int {
    return 1
  }
  func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
    return languages[row]
  }
  func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
    return languages.count
  }
  func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
    translationLanguage = languages[row]
  }
  
  let imagePicker = UIImagePickerController()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    imagePicker.delegate = self
    imagePicker.sourceType = .camera
    imagePicker.allowsEditing = false
  }
  
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
    if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
      
      //translationLabel.tex = pickedImage
      
      guard let ciimage = CIImage(image: pickedImage) else {
        fatalError("Unable to convert")
      }
      detectObject(pickedImage: pickedImage)
    }
    imagePicker.dismiss(animated: true, completion: nil)
    
    
  }
  
  func detectObject(pickedImage: UIImage)  {
    
    
    guard let ciimage = CIImage(image: pickedImage) else {
      fatalError("Unable to convert")
    }
    guard let model =  try? VNCoreMLModel(for: Inceptionv3().model) else {
      fatalError("Failed to load model")
    }
    let request = VNCoreMLRequest(model: model) { request, error in
      guard let prediction = request.results as? [VNClassificationObservation] else {
        fatalError("Failed to get a prediction")
      }
      let vocab = Vocabulary()
      let translation = vocab.getTranslation(language: self.translationLanguage, object: prediction.first?.identifier ?? "error")
      print(translation)
      self.translationLabel.text = translation
    }
    let handler = VNImageRequestHandler(ciImage: ciimage)
    do {
      try handler.perform([request])
    }
    catch {
      print(error)
    }

  }
    
   
      
  
  
  @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
    present(imagePicker, animated: true, completion: nil)
  }


}

