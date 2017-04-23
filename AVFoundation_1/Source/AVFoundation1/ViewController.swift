//
//  ViewController.swift
//  AVFoundation1
//
//  Created by NAVER on 2017. 4. 23..
//  Copyright © 2017년 NAVER. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        let speechController = SpeachController.speechController
        speechController.beginConversation()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

