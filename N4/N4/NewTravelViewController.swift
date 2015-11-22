//
//  NewTravelViewController.swift
//  N4
//
//  Created by Teclógica Serviços em Informática LTDA on 18/11/15.
//  Copyright © 2015 FURB. All rights reserved.
//

import UIKit

class NewTravelViewController: UIViewController {

    @IBOutlet weak var travelName: UITextField!
    @IBOutlet weak var secure: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
}
