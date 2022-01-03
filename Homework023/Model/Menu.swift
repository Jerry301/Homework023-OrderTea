//
//  Menu.swift
//  Homework023
//
//  Created by Chun-Yi Lin on 2021/12/25.
//

import Foundation

struct MenuFields: Codable {
    let name : String
    let midPrice : Int?
    let largePrice : Int?
//    let reminder: String?
    let category : String
    let description : String
    let image : [MenuDrinkImage]
    struct MenuDrinkImage: Codable {
        let url : String
    }
}

struct MenuRecord : Codable {
    let id : String
    let fields : MenuFields
}

struct Menu: Decodable {
    let records : [MenuRecord]
}
