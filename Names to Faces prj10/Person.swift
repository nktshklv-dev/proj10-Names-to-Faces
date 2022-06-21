//
//  Person.swift
//  Names to Faces prj10
//
//  Created by Nikita  on 6/21/22.
//

import UIKit

class Person: NSObject {
    var name: String
    var image: String
    
    init(name: String, image: String){
        self.name = name
        self.image = image
    }
}
