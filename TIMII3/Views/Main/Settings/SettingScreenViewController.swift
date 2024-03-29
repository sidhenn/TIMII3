//
//  SettingScreen.swift
//  TIMII
//
//  Created by Dennis Huang on 8/5/18.
//  Copyright © 2018 Autonomii. All rights reserved.
//

/* TODO Section
 
 TODO: 8.5.18 - This file exist as the 'controller' (swift class) for our 'views' (XML) that can be referenced using the XML tag (ie; <SettingsScreen>)
 TODO: 8.21.18 - Login out and login back in drop user on to profile/Setting screen given the present call here. Remove the present LoginScreen from the HandleLogout func. This was tried but the present / dismiss / Layout with XML views seems to get in the way. I tried a few ways through main.swift to offload this into the LogInOutSystem.swift without too much luck. At least the Firebase calls from this class is no longer needed.
 TODO: 10.10.18 [DONE 10.10.18] - Migrated code from TIMII to TIMII3
 TODO: 10.21.18 [DONE 10.28.18] - Added Member info to be displayed on Profile screen
 TODO: 10.28.18 [DONE 10.28.18] - Refresh screen info on a login/logout action.
 TODO: 10.28.18 - Refactor fetchMemberEmail -> to Member.swift file
 
 */

import UIKit
import Layout
import Firebase

class SettingScreenViewController: UIViewController, Ownable
{
    var listener: ListenerRegistration!

    @IBOutlet var SettingScreenNode: LayoutNode? {
        didSet {
            // Set FS fields to "blank" so no errors show up waiting for data retrival
            SettingScreenNode?.setState([
                "email": "",
                "userName": "",
                "fullName": "",
                ])
        }
    }
    
    /*
     This viewWillAppear plus the addSnapshotListener seems to be updating the value
     for memberEmail values all the time! Can now delete the fetchMemberEmail function.
    */
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Adding a whole code block just to retrive member info...
        // FS Boilerplate to remove warning.
        let db = Firestore.firestore()
        let settings = db.settings
        settings.areTimestampsInSnapshotsEnabled = true
        db.settings = settings
        
        let memberRef = db.collection(FSCollectionName.Members.rawValue).document(memberID)
        listener = memberRef.addSnapshotListener { (document, error) in
            guard let doc = document, doc.exists else { return }
            if let err = error {
                print("Error getting document: \(err)")
            } else {
                let memberDoc = document?.data()
                let email           = memberDoc!["email"] as? String ?? ""
                let userName        = memberDoc!["userName"] as? String ?? ""
                let fullName        = memberDoc!["fullName"] as? String ?? ""
                
                // let memberID            = document?.documentID
                // let memberAuthMethod    = memberDoc!["authMethod"] as? String ?? ""
                
                self.SettingScreenNode?.setState([
                    "email": email as Any,
                    "userName": userName as Any,
                    "fullName": fullName as Any,
                    ])
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        listener.remove()   // removes listener to present memory hog, network access and also no need for weak reference in definition
    }
    
    @objc func settingHandleLogout()
    {
        print("Setting Screen logout...")
        let lo = Login()
        lo.handleLogout()
        
        print("Show Login screen from SettingScreen.")
        let login = LoginScreen()
        present(login, animated: true, completion: nil)
    }
}
