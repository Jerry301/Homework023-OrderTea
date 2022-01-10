//
//  ViewController.swift
//  Homework023
//
//  Created by Chun-Yi Lin on 2021/12/25.
//

import UIKit

public let apiKey = "keytdvR37JsFsv9cD" 

class MainViewController: UIViewController {
    
    
    @IBOutlet weak var brandImageView: UIImageView!
    @IBOutlet var categoryButton: [UIButton]!
    @IBOutlet weak var categoryScrollView: UIScrollView!
    @IBOutlet weak var menuScrollView: UIScrollView!
    
    var orderList = Array<OrderRecord>()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        putInCategoryItems ()
        
        categoryButton.forEach { UIButton in
            UIButton.setTitleColor(.gray, for: .normal)
        }
        categoryButton[0].setTitleColor(.red, for: .normal)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        
        fetchOrder()
        
    }
    
    func putInCategoryItems (){
        let category = CategoryList.allCases
        
        for i in 0...category.count-1 {
            categoryButton[i].setTitle("\(category[i].rawValue)", for: .normal)
        }
        
    }
    
    func fetchOrder() {
        var url = MenuController.shared.airtableURL.appendingPathComponent("order")
        url = URL(string:"\(url)?sort[][field]=time")!

        MenuController.shared.fetchOrderRecords(orderURL: url) { (result) in
            switch result {
            case .success(let orderLists):
                self.updateUI(with: orderLists)
            case .failure(let error):
                self.displayError(error, title: "Failed to Fetch Order")
            }
        }
    }
    
    func updateUI(with orderList: Array<OrderRecord>) {
        DispatchQueue.main.async {
            self.orderList = orderList
            if let items = self.tabBarController?.tabBar.items as NSArray? {
                let tabItem = items.object(at: 1) as! UITabBarItem
                tabItem.badgeValue = "\(orderList.count)"
            }
        }
    }
    
    func displayError(_ error: Error, title: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func changeCategoryBtns(_ sender: UIButton) {
        let width = menuScrollView.bounds.width
        let x = CGFloat(sender.tag) * width
        let offset = CGPoint(x: x, y: 0)
        menuScrollView.setContentOffset(offset, animated: true)
        
        //設定分類按鈕是灰體字
        categoryButton.forEach { sender in
            sender.setTitleColor(.gray, for: .normal)
        }
        //點選分類按鈕變紅字
        let currentIndex = Int(offset.x/width)
        if currentIndex == sender.tag {
            categoryButton[sender.tag].setTitleColor(.red, for: .normal)

        }
        
    }

}

