//
//  UpdateOrder.swift
//  Homework023
//
//  Created by Chun-Yi Lin on 2021/12/27.
//

import Foundation

struct UpdateOrderField: Codable {
    let orderer : String
    let capacity : String
    let sugar : String
    let temp : String
    let topping : String?
    let quantity : Int
    let subtotal : Int
    let toppingsArrString : String
    let time : String
}

struct UpdateOrderRecord : Codable {
    let id : String
    let fields: UpdateOrderField
}

struct UpdateOrder : Codable {
    let records : [UpdateOrderRecord]
}
