//
//  ViewController.swift
//  NudityTest
//
//  Created by Mahmudul Hasan on 2022-10-12.
//

import UIKit
import PhotosUI
import NSFWDetector

class ViewController: UIViewController, UINavigationControllerDelegate, UIImagePickerControllerDelegate, PHPickerViewControllerDelegate {

  let imageView = UIImageView()

  let resultLabel = UILabel()

  let checkButton = UIButton()
  let pickButton = UIButton()


  override func viewDidLoad() {
    super.viewDidLoad()
    // Do any additional setup after loading the view.

    configureImageView()
    configureLabel()
    configureCheckButton()
    configurePickButton()
  }


  func configureImageView(){
    view.addSubview(imageView)
    imageView.translatesAutoresizingMaskIntoConstraints = false

    imageView.backgroundColor = .systemGray6

    NSLayoutConstraint.activate([
      imageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10),
      imageView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
      imageView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
      imageView.heightAnchor.constraint(equalTo: view.widthAnchor)
    ])

  }

  func configureLabel(){
    view.addSubview(resultLabel)
    resultLabel.translatesAutoresizingMaskIntoConstraints = false

    resultLabel.font = UIFont.systemFont(ofSize: 18)
    resultLabel.text = "Waiting for image"

    NSLayoutConstraint.activate([
      resultLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 20),
      resultLabel.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
      resultLabel.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
      resultLabel.heightAnchor.constraint(equalToConstant: 40)
    ])
  }

  func configureCheckButton(){
    view.addSubview(checkButton)
    checkButton.translatesAutoresizingMaskIntoConstraints = false

    checkButton.setTitle("Check Image", for: .normal)
    checkButton.backgroundColor = .systemBlue



    NSLayoutConstraint.activate([
      checkButton.topAnchor.constraint(equalTo: resultLabel.bottomAnchor, constant: 20),
      checkButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
      checkButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),

    ])

    if let image = imageView.image {
      checkNudityIn(image: image)
    }

  }

  func configurePickButton(){
    view.addSubview(pickButton)
    pickButton.translatesAutoresizingMaskIntoConstraints = false

    pickButton.setTitle("Select Image", for: .normal)
    pickButton.backgroundColor = .systemGray

    NSLayoutConstraint.activate([
      pickButton.topAnchor.constraint(equalTo: checkButton.bottomAnchor, constant: 20),
      pickButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
      pickButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
    ])

    pickButton.addTarget(self, action: #selector(pickButtonDidTapped), for: .touchUpInside)
  }

  @objc func pickButtonDidTapped(_ sender: UIButton){
    // show an alert to select the desired source

    if UIImagePickerController.isSourceTypeAvailable(.camera){

      let alert = UIAlertController(title: "Select Source", message: "", preferredStyle: .alert)

      alert.addAction(UIAlertAction(title: "Camera", style: .default, handler: { _ in

        let vc = UIImagePickerController()
        vc.sourceType = .camera
        vc.allowsEditing = true
        vc.delegate = self
        self.present(vc, animated: true)

      }))

      alert.addAction(UIAlertAction(title: "Photos", style: .default, handler: { _ in
        self.presentPicker()
      }))

      alert.addAction(UIAlertAction(title: "Dismiss", style: .default, handler: { _ in
        alert.dismiss(animated: true)
      }))

      // then show the vc
      present(alert, animated: true)

    } else {
      // no alert directly access library

      presentPicker()

    }

  } // end pick button

  func presentPicker(){
    var config = PHPickerConfiguration()
    config.filter = .images

    let picker = PHPickerViewController(configuration: config)
    picker.delegate = self
    self.present(picker, animated: true)
  }

  // Photo Picked
  func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
    print("pick finished with result \(results.count)")
    picker.dismiss(animated: true)

    if results.count > 0 {
      guard let itemProvider = results.first?.itemProvider, itemProvider.canLoadObject(ofClass: UIImage.self)  else {return}

      itemProvider.loadObject(ofClass: UIImage.self) { image, error in

        if let image = image as? UIImage {
          DispatchQueue.main.async {
            self.imageView.image = image
            self.checkNudityIn(image: image)
          }
        }
      }
    }

  }// end photo picker

  // Camera
  func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {

    picker.dismiss(animated: true)

    guard let image = info[.editedImage] as? UIImage else {
      print("No image found")
      return
    }

    print("Image Picked from Camera")

    self.imageView.image = image
    checkNudityIn(image: image)
  }

  func checkNudityIn(image inputImage: UIImage){
    NSFWDetector.shared.check(image: inputImage, completion: { result in
      switch result {
        case let .success(nsfwConfidence: confidence):
          let confidencePercent = confidence * 100
          self.resultLabel.text = "Image Nudity: \(String(format: "%.2f", confidencePercent))%"
        default:
          break
      }
    })
  }
}

