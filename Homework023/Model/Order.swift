//
//  Order.swift
//  Homework023
//
//  Created by Chun-Yi Lin on 2021/12/27.
//

import Foundation

struct OrderFields: Codable {
    var orderer : String
    var imageUrl : String
    var drinkName : String
    var capacity : String
    var sugar : String
    var temp : String
    var topping : String?
    var quantity : Int
    var subtotal : Int
    var time : String
    let largePrice : Int
    let midPrice : Int
    let category : String
    var toppingsArrString : String
}

struct OrderRecord: Codable {
    var id : String?
    var fields: OrderFields
    var createdTime: String?
    init(id : String? = nil, fields: OrderFields, createdTime : String? = nil){
        self.id = id
        self.fields = fields
        self.createdTime = createdTime
    }
    
}

struct Order: Codable {
    let records : [OrderRecord]
    
}
