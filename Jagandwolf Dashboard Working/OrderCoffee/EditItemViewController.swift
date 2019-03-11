//
//  AppDelegate.swift
//  JagandwolfOrder
//
//  Created by Ricky Halley
//  Copyright © Jagandwolf All rights reserved.
//

import UIKit
import Firebase

class EditItemViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var itemImage: UIImageView!
    @IBOutlet weak var itemNameTextField: UITextField!
    @IBOutlet weak var categoryTextField: UITextField!
    @IBOutlet weak var hpriceTextField: UITextField!
    @IBOutlet weak var cpriceTextField: UITextField!
    @IBOutlet weak var fpriceTextField: UITextField!
    @IBOutlet weak var sweetButton: UIButton!
    @IBOutlet weak var creamButton: UIButton!
    @IBOutlet weak var syrupButton: UIButton!
    @IBOutlet weak var detailTextView: UITextView!
    
    //ประกาศตัวแปร
    var databaseRef: DatabaseReference!
    var userID = Auth.auth().currentUser?.uid
    var rootRef = Database.database().reference()
    var storageRef = Storage.storage().reference()
    var selectedImage: UIImage?
    var categoryPickerView = UIPickerView()
    var motion = String()
    var twist = String()
    var amount = String()
    var getName = String()
    var getCategory = String()
    var image: UIImage?
    var product:Product?
    
    //ประกาศค่าให้ตัวแปร
    let categories = ["Coffee", "Drink", "Fruit"]
    
    override func viewDidLoad() {
        super.viewDidLoad()

        //ส่วนตกแต่ง
        itemImage.layer.cornerRadius = itemImage.bounds.height / 2
        itemImage.clipsToBounds = true
        navigationItem.title = "Edit Item"
        
        itemNameTextField.delegate = self
        categoryTextField.delegate = self
        hpriceTextField.delegate = self
        cpriceTextField.delegate = self
        fpriceTextField.delegate = self
        
        categoryPickerView.delegate = self
        categoryPickerView.dataSource = self
        categoryTextField.inputView = categoryPickerView
        
        databaseRef = Database.database().reference()
        databaseRef.child("Product").child(userID!).child(getName).observeSingleEvent(of: .value, with: { (snapshot) in
            // Get user value
            let value = snapshot.value as? NSDictionary
            self.hpriceTextField.text = value?["ProductNeatPrice"] as? String ?? ""
            self.cpriceTextField.text = value?["ProductChilledPrice"] as? String ?? ""
            self.fpriceTextField.text = value?["ProductRocksPrice"] as? String ?? ""
            self.detailTextView.text = value?["ProductDetail"] as? String ?? ""
            let motionData = value?["OptionMotion"] as? String ?? ""
            let twistData = value?["OptionTwist"] as? String ?? ""
            let amountData = value?["OptionAmount"] as? String ?? ""
            
            if motionData == "open" {
                self.sweetButton.isSelected = true
                self.motion = "open"
            } else {
                self.sweetButton.isSelected = false
                self.motion = "close"
            }
            if twistData == "open" {
                self.creamButton.isSelected = true
                self.twist = "open"
            } else {
                self.creamButton.isSelected = false
                self.twist = "close"
            }
            if amountData == "open" {
                self.syrupButton.isSelected = true
                self.amount = "open"
            } else {
                self.syrupButton.isSelected = false
                self.amount = "close"
            }
            
            if(value?["ProductImg"] != nil)
            {
                let productImage = value?["ProductImg"] as? String ?? ""
                
                let url = URL(string: productImage)
                let data = try? Data(contentsOf: url!)
                self.itemImage.image = UIImage(data: data!)
            }
            
            // ...
        }) { (error) in
            print(error.localizedDescription)
        }
        
        self.itemNameTextField.text = getName
        self.categoryTextField.text = getCategory
    }
    
    //ตกแต่ง Status bar
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        let statusBar: UIView = UIApplication.shared.value(forKey: "statusBar") as! UIView
        if statusBar.responds(to: #selector(setter: UIView.backgroundColor)){
            statusBar.backgroundColor = UIColor(named: "Status")!
        }
    }
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return .lightContent
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func sweetBtn(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveLinear, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }) { (success) in
            sender.isSelected = !sender.isSelected
            UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveLinear, animations: {
                sender.transform = .identity
            }, completion: nil)
            if sender.isSelected {
                self.motion = "open"
            } else {
                self.motion = "close"
            }
        }
    }
    
    @IBAction func whipBtn(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveLinear, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }) { (success) in
            sender.isSelected = !sender.isSelected
            UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveLinear, animations: {
                sender.transform = .identity
            }, completion: nil)
            if sender.isSelected {
                self.twist = "open"
            } else {
                self.twist = "close"
            }
        }
    }
    
    @IBAction func syrupBtn(_ sender: UIButton) {
        UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveLinear, animations: {
            sender.transform = CGAffineTransform(scaleX: 0.1, y: 0.1)
        }) { (success) in
            sender.isSelected = !sender.isSelected
            UIView.animate(withDuration: 0.5, delay: 0.1, options: .curveLinear, animations: {
                sender.transform = .identity
            }, completion: nil)
            if sender.isSelected {
                self.amount = "open"
            } else {
                self.amount = "close"
            }
        }
    }
    
    @IBAction func saveItemBtn(_ sender: Any) {
        if itemNameTextField.text != getName {
            self.rootRef.child("Product").child(userID!).child(getName).removeValue()
            self.storageRef.child("Product").child(userID!).child(getName).delete { error in
                if let error = error {
                    print(error)
                } else {
                    // File deleted successfully
                }
            }
            
            //Add product เข้า firebase ใหม่
            if product == nil {
                product = Product()
            }
            
            product?.name = self.itemNameTextField.text
            product?.category = self.categoryTextField.text
            
            self.rootRef.child("Product").child(userID!).child(self.itemNameTextField.text!).child("ProductName").setValue(product!.name!)
            self.rootRef.child("Product").child(userID!).child(self.itemNameTextField.text!).child("ProductCategory").setValue(product!.category!)
            self.rootRef.child("Product").child(userID!).child(self.itemNameTextField.text!).child("ProductNeatPrice").setValue(self.hpriceTextField.text!)
            self.rootRef.child("Product").child(userID!).child(self.itemNameTextField.text!).child("ProductChilledPrice").setValue(self.cpriceTextField.text!)
            self.rootRef.child("Product").child(userID!).child(self.itemNameTextField.text!).child("ProductRocksPrice").setValue(self.fpriceTextField.text!)
            self.rootRef.child("Product").child(userID!).child(self.itemNameTextField.text!).child("OptionMotion").setValue(self.motion)
            self.rootRef.child("Product").child(userID!).child(self.itemNameTextField.text!).child("OptionTwist").setValue(self.twist)
            self.rootRef.child("Product").child(userID!).child(self.itemNameTextField.text!).child("OptionAmount").setValue(self.amount)
            self.rootRef.child("Product").child(userID!).child(self.itemNameTextField.text!).child("ProductDetail").setValue(self.detailTextView.text!)
            
            if selectedImage == nil {
                image = itemImage.image
            } else {
                image = selectedImage!
            }
            
            let imageRef = storageRef.child("Product").child(userID!).child(itemNameTextField.text!)
            if let itemPic = image, let imageData = UIImageJPEGRepresentation(itemPic, 0.1){
                imageRef.putData(imageData, metadata: nil, completion: {(metadata, error) in
                    if error != nil{
                        return
                    }
                    
                    let itemImageUrl = metadata?.downloadURL()?.absoluteString
                    self.rootRef.child("Product").child(self.userID!).child(self.itemNameTextField.text!).child("ProductImg").setValue(itemImageUrl)
                })
            }
            print("complete")
        } else {
            self.rootRef.child("Product").child(userID!).child(self.itemNameTextField.text!).child("ProductName").setValue(self.itemNameTextField.text!)
            self.rootRef.child("Product").child(userID!).child(self.itemNameTextField.text!).child("ProductCategory").setValue(self.categoryTextField.text!)
            self.rootRef.child("Product").child(userID!).child(self.itemNameTextField.text!).child("ProductHotPrice").setValue(self.hpriceTextField.text!)
            self.rootRef.child("Product").child(userID!).child(self.itemNameTextField.text!).child("ProductColdPrice").setValue(self.cpriceTextField.text!)
            self.rootRef.child("Product").child(userID!).child(self.itemNameTextField.text!).child("ProductFrappePrice").setValue(self.fpriceTextField.text!)
            self.rootRef.child("Product").child(userID!).child(self.itemNameTextField.text!).child("OptionMotion").setValue(self.motion)
            self.rootRef.child("Product").child(userID!).child(self.itemNameTextField.text!).child("OptionTwist").setValue(self.twist)
            self.rootRef.child("Product").child(userID!).child(self.itemNameTextField.text!).child("OptionAmount").setValue(self.amount)
            self.rootRef.child("Product").child(userID!).child(self.itemNameTextField.text!).child("ProductDetail").setValue(self.detailTextView.text!)
            
            let imageRef = storageRef.child("Product").child(userID!).child(self.itemNameTextField.text!)
            if let itemPic = self.selectedImage, let imageData = UIImageJPEGRepresentation(itemPic, 0.1){
                imageRef.putData(imageData, metadata: nil, completion: {(metadata, error) in
                    if error != nil{
                        return
                    }
                    
                    let itemImageUrl = metadata?.downloadURL()?.absoluteString
                    self.rootRef.child("Product").child(self.userID!).child(self.itemNameTextField.text!).child("ProductImg").setValue(itemImageUrl)
                })
            }
            print("editcomplete")
        }

        self.navigationController?.popViewController(animated: true)
    }
    
    @IBAction func deleteBtn(_ sender: Any) {
        self.rootRef.child("Product").child(userID!).child(getName).removeValue()
        self.performSegue(withIdentifier: "goToProduct", sender: self)
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return categories.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return categories[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        
        categoryTextField.text = categories[row]
        categoryTextField.resignFirstResponder()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        selectedImage = image
        itemImage.image = image
        itemImage.contentMode = .scaleAspectFill
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectPhoto(_ sender: UITapGestureRecognizer) {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = .photoLibrary
        present(controller, animated: true, completion: nil)
    }
    
}
