//
//  ViewController.swift
//  Analisar Flores
//
//  Created by Wanderson Hipolito on 12/11/20.
//

import UIKit
import CoreML
import Vision
import Alamofire
import SwiftyJSON

class ViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var flowerImageView: UIImageView!
    
    var pickerView = UIImagePickerController()
    let wikipediaURl = "https://en.wikipedia.org/w/api.php"
    var flowerDescription: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        pickerView.delegate = self
        pickerView.allowsEditing = false
        pickerView.sourceType = .photoLibrary // usar o .camera para a utilização do app em smartfone real.
        
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let userImagePicker = info[UIImagePickerController.InfoKey.originalImage] as? UIImage{
            self.flowerImageView.image = userImagePicker
            
            guard let ciimage = CIImage(image: userImagePicker) else {
                fatalError("Não é possivel converter UIImage em CIImage")
            }
            
            self.detectImage(image: ciimage)
        }
        
        
        pickerView.dismiss(animated: true, completion: nil)
        
    }
    
    
    private func detectImage(image: CIImage) {
        //primeira parte tenho que carregar meu modelo .mlmodel
        guard let model = try?  VNCoreMLModel(for: FlowerCassifier().model) else{
            fatalError("Erro ao tentar carregar o modelo")
        }
        
        //nessa parte tenho que carregar o request
        let request = VNCoreMLRequest(model: model) { (request, error) in
            guard let flowerClassification = request.results?.first as? VNClassificationObservation else{
                fatalError("Não pode classificar a imagem")
            }
            self.navigationItem.title = flowerClassification.identifier.capitalized
            self.requestInformation(flowerName: flowerClassification.identifier)
        
        }
        
        let handler = VNImageRequestHandler(ciImage: image)
        do {
            try handler.perform([request])
            
        } catch {
            print(error.localizedDescription)
            
        }
    
        
    }
    
    
    func requestInformation(flowerName: String) {
        
        let parameters : [String:String] = [
        "format" : "json",
        "action" : "query",
        "prop" : "extracts",
        "exintro" : "",
        "explaintext" : "",
        "titles" : flowerName,
        "indexpageids" : "",
        "redirects" : "1",
        ]
        
        AF.request(wikipediaURl, method: .get, parameters: parameters ).responseJSON { (response) in
            
            switch response.result{
            case .success:
                print("Sucess")
                //print(response)
                let flowerJSON: JSON = JSON(response.value!)
                let pageID = flowerJSON["query"]["pageids"][0].stringValue
                self.flowerDescription = flowerJSON["query"]["pages"][pageID]["extract"].stringValue
                print(self.flowerDescription)
                
            case .failure:
                print("Failure")
            }
        }
        
        
        
        
    }
    
    
    @IBAction func detailButtonPress(_ sender: Any) {
        
        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "gotoDetails"{
            let destinationViewController = segue.destination as! DetalhesViewController
            destinationViewController.destailsText = flowerDescription
            
        }
    }
    
    
    @IBAction func cameraTapped(_ sender: UIBarButtonItem) {
        
        present(pickerView, animated: true, completion: nil)
        
    }
    
    
}

