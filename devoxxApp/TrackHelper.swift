//
//  TrackHelper.swift
//  devoxxApp
//
//  Created by got2bex on 2015-12-20.
//  Copyright © 2015 maximedavid. All rights reserved.
//

import Foundation

class TrackHelper: NSObject {
    
    let title: String
    let id: String
    let trackDescription: String
    
    override var description: String {
        return "title: \(title)\n id: \(id)\n trackDescription: \(trackDescription)\n"
    }
    
    init(title: String?, id: String?, trackDescription: String?) {
        self.title = title ?? ""
        self.id = id ?? ""
        self.trackDescription = trackDescription ?? ""
    }
    
    class func feed(data: JSON) -> TrackHelper {
        
        let title: String? = data["title"].string
        let id: String? = data["id"].string
        let trackDescription: String? = data["trackDescription"].string
        
        return TrackHelper(title: title, id: id, trackDescription: trackDescription)
    }
    
}