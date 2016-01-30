//
//  SearchViewController.swift
//  vlogger
//
//  Created by Eric Smith on 1/24/16.
//  Copyright © 2016 smith1302. All rights reserved.
//

import UIKit
import ParseUI

class SearchViewController: CustomPFQueryTableViewController {

    var searchTerm:String = ""
    weak var delegate:TransitionToFeedDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func doSearch(searchTerm:String?) {
        if let text = searchTerm {
            self.searchTerm = text
        } else {
            self.searchTerm = ""
        }
        loadObjects()
    }

}
