//
//  Enums.swift
//  Homework023
//
//  Created by Chun-Yi Lin on 2021/12/26.
//

import Foundation
import UIKit

enum CategoryList: String, CaseIterable {
    case original = "經典原茶"
    case fruit = "新鮮果茶"
    case milk = "香醇奶茶"
    case ice = "炙夏冰沙"
    case fresh = "純鮮奶茶"
}

enum OrderInfo: CaseIterable {
    case orderer
    case capacity
    case sugar
    case temp
    case topping
}

enum Capacity : String, CaseIterable {
    case middleLevel = "中杯"
    case largeLevel = "大杯"
}

enum Temp : String, CaseIterable {
    case iceNormal = "正常冰"
    case iceLess = "少冰"
    case iceLight = "微冰"
    case iceFree = "去冰"
    case warm = "溫"
    case hot = "熱"
}

enum Sugar : String, CaseIterable {
    case normal = "正常"
    case less = "8分"
    case half = "半糖"
    case light = "3分"
    case rare = "1分"
    case none = "無糖"
}

enum Topping : String, CaseIterable {
    case coconutJelly = "椰果"
    case garassJelly = "仙草凍"
    case boba = "波霸"
    case pearl = "珍珠"
    case mixed = "混珠"
    case doubleQ = "雙Q果"
    case honey = "蜂蜜"
    case yakult = "養樂多"
    case greenTeaJelly = "綠茶凍"
    case grapePearl = "葡萄波波"
    case cheeseCream = "芝芝"
    case creamBrulee = "布蕾"
    case iceCream = "冰淇淋"
}

enum ToppingPrice : Int, CaseIterable {
    case coconutJelly
    case garassJelly
    case boba
    case pearl
    case mixed
    case doubleQ
    case honey
    case yakult
    case greenTeaJelly
    case grapePearl
    case cheseCream
    case creamBrulee
    case iceCream
    var price: Int {
        switch self {
        case .coconutJelly:
            return 5
        case .garassJelly:
            return 5
        case .boba:
            return 10
        case .pearl:
            return 10
        case .mixed:
            return 10
        case .doubleQ:
            return 10
        case .honey:
            return 10
        case .yakult:
            return 10
        case .greenTeaJelly:
            return 10
        case .grapePearl:
            return 15
        case .cheseCream:
            return 20
        case .creamBrulee:
            return 20
        case .iceCream:
            return 20
        }
    }
}

enum NetworkError : Error {
    case invalidUrl
    case requestFailed(Error)
    case invalidData
    case invalidResponse
}

struct checkTopping {
    var title: String
    var isMarked: Bool
}
