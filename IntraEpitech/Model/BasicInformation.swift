//
//  BasicInformation.swift
//  IntraEpitech
//
//  Created by Maxime Junger on 23/01/2017.
//  Copyright © 2017 Maxime Junger. All rights reserved.
//

import Foundation
import SwiftyJSON

class BasicInformation {
 
    var scolaryear: String? = nil
    var codeModule: String? = nil
    var codeInstance: String? = nil
    
    init() { }
    
    init(dict: JSON) {
        scolaryear = dict["scolaryear"].stringValue
        codeModule = dict["codemodule"].stringValue
        codeInstance = dict["codeinstance"].stringValue
    }
    
}
