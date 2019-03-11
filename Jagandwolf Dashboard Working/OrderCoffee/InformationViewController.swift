//
//  AppDelegate.swift
//  JagandwolfOrder
//
//  Created by Ricky Halley
//  Copyright © Jagandwolf All rights reserved.
//

import UIKit
import Firebase

class Province {
    var province: String
    var district: [String]
    
    init(province:String, district:[String]){
        self.district = district
        self.province = province
    }
}

class InformationViewController: UIViewController, UITextFieldDelegate, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    @IBOutlet weak var shopNameTextField: UITextField!
    @IBOutlet weak var AddressTextField: UITextField!
    @IBOutlet weak var provinceTextField: UITextField!
    @IBOutlet weak var districtTextField: UITextField!
    @IBOutlet weak var zipCodeTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var profileImage: UIImageView!
    @IBOutlet weak var openTextField: UITextField!
    @IBOutlet weak var closeTextField: UITextField!
    @IBOutlet weak var nameLbl: UILabel!
    @IBOutlet weak var addressLbl: UILabel!
    @IBOutlet weak var phoneLbl: UILabel!
    @IBOutlet weak var timeLbl: UILabel!
    @IBOutlet weak var provinceLbl: UILabel!
    @IBOutlet weak var districtLbl: UILabel!
    @IBOutlet weak var codeLbl: UILabel!
    @IBOutlet weak var matchIcon: UIImageView!
    
    var userID = Auth.auth().currentUser?.uid
    var databaseRef: DatabaseReference!
    var rootRef = Database.database().reference()
    var storageRef = Storage.storage().reference()
    var provinces = [Province]()
    var selectedImage: UIImage?
    var array = [String]()
    var getMail = String()
    var getPass = String()
    var getId = String()
    var image: UIImage?
    var check = false
    
    var provincePickerView = UIPickerView()
    var districtPickerView = UIPickerView()
    
    let pickerOpen = UIDatePicker()
    let pickerClose = UIDatePicker()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        profileImage.layer.cornerRadius = profileImage.bounds.height / 2
        profileImage.clipsToBounds = true
        
        //แต่ง Label
        nameLbl.layer.borderWidth = 1.0
        nameLbl.layer.borderColor = UIColor.gray.cgColor
        phoneLbl.layer.borderWidth = 1.0
        phoneLbl.layer.borderColor = UIColor.gray.cgColor
        addressLbl.layer.borderWidth = 1.0
        addressLbl.layer.borderColor = UIColor.gray.cgColor
        timeLbl.layer.borderWidth = 1.0
        timeLbl.layer.borderColor = UIColor.gray.cgColor
        provinceLbl.layer.borderWidth = 1.0
        provinceLbl.layer.borderColor = UIColor.gray.cgColor
        districtLbl.layer.borderWidth = 1.0
        districtLbl.layer.borderColor = UIColor.gray.cgColor
        codeLbl.layer.borderWidth = 1.0
        codeLbl.layer.borderColor = UIColor.gray.cgColor
        
        matchIcon.isHidden = true
        
        shopNameTextField.delegate = self
        AddressTextField.delegate = self
        provinceTextField.delegate = self
        zipCodeTextField.delegate = self
        phoneNumberTextField.delegate = self
        
        createDatePicker()
        setUp()
        self.provinces.sort(by: {$0.province < $1.province})
        
        provincePickerView.delegate = self
        provincePickerView.dataSource = self
        provincePickerView.tag = 1
        
        districtPickerView.delegate = self
        districtPickerView.dataSource = self
        districtPickerView.tag = 2
        
        // toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button for toolbar
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(doneClick))
        toolbar.setItems([done], animated: false)
        
        provinceTextField.inputAccessoryView = toolbar
        districtTextField.inputAccessoryView = toolbar
        
        provinceTextField.inputView = provincePickerView
        districtTextField.inputView = districtPickerView
        
        //ดึงค่าชื่อร้าน เวลาเปิด-ปิด และที่อยู่จาก Firebase
        databaseRef = Database.database().reference().child("Shop")
        databaseRef.observe(DataEventType.value, with: {(DataSnapshot) in
            if DataSnapshot.childrenCount > 0 {
                for shops in DataSnapshot.children.allObjects as! [DataSnapshot]{
                    let shopObject = shops.value as? [String: AnyObject]
                    let shopName = shopObject?["ShopName"]
                    
                    self.array.append(shopName as! String)
                }
            }
        })
        
        shopNameTextField.addTarget(self, action: #selector(edited), for:.editingChanged)
        
    }
    
    @objc func edited() {
        if array.contains(shopNameTextField.text!) || shopNameTextField.text == "" {
            matchIcon.isHidden = false
            matchIcon.image = UIImage(named: "false")
            check = false
            print("Match")
        } else {
            matchIcon.isHidden = false
            matchIcon.image = UIImage(named: "true")
            check = true
            print("noMatch")
        }
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
    
    @IBAction func saveProfileBtn(_ sender: Any) {
        if check == true && shopNameTextField.text != "" {
            if phoneNumberTextField.text?.range(of: "^[0-9]{2,3}-?[0-9]{3}-?[0-9]{3,4}$", options: .regularExpression) != nil {
                if zipCodeTextField.text?.range(of: "^[0-9]{5}$", options: .regularExpression) != nil {
                    self.rootRef.child("Shop").child(userID!).child("ShopName").setValue(self.shopNameTextField.text!)
                    self.rootRef.child("Shop").child(userID!).child("Address").setValue(self.AddressTextField.text!)
                    self.rootRef.child("Shop").child(userID!).child("Province").setValue(self.provinceTextField.text!)
                    self.rootRef.child("Shop").child(userID!).child("District").setValue(self.districtTextField.text!)
                    self.rootRef.child("Shop").child(userID!).child("ZipCode").setValue(self.zipCodeTextField.text!)
                    self.rootRef.child("Shop").child(userID!).child("PhoneNumber").setValue(self.phoneNumberTextField.text!)
                    self.rootRef.child("Shop").child(userID!).child("OpenTime").setValue(self.openTextField.text!)
                    self.rootRef.child("Shop").child(userID!).child("CloseTime").setValue(self.closeTextField.text!)
                    
                    self.rootRef.child("Shop").child(userID!).child("Email").setValue(getMail)
                    self.rootRef.child("Shop").child(userID!).child("Password").setValue(getPass)
                    self.rootRef.child("Shop").child(userID!).child("ShopID").setValue(getId)
                    
                    if selectedImage == nil {
                        image = UIImage(named: "blankShop")!
                    } else {
                        image = selectedImage!
                    }
                    
                    let imageRef = storageRef.child("Shop").child(userID!).child("ShopImageLogo")
                    if let profilePic = image, let imageData = UIImageJPEGRepresentation(profilePic, 0.1){
                        imageRef.putData(imageData, metadata: nil, completion: {(metadata, error) in
                            if error != nil{
                                return
                            }
                            
                            let profileImageUrl = metadata?.downloadURL()?.absoluteString
                            self.rootRef.child("Shop").child(self.userID!).child("ShopImageLogo").setValue(profileImageUrl)
                        })
                    }
                    self.performSegue(withIdentifier: "goToOrder", sender: self)
                } else {
                    let errorAlert = UIAlertController(title: "Signup error", message: "Error information, Please check zip code again.", preferredStyle: .alert)
                    errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(errorAlert, animated: true, completion: nil)
                }
                
            } else {
                let errorAlert = UIAlertController(title: "Signup error", message: "Error information, Please check phone number again.", preferredStyle: .alert)
                errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                self.present(errorAlert, animated: true, completion: nil)
            }
            
        } else {
            let errorAlert = UIAlertController(title: "Signup error", message: "Error information, Please check the information again.", preferredStyle: .alert)
            errorAlert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
            self.present(errorAlert, animated: true, completion: nil)
        }
    }
    
    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        if pickerView.tag == 1 {
            return provinces.count
        }
        else {
            let selectedProvince = provincePickerView.selectedRow(inComponent: 0)
            return provinces[selectedProvince].district.count
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        if pickerView.tag == 1 {
            return provinces[row].province
        }
        else {
            let selectedProvince = provincePickerView.selectedRow(inComponent: 0)
            return provinces[selectedProvince].district[row]
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        pickerView.reloadAllComponents()
        
        let selectedProvince = provincePickerView.selectedRow(inComponent: 0)
        let selectedDistrict = districtPickerView.selectedRow(inComponent: 0)
        let province = provinces[selectedProvince].province
        let district = provinces[selectedProvince].district[selectedDistrict]
        
        provinceTextField.text = province
        districtTextField.text = district
        
    }
    
    @objc func doneClick() {
        provinceTextField.resignFirstResponder()
        districtTextField.resignFirstResponder()
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        let image = info[UIImagePickerControllerOriginalImage] as! UIImage
        selectedImage = image
        profileImage.image = image
        profileImage.contentMode = .scaleAspectFill
        
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func selectPhoto(_ sender: UITapGestureRecognizer) {
        let controller = UIImagePickerController()
        controller.delegate = self
        controller.sourceType = .photoLibrary
        present(controller, animated: true, completion: nil)
    }
    
    func createDatePicker() {
        
        // toolbar
        let toolbar = UIToolbar()
        toolbar.sizeToFit()
        
        // done button for toolbar
        let done = UIBarButtonItem(barButtonSystemItem: .done, target: nil, action: #selector(donePressed))
        toolbar.setItems([done], animated: false)
        
        closeTextField.inputAccessoryView = toolbar
        openTextField.inputAccessoryView = toolbar
        closeTextField.inputView = pickerClose
        openTextField.inputView = pickerOpen
        
        // format picker for date
        pickerOpen.datePickerMode = .time
        pickerClose.datePickerMode = .time
    }
    
    @objc func donePressed() {
        // format date
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        let timeOpenString = formatter.string(from: pickerOpen.date)
        let timeCloseString = formatter.string(from: pickerClose.date)
        
        openTextField.text = "\(timeOpenString)"
        closeTextField.text = "\(timeCloseString)"
        self.view.endEditing(true)
    }
    
    func setUp() {
        provinces.append(Province(province: "Texas", district: ["Houston", "San Antonio", "Austin", "Dallas", "College Station", "Pearland", "Woodlands", "Cypress", "Memorial City"]))
       
    }
    
}
