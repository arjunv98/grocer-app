//
//  StoreDetailViewController.swift
//  Grocer
//
//  Created by Arjun Viswanathan on 5/4/20.
//  Copyright © 2020 Arjun Viswanathan. All rights reserved.
//

import UIKit
import RealmSwift

class StoreDetailViewController: UIViewController {
    /*
     * IB Outlets
     */
    @IBOutlet weak var storeName: UILabel!
    @IBOutlet weak var storeAddress: UILabel!
    @IBOutlet weak var distanceLabel: UILabel!
    @IBOutlet weak var saveButton: UIButton!
    
    /*
     * Variables
     */
    var selectedAnnotation: StoreAnnotation!
    let configuration = Realm.Configuration(deleteRealmIfMigrationNeeded: true)
    let saveImage = UIImage(systemName: "star")
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("DETAIL VIEW DID LOAD")
        storeName.text = selectedAnnotation.store?.name
        storeAddress.text = selectedAnnotation.store?.location?.address
        distanceLabel.text = "\(selectedAnnotation.distance) kilometers away"
        saveButton.isSelected = selectedAnnotation.isSaved
    }
    
    @IBAction func didTapButton(_ sender: Any) {
        saveButton.isSelected = !saveButton.isSelected
        selectedAnnotation.isSaved = saveButton.isSelected
        let realm = try! Realm(configuration: configuration)
        try! realm.write {
            selectedAnnotation.store?.isSaved = saveButton.isSelected
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

}
