//
//  ResultTableViewController.swift
//  CameraFilterTest
//
//  Created by 이채원 on 2017. 6. 7..
//  Copyright © 2017년 이채원. All rights reserved.
//

import UIKit

class ResultTableViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet var tableView: UITableView!
    
    var dataModel: [String: Float]!
    var dataKeys: [String]!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.dataKeys = [String](dataModel.keys)
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "ResultTableViewCell", for: indexPath) as! ResultTableViewCell
        
        let data = dataModel[dataKeys[indexPath.row]]
        
        cell.nameLabel.text = dataKeys[indexPath.row]
        cell.valueLabel.text = String(data!)
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.dataKeys.count
    }
}

class ResultTableViewCell: UITableViewCell {
    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var valueLabel: UILabel!
    
}
