//
//  Item.swift
//  TestProject
//
//  Created by Dmitry Vorozhbicki on 07/11/2019.
//  Copyright © 2019 Dmitry Vorozhbicki. All rights reserved.
//

import Foundation
import ObjectMapper

struct Items: Mappable {
    var all: [Item] = []

    init?(map: Map) {

    }
    // Mappable
    mutating func mapping(map: Map) {
        all <- map["items"]
    }
}

struct Item: Mappable {
    var title: String? = nil
    var description : String? = nil
    var urlImage: String? = nil

    init?(map: Map) {

    }
    mutating func mapping(map: Map) {
        title <- map["snippet.title"]
        description <- map["snippet.description"]
        urlImage <- map["snippet.thumbnails.default.url"]
    }
}
