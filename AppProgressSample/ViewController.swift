//
//  ViewController.swift
//
//  Created by hideyuki okuni on 2016/11/04.
//  Copyright © 2016年 hideyuki. All rights reserved.
//

import UIKit
import AppProgress

final class ViewController: UIViewController {

    @IBOutlet weak var txtFree: UITextField!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBAction func changedColorType(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            AppProgress.set(colorType: .whiteAndBlack)
        case 1:
            AppProgress.set(colorType: .blackAndWhite)
        case 2:
            AppProgress.set(colorType: .grayAndWhite)
        default:
            break
        }
    }
    
    @IBAction func changedBackgroundStyle(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            AppProgress.set(backgroundStyle: .full)
        case 1:
            AppProgress.set(backgroundStyle: .none)
        default:
            break
        }
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
    
    @IBAction func pressTextFieldDone(_ sender: UITextField) {
    }

}

