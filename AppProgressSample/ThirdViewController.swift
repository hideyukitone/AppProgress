//
//  ThirdViewController.swift
//
//  Created by hideyuki okuni on 2016/11/04.
//  Copyright © 2016年 hideyuki. All rights reserved.
//

import UIKit
import AppProgress

class ThirdViewController: UIViewController {

    @IBOutlet weak var txtFree: UITextView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func pressCustom1(_ sender: UIButton) {
        AppProgress.custom(image: UIImage(named: "basketball1"), imageRenderingMode: .alwaysOriginal, string: txtFree.text ?? "", isRotation: false)
    }
    
    @IBAction func pressCustom2(_ sender: UIButton) {
        AppProgress.custom(image: UIImage(named: "basketball1"), imageRenderingMode: .alwaysOriginal, string: txtFree.text ?? "", isRotation: true)
    }
    
    @IBAction func pressShow(_ sender: UIButton) {
        AppProgress.show(string: txtFree.text ?? "")
    }
    
    @IBAction func pressInfo(_ sender: UIButton) {
        AppProgress.info(string: txtFree.text ?? "")
    }
    
    @IBAction func pressDone(_ sender: UIButton) {
        AppProgress.done(string: txtFree.text ?? "")
    }
    
    @IBAction func pressErr(_ sender: UIButton) {
        AppProgress.err(string: txtFree.text ?? "")
    }
    
    @IBAction func pressDismiss(_ sender: UIButton) {
        AppProgress.dismiss()
    }

}
