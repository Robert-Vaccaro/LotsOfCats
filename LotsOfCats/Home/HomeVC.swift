//
//  ViewController.swift
//  LotsOfCats
//
//  Created by Bobby on 1/7/22.
//

import UIKit
import SDWebImage
import JGProgressHUD
import Photos

class HomeVC: UIViewController {
    @IBOutlet weak var catImgView: UIImageView!
    @IBOutlet weak var imageSettingsBtn: UIButton!
    @IBOutlet weak var shareBtn: UIButton!
    @IBOutlet weak var addTextOverlayBtn: UIButton!
    @IBOutlet weak var clearTextOverlayBtn: UIButton!
    
    let spinner = JGProgressHUD(style: .light)
    var aspectRatio:String = "Aspect Fit"
    var swipingStyle:String = "Swipe Left or Right"
    var searchURL:String = "https://cataas.com/cat"
    var panGesture = UIPanGestureRecognizer()
    var searchURLExists:Bool = false
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        updateCatImage()
    }
    
    func updateCatImage() {
        spinner.textLabel.text = "Loading A Cat"
        showLoaders()
        hideBtnOnLoad()
        catImgView.sd_setImage(with: URL(string: self.searchURL), placeholderImage: nil,options: .fromLoaderOnly, completed: { (image, error, cacheType, imageURL) in
            self.removeLoaders()
            self.showBtnAfterLoad()
        })
    }
    
    func showLoaders() {
        DispatchQueue.main.async {
            self.view.isUserInteractionEnabled = false
            self.spinner.show(in: self.catImgView)
            self.catImgView.addLoadingGradient()
        }
    }
    
    func removeLoaders() {
        DispatchQueue.main.async {
            self.view.isUserInteractionEnabled = true
            self.spinner.dismiss(animated: true)
            self.catImgView.removeLoadingGradient()
        }
    }
    
    func reloadPage(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let vc = storyboard.instantiateViewController(withIdentifier: "HomeVC") as UIViewController
        vc.modalPresentationStyle = .fullScreen
        vc.modalTransitionStyle = .crossDissolve
        self.present(vc, animated: true, completion: nil)
    }
    
    func writeToPhotoAlbum(image: UIImage) {
        UIImageWriteToSavedPhotosAlbum(image, self, #selector(saveCompleted), nil)
    }
    
    func openImageRatioAlert() {
        let imageRatioAlert = UIAlertController(title: "Image Settings", message: "This will change the aspect ratio of the cat image. Your current aspect ratio: \(self.aspectRatio)", preferredStyle: UIAlertController.Style.alert)
        
        imageRatioAlert.addAction(UIAlertAction(title: "Aspect Fit", style: UIAlertAction.Style.default, handler: {_ in
            UserDefaults.standard.setValue("Aspect Fit", forKey: "aspect-ratio")
            self.reloadPage()
        }))
        
        imageRatioAlert.addAction(UIAlertAction(title: "Aspect Fill", style: UIAlertAction.Style.default, handler: {_ in
            UserDefaults.standard.setValue("Aspect Fill", forKey: "aspect-ratio")
            self.reloadPage()
        }))
        
        imageRatioAlert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(imageRatioAlert, animated: true, completion: nil)
    }
    
    func openSwippingStyleAlert() {
        let swippingStyleAlert = UIAlertController(title: "Swipe Style Settings", message: "This will change your swiping style. Your current style: \(self.swipingStyle)", preferredStyle: UIAlertController.Style.alert)
        
        swippingStyleAlert.addAction(UIAlertAction(title: "Draggable", style: UIAlertAction.Style.default, handler: {_ in
            UserDefaults.standard.setValue("Draggable", forKey: "swiping-style")
            self.reloadPage()
        }))
        
        swippingStyleAlert.addAction(UIAlertAction(title: "Swipe Left or Right", style: UIAlertAction.Style.default, handler: {_ in
            UserDefaults.standard.setValue("Swipe Left or Right", forKey: "swiping-style")
            self.reloadPage()
        }))
        
        swippingStyleAlert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler: nil))
        self.present(swippingStyleAlert, animated: true, completion: nil)
    }
    
    func openTextOverlayAlert(){
        let textOverlayAlert = UIAlertController(title: "Add Text Overlay", message: "Enter in anything you want and it will appear on the image.", preferredStyle: .alert)
        
        textOverlayAlert.addTextField { (textOverlayTF) in
            textOverlayTF.placeholder = "Enter Anything You Want"
        }
        
        textOverlayAlert.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            let textOverlayTF = textOverlayAlert.textFields![0]
            let encodedString = textOverlayTF.text!.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
            self.searchURL = "https://cataas.com/cat/says/\(encodedString!)"
            UserDefaults.standard.setValue(encodedString!, forKey: "search-url")
            self.reloadPage()
        }))
        
        textOverlayAlert.addAction(UIAlertAction(title: "Close", style: .cancel, handler: nil))
        self.present(textOverlayAlert, animated: true, completion: nil)
    }
    
    func hideBtnOnLoad() {
        imageSettingsBtn.isHidden = true
        shareBtn.isHidden = true
        addTextOverlayBtn.isHidden = true
        if searchURLExists == true {
            clearTextOverlayBtn.isHidden = true
        }
    }
    
    func showBtnAfterLoad() {
        imageSettingsBtn.isHidden = false
        shareBtn.isHidden = false
        addTextOverlayBtn.isHidden = false
        if searchURLExists == true {
            clearTextOverlayBtn.isHidden = false
        }
    }
    
    @objc func draggedView(_ sender:UIPanGestureRecognizer){
        let translation = sender.translation(in: self.view)
        catImgView.center = CGPoint(x: catImgView.center.x + translation.x, y: catImgView.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self.view)
        if sender.state == .ended {
            updateCatImage()
        }
    }
    
    @objc func respondToSwipeGesture(gesture: UIGestureRecognizer) {
        if let swipeGesture = gesture as? UISwipeGestureRecognizer {
            switch swipeGesture.direction {
            case .right:
                print("Swiped right")
                updateCatImage()
            case .down:
                print("Swiped down")
            case .left:
                print("Swiped left")
                updateCatImage()
            case .up:
                print("Swiped up")
            default:
                break
            }
        }
    }
    
    @objc func saveCompleted(_ image: UIImage, didFinishSavingWithError error: Error?, contextInfo: UnsafeRawPointer) {
        if error != nil {
            let imageErrorAlert = UIAlertController(title: "Error", message: "An error occurred while saving the image. Please make sure the app has permission to save the image to your photo library.", preferredStyle: UIAlertController.Style.alert)
            imageErrorAlert.addAction(UIAlertAction(title: "Go to Settings", style: UIAlertAction.Style.default, handler: {_ in
                guard let settingsUrl = URL(string: UIApplication.openSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)")
                    })
                }
            }))
            
            imageErrorAlert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(imageErrorAlert, animated: true, completion: nil)
        } else {
            let imageSavedAlert = UIAlertController(title: "Image Saved", message: "", preferredStyle: UIAlertController.Style.alert)
            imageSavedAlert.addAction(UIAlertAction(title: "Close", style: UIAlertAction.Style.cancel, handler: nil))
            self.present(imageSavedAlert, animated: true, completion: nil)
        }
    }
    
    @IBAction func addTextOverlayBtnPress(_ sender: Any) {
        openTextOverlayAlert()
    }
    
    @IBAction func clearTextOverlayBtnPress(_ sender: Any) {
        self.searchURL = "https://cataas.com/cat"
        UserDefaults.standard.setValue(nil, forKey: "search-url")
        self.reloadPage()
    }
    
    @IBAction func shareBtnPress(_ sender: Any) {
        spinner.textLabel.text = ""
        spinner.show(in: self.catImgView)
        let image = self.catImgView.image
        let imageShareOptions = UIAlertController(title: "Image Options", message: "", preferredStyle: .actionSheet)
        
        imageShareOptions.addAction(UIAlertAction(title: "Share Image", style: .default , handler:{ _ in
            let imageToShare = [ image! ]
            let activityViewController = UIActivityViewController(activityItems: imageToShare, applicationActivities: nil)
            self.present(activityViewController, animated: true, completion: {
                self.spinner.dismiss(animated: true)
            })
        }))
        
        imageShareOptions.addAction(UIAlertAction(title: "Save Image", style: .default , handler:{ _ in
            self.writeToPhotoAlbum(image: image!)
        }))
        
        imageShareOptions.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(imageShareOptions, animated: true, completion: {
            self.spinner.dismiss(animated: true)
        })
    }
    
    @IBAction func imageSettingsBtnPress(_ sender: Any) {
        spinner.textLabel.text = ""
        spinner.show(in: self.catImgView)
        let imageSettingsOptions = UIAlertController(title: "Image Settings", message: "", preferredStyle: .actionSheet)
        
        imageSettingsOptions.addAction(UIAlertAction(title: "Change Image Aspect Ratio", style: .default , handler:{ _ in
            self.openImageRatioAlert()
        }))
        
        imageSettingsOptions.addAction(UIAlertAction(title: "Change Swipe Style", style: .default , handler:{ _ in
            self.openSwippingStyleAlert()
        }))
        
        imageSettingsOptions.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        self.present(imageSettingsOptions, animated: true, completion: {
            self.spinner.dismiss(animated: true)
        })
        
    }
    
    func setupUI() {
        let cachedAspectRatio = UserDefaults.standard.value(forKey: "aspect-ratio")
        if cachedAspectRatio != nil {
            self.aspectRatio = cachedAspectRatio as! String
        }
        
        let cachedSwippingStyle = UserDefaults.standard.value(forKey: "swiping-style")
        if cachedSwippingStyle != nil {
            self.swipingStyle = cachedSwippingStyle as! String
        }
        
        clearTextOverlayBtn.isHidden = true
        let cachedSearchURL = UserDefaults.standard.value(forKey: "search-url")
        if cachedSearchURL != nil {
            if cachedSearchURL as! String == "" {
                self.searchURL = "https://cataas.com/cat"
            } else {
                searchURLExists = true
                clearTextOverlayBtn.isHidden = false
                self.searchURL = "https://cataas.com/cat/says/\(cachedSearchURL ?? "")"
            }
        }
        
        if self.aspectRatio == "Aspect Fit"{
            self.catImgView.contentMode = .scaleAspectFit
        } else {
            self.catImgView.contentMode = .scaleAspectFill
        }
        // UI layering
        clearTextOverlayBtn.layer.zPosition = 11
        imageSettingsBtn.layer.zPosition = 11
        shareBtn.layer.zPosition = 11
        addTextOverlayBtn.layer.zPosition = 11
        spinner.layer.zPosition = 10
        catImgView.layer.zPosition = 11
        
        self.clearTextOverlayBtn.layer.cornerRadius = self.clearTextOverlayBtn.frame.size.height/2
        self.shareBtn.layer.cornerRadius = self.shareBtn.frame.size.height/2
        self.imageSettingsBtn.layer.cornerRadius = self.imageSettingsBtn.frame.size.height/2
        self.shareBtn.layer.cornerRadius = self.shareBtn.frame.size.height/2
        self.addTextOverlayBtn.layer.cornerRadius = self.addTextOverlayBtn.frame.size.height/2
        
        if self.swipingStyle == "Draggable"{
            panGesture = UIPanGestureRecognizer(target: self, action: #selector(draggedView))
            catImgView.isUserInteractionEnabled = true
            catImgView.addGestureRecognizer(panGesture)
        } else {
            let swipeLeft = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
            swipeLeft.direction = .left
            self.view.addGestureRecognizer(swipeLeft)
            
            let swipeRight = UISwipeGestureRecognizer(target: self, action: #selector(respondToSwipeGesture))
            swipeRight.direction = .right
            self.view.addGestureRecognizer(swipeRight)
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
}
