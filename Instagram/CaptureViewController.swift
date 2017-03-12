//
//  CaptureViewController.swift
//  Instagram
//
//  Created by Calvin Chu on 3/11/17.
//  Copyright © 2017 Calvin Chu. All rights reserved.
//

import UIKit
import Parse
import MBProgressHUD

class CaptureViewController: UIViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    @IBOutlet weak var selectPhotoButton: UIButton!
    @IBOutlet weak var captionTextField: UITextField!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        let selectPhotoGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(presentImagePicker(tapGestureRecognizer:)))
        selectPhotoButton.addGestureRecognizer(selectPhotoGestureRecognizer)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        // Get the image captured by the UIImagePickerController
        let originalImage = info[UIImagePickerControllerOriginalImage] as! UIImage
        
        // Do something with the images (based on your use case)
        selectPhotoButton.setImage(originalImage, for: .normal)
        
        // Dismiss UIImagePickerController to go back to your original view controller
        dismiss(animated: true, completion: nil)
    }
    
    func presentImagePicker(tapGestureRecognizer: UITapGestureRecognizer) {
        let vc = UIImagePickerController()
        vc.delegate = self
        vc.allowsEditing = true
        vc.sourceType = UIImagePickerControllerSourceType.photoLibrary
        self.present(vc, animated: true, completion: nil)
    }
    
    func resize(image: UIImage, newSize: CGSize) -> UIImage {
        let resizeImageView = UIImageView(frame: CGRect(x:0, y:0, width:newSize.width, height:newSize.height))
        resizeImageView.contentMode = UIViewContentMode.scaleAspectFill
        resizeImageView.image = image
        UIGraphicsBeginImageContext(resizeImageView.frame.size)
        print(resizeImageView.frame.size)
        resizeImageView.layer.render(in: UIGraphicsGetCurrentContext()!)
        let newImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        return newImage!
    }

    @IBAction func submit(_ sender: Any) {
        let oldImage = selectPhotoButton.image(for: .normal)
        let oldSize = oldImage?.size
        var data = UIImagePNGRepresentation(oldImage!)
        var image = oldImage
        if (data?.count)! >= 10000000 {
            var newSize = CGSize(width: (oldSize?.width)!/2, height: (oldSize?.height)!/2)
            image = resize(image: oldImage!, newSize: newSize)
            data = UIImagePNGRepresentation(image!)
            while (data?.count)! >= 10000000 {
                newSize = CGSize(width: newSize.width/2, height: newSize.height/2)
                image = resize(image: image!, newSize: newSize)
                data = UIImagePNGRepresentation(image!)
            }
        }
        MBProgressHUD.showAdded(to: self.view, animated: true)
        Post.postUserImage(image: image, withCaption: captionTextField.text) { (succeeded: Bool, error: Error?) in
            if succeeded {
                MBProgressHUD.hide(for: self.view, animated: true)
                self.tabBarController?.selectedIndex = 0
            } else {
                print(error?.localizedDescription as Any)
            }
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
