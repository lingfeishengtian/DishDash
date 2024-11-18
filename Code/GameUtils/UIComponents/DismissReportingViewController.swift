//
//  DismissReportingViewController.swift
//  DishDash
//
//  Created by Hunter Han on 11/17/24.
//

import Foundation
import UIKit
import SwiftUI

class DismissReportingViewController<T : View>: UIHostingController<T> {
    var onDismiss: (() -> Void)?
    var onAppear: (() -> Void)?
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        if isBeingDismissed {
            onDismiss?()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if isBeingPresented {
            onAppear?()
        }
    }
}

