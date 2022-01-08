//
//  CountViewController.swift
//  Homework023
//
//  Created by Chun-Yi Lin on 2021/12/27.
//

import UIKit

class CountViewController: UIViewController {

    @IBOutlet weak var countTableView: UITableView!
    @IBOutlet weak var countLabel: UILabel!
    @IBOutlet weak var totalLabel: UILabel!
    
    var orderList = Array<OrderRecord>()
    var order : Order?
    var orderID = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        countTableView.dataSource = self
        countTableView.delegate = self

    }
    
    override func viewDidAppear(_ animated: Bool) {
        fetchOrder()
    }
   
    func fetchOrder() {
        var url = MenuController.shared.airtableURL.appendingPathComponent("order")
        url = URL(string: "\(url)?sort[][field]=time")!
        MenuController.shared.fetchOrderRecords(orderURL: url){(result) in
            switch result {
            case .success(let orderList):
                self.updateUI(with: orderList)
            case .failure(let error):
                self.displayError(error, title: "Failed to Fetch Order")
            }
        }
    }
    
    func initTabItem () {
        if let items = self.tabBarController?.tabBar.items as NSArray? {
            let tabItem = items.object(at: 1) as! UITabBarItem
            tabItem.badgeValue = "\(orderList.count)"
        }
    }
    
    func initTotal () {
        var count = 0
        self.orderList.forEach { orderList in
            count += orderList.fields.quantity
        }
        self.countLabel.text = "共\(count)杯"
        
        var total = 0
        self.orderList.forEach { orderList in
            total += orderList.fields.subtotal
        }
        self.totalLabel.text = "\(total)元"
    }
    
    func updateUI (with orderList: Array<OrderRecord>) {
        DispatchQueue.main.async {
            self.orderList = orderList
            self.initTabItem()
            self.initTotal()
            self.countTableView.reloadData()
        }
    }
    
    func displayError (_ error: Error, title: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBSegueAction func showEditOrder(_ coder: NSCoder) -> EditViewController? {
        guard let row = countTableView.indexPathsForSelectedRows?.first?.row else {return nil}
        let vc = EditViewController(coder: coder, orderList: orderList, orderID: orderID, indexPath: row)
        vc?.delegate = self
        return vc
    }
    
}

extension CountViewController: UITableViewDataSource, UITableViewDelegate {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        self.orderList.count
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        180
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "\(CountTableViewCell.self)", for: indexPath) as? CountTableViewCell
        else {return UITableViewCell()}
        
        let orderField = self.orderList[indexPath.row].fields
        cell.ordererNameLabel.text = orderField.orderer
        cell.drinkNameLabel.text = orderField.drinkName
        cell.capacityLabel.text = orderField.capacity
        cell.sugarLabel.text = orderField.sugar
        cell.tempLabel.text = orderField.temp
        cell.toppingLabel.text = "另加 ：\(orderField.topping ?? "無")"
        cell.quantityLabel.text = "\(orderField.quantity)杯"
        cell.subtotalLabel.text = "\(orderField.subtotal)元"
        
        let imageUrl = orderField.imageUrl
        MenuController.shared.fetchImage(urlString: imageUrl) { result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    cell.drinkImageView.image = image
                }
            case .failure(let networkError):
                switch networkError {
                case .invalidUrl:
                    print(networkError)
                case .requestFailed(let error):
                    print(networkError, error)
                case .invalidData:
                    print(networkError)
                case .invalidResponse:
                    print(networkError)
                }
            }
        }
        return cell
    }
    
    func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        true
    }
    
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            
            let order = self.orderList[indexPath.row]
            
            let alertController = UIAlertController(title: "\(order.fields.orderer):\(order.fields.drinkName)", message: "確定要刪除此訂單嗎？", preferredStyle: .alert)
            
            let okAction = UIAlertAction(title: "刪除", style: .default) { (_) in
//                self.loading.startAnimating()
                MenuController.shared.deleteOrder(orderID: order.id!) { result in
                    switch result {
                    case .success(let content):
                        print("DeleteOrder success:\(content)")
                        self.orderList.remove(at: indexPath.row)
                        DispatchQueue.main.async {
                            self.countTableView.deleteRows(at: [indexPath], with: .fade)
                            self.initTotal()
                            self.initTabItem()
                            self.countTableView.reloadData()
//                            self.loading.stopAnimating()
                        }
                        
                    case .failure(let error):
                        print("DeleteOrder failed:\(error)")
                    }
                }
            }
            
            let cancelAction = UIAlertAction(title: "保留", style: .default, handler: nil)
            alertController.addAction(okAction)
            alertController.addAction(cancelAction)
            present(alertController, animated: true, completion: nil)
        }
    }
}
