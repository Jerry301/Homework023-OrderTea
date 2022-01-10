//
//  MenuController.swift
//  Homework023
//
//  Created by Chun-Yi Lin on 2021/12/25.
//

import Foundation
import UIKit

class MenuController {
    static let shared = MenuController()
    let airtableURL = URL(string: "https://api.airtable.com/v0/appZqizadhqLhMfIo/")!
    
    func fetchMenuRecords(_ page: String, completion: @escaping (Result<Array<MenuRecord>,Error>) -> Void) {
        let menuURL = airtableURL.appendingPathComponent(page)
        guard let components = URLComponents(url: menuURL, resolvingAgainstBaseURL: true) else { return }
        guard let menuURL = components.url else { return }
        
        var request = URLRequest(url: menuURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request) {
            data, response, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let menu = try decoder.decode(Menu.self, from: data)
                    completion(.success(menu.records))
                } catch {
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func fetchImage(urlString: String, completion: @escaping (Result<UIImage, NetworkError>) -> Void) {
        guard let imageURL = URL(string: urlString) else {
            completion(.failure(.invalidUrl))
            return
        }
        URLSession.shared.dataTask(with: imageURL) { (data, response, error) in
            if let error = error {
                completion(.failure(.requestFailed(error)))
                return
            }
            guard let httpResponse = response as? HTTPURLResponse,httpResponse.statusCode == 200 else {
                completion(.failure(.invalidResponse))
                return
            }
            guard let data = data, let image = UIImage(data: data) else {
                completion(.failure(.invalidData))
                return
            }
            completion(.success(image))
        }.resume()
    }
    
    func fetchOrderRecords(orderURL: URL, completion: @escaping (Result<Array<OrderRecord>,Error>) -> Void) {
        var request = URLRequest(url: orderURL)
        request.httpMethod = "GET"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with: request) {
            data, response, error in
            if let data = data {
                do {
                    let decoder = JSONDecoder()
                    let orderResponse = try decoder.decode(Order.self, from: data)
                    
                    completion(.success(orderResponse.records))
                } catch {
                    completion(.failure(error))
                }
            } else if let error = error {
                completion(.failure(error))
            }
        }.resume()
    }
    
    func postOrder(orderData:Order, completion: @escaping (Result<String,Error>) -> Void) {
        let orderURL = airtableURL.appendingPathComponent("order")
        guard let components = URLComponents(url: orderURL, resolvingAgainstBaseURL: true) else { return }
        guard let orderURL = components.url else { return }
        
        var request = URLRequest(url: orderURL)
        request.httpMethod = "POST"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let encoder = JSONEncoder()
        request.httpBody = try? encoder.encode(orderData)

        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(orderData)
            URLSession.shared.dataTask(with: request) { data, response, resError in
                if let data = data,
                   let content = String(data: data, encoding: .utf8) {
                    completion(.success(content))
                } else if let resError = resError {
                    completion(.failure(resError))
                }
            }.resume()
        } catch {
            completion(.failure(error))
        }
    }
    
    func deleteOrder(orderID:String, completion: @escaping(Result<String,Error>) -> Void) {
        var orderURL = airtableURL.appendingPathComponent("order")
        orderURL = orderURL.appendingPathComponent(orderID)
        guard let components = URLComponents(url: orderURL, resolvingAgainstBaseURL: true) else { return }
        guard let orderURL = components.url else { return }
        
        var request = URLRequest(url: orderURL)
        request.httpMethod = "DELETE"
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        URLSession.shared.dataTask(with:request) { (data,response,resError) in
            if let response = response as? HTTPURLResponse,
               response.statusCode == 200,
               resError == nil,
               let data = data,
               let content = String(data:data,encoding: .utf8){
                completion(.success(content))
            }else if let resError = resError {
                completion(.failure(resError))
            }
        }.resume()

    }
    
    func updateOrder(orderData: UpdateOrder, completion: @escaping (Result<String, Error>) -> Void) {
        let orderURL = airtableURL.appendingPathComponent("order")
        guard let components = URLComponents(url: orderURL, resolvingAgainstBaseURL: true) else { return }
        guard let orderURL = components.url else { return }
        var request = URLRequest(url: orderURL)
        request.setValue("Bearer \(apiKey)", forHTTPHeaderField: "Authorization")
        request.httpMethod = "PATCH"
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        do {
            let encoder = JSONEncoder()
            request.httpBody = try encoder.encode(orderData)
            URLSession.shared.dataTask(with: request) { data, response, resError in
                if let data = data,
                   let content = String(data: data, encoding: .utf8) {
                    completion(.success(content))
                } else if let resError = resError {
                    completion(.failure(resError))
                }
            }.resume()
        } catch {
            completion(.failure(error))
        }
    }
    
    
    
}

public func priceIsZeroFormate(price: Int) -> String {
    if price == 0 {
        return "-"
    } else {
        return "\(price)"
    }
}
