//
//  OrderViewController.swift
//  Homework023
//
//  Created by Chun-Yi Lin on 2021/12/28.
//

import UIKit

class OrderViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var orderTableView: UITableView!
    @IBOutlet weak var drinkImageView: UIImageView!
    @IBOutlet weak var drinkNameLabel: UILabel!
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var addToCartButton: UIButton!
    @IBOutlet weak var drinkStatusLabel: UILabel!
        
    
    let menuItem : Array<MenuRecord>
    let indexPath: Int
    let largePrice : Int
    let midPrice : Int
    let drinkName : String
    let category : String
//    let reminder : String
    var imageUrl : String
    
    init?(coder: NSCoder, menuItem: Array<MenuRecord>, indexPath: Int){
        self.menuItem = menuItem
        self.indexPath = indexPath
        self.largePrice = menuItem[indexPath].fields.largePrice ?? 0
        self.midPrice = menuItem[indexPath].fields.midPrice ?? 0
        self.drinkName = menuItem[indexPath].fields.name
        self.category = menuItem[indexPath].fields.category
//        self.reminder = menuItem[indexPath].fields.reminder ?? ""
        self.imageUrl = menuItem[indexPath].fields.image.first?.url ?? ""
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var orderID: String?
    var newOrderer: String?
    var capacity: String?
    var temp: String?
    var sugar: String?
    var topping: String?
    var time: String?
    
    var countNum = 1
    var orderPrice: Int?
    var drinkPrice = 0
    var toppingPrice = 0
    var toppingChecked = Array(repeating: false, count: Topping.allCases.count)
    var toppingArr = Array(repeating: "", count: Topping.allCases.count)
    var toppingArrString = String(repeating: "false", count: Topping.allCases.count)
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        orderTableView.delegate = self
        orderTableView.dataSource = self
        orderTableView.allowsSelection = true
        orderTableView.allowsMultipleSelection = false
        toppingArrString.remove(at: toppingArrString.index(before: toppingArrString.endIndex))
        
        drinkNameLabel.text = menuItem[indexPath].fields.name
        drinkPrice = menuItem[indexPath].fields.largePrice!
        quantityLabel.text = "\(countNum)"
        capacity = Capacity.largeLevel.rawValue
        sugar = "\(Sugar.normal.rawValue)甜"
        temp = Temp.iceNormal.rawValue
        topping = ""
        
        fetchImage()
        createdTimeFormatter()
        updateSubtotal()
        
    }
    
    func createdTimeFormatter () {
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        time = formatter.string(from: now)
        print("Created Time: \(time!)")
    }
    
    func updateDrinkStatus () {
        if topping == "" {
            drinkStatusLabel.text = "\(capacity!), \(sugar!), \(temp!)"
        } else {
            drinkStatusLabel.text = "\(capacity!), \(sugar!), \(temp!), \(topping!)"
        }
    }
    
    func updateSubtotal () {
        orderPrice = drinkPrice + toppingPrice
        subtotalLabel.text = "$ \(orderPrice! * countNum)"
    }
    
    func fetchImage (){
        MenuController.shared.fetchImage(urlString: imageUrl) { result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self.drinkImageView.image = image
                    //                    self.loading.stopAnimating()
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
    }
    
    func textFieldShouldReturn (_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        newOrderer = textField.text
        return true
    }
    
    
    @IBAction func plusButtonClicked(_ sender: UIButton) {
        if countNum < 99 {
            countNum += 1
            quantityLabel.text = "\(countNum)"
            
            updateSubtotal()
        }
    }
    @IBAction func minusButtonClicked(_ sender: UIButton) {
        if countNum > 1 {
            countNum -= 1
        } else {
            countNum = 1
        }
        quantityLabel.text = "\(countNum)"
        updateSubtotal()
    }
    
    @IBAction func addToCartButtonClicked(_ sender: UIButton) {
        
        let orderField = OrderFields(orderer: newOrderer ?? "", imageUrl: imageUrl, drinkName: drinkName, capacity: capacity ?? "", sugar: sugar ?? "", temp: temp ?? "", topping: topping ?? "", quantity: countNum, subtotal: orderPrice!*countNum, time: time ?? "", largePrice: largePrice, midPrice: midPrice, category: category, toppingsArrString: toppingArrString)
        
        let orderRecord = OrderRecord(id: nil, fields: orderField, createdTime: nil)
        
        let order = Order(records: [orderRecord])
                
        if orderField.orderer == "" {
            self.showAlert(title: "錯誤", message: "請填寫您的大名")
        } else {
            MenuController.shared.postOrder(orderData: order) { result in
                switch result {
                case .success(let content):
                    print("postOrder success:\(content)")
                    
                    DispatchQueue.main.async {
                        self.showAlert(title: "感謝您！", message: "訂購成功！")
                    }
                case .failure(let error):
                    print("postOrder success:\(error)")
                    
                    DispatchQueue.main.async {
                        self.showAlert(title: "不好意思！", message: "訂單上傳失敗！")
                    }
                }
            }
        }
    }
    
    func showAlert(title: String, message: String){
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { (action) -> Void in
            self.dismiss(animated: true, completion: nil)
        }))
        
        self.present(alert, animated: true, completion: nil)
    }
    
}

extension OrderViewController: UITableViewDataSource, UITableViewDelegate {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let orderInfoType = OrderInfo.allCases[section]
        switch orderInfoType {
        case .orderer, .capacity, .sugar, .temp:
            return 1
        case .topping:
            return Topping.allCases.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let orderTypeInfo = OrderInfo.allCases[indexPath.section]
        
        switch orderTypeInfo {
        case .orderer:
            guard let cell = orderTableView.dequeueReusableCell(withIdentifier: "\(OrdererTableViewCell.self)") as? OrdererTableViewCell else { return UITableViewCell() }
            cell.ordererTextField.delegate = self
            cell.ordererTextField.placeholder = "請輸入您的大名"
            guard let orderName = newOrderer
            else {return cell}
            cell.ordererTextField.text = orderName
            print("訂購人：\(newOrderer!)")
            return cell
            
        case .capacity:
            guard let cell = orderTableView.dequeueReusableCell(withIdentifier: "\(CapacityTableViewCell.self)", for: indexPath) as? CapacityTableViewCell
            else {return UITableViewCell()}
            
            cell.delegate = self
            cell.capacitySegmentedControl.selectedSegmentTintColor = .green
            if largePrice == 0 {
                cell.capacitySegmentedControl.removeSegment(at: 1, animated: false)
                cell.capacitySegmentedControl.setTitle("\(Capacity.middleLevel.rawValue)", forSegmentAt: 0)
                self.capacity = cell.capacitySegmentedControl.titleForSegment(at: cell.capacitySegmentedControl.selectedSegmentIndex)
            }else{
                cell.capacitySegmentedControl.setTitle("\(Capacity.middleLevel.rawValue)", forSegmentAt: 0)
                cell.capacitySegmentedControl.setTitle("\(Capacity.largeLevel.rawValue)", forSegmentAt: 1)
                self.capacity = cell.capacitySegmentedControl.titleForSegment(at: cell.capacitySegmentedControl.selectedSegmentIndex)
            }
            return cell
            
        case .sugar:
            guard let cell = orderTableView.dequeueReusableCell(withIdentifier: "\(SugarTableViewCell.self)", for: indexPath) as? SugarTableViewCell
            else {return UITableViewCell()}
            cell.delegate = self
            cell.sugarSegmentedControl.selectedSegmentTintColor = .green
            
            cell.sugarSegmentedControl.setTitle("\(Sugar.normal.rawValue)", forSegmentAt: 0)
            cell.sugarSegmentedControl.setTitle("\(Sugar.less.rawValue)", forSegmentAt: 1)
            cell.sugarSegmentedControl.setTitle("\(Sugar.half.rawValue)", forSegmentAt: 2)
            cell.sugarSegmentedControl.setTitle("\(Sugar.light.rawValue)", forSegmentAt: 3)
            cell.sugarSegmentedControl.setTitle("\(Sugar.rare.rawValue)", forSegmentAt: 4)
            cell.sugarSegmentedControl.setTitle("\(Sugar.none.rawValue)", forSegmentAt: 5)
            
            updateDrinkStatus()
            return cell
            
        case .temp:
            guard let cell = orderTableView.dequeueReusableCell(withIdentifier: "\(TempTableViewCell.self)", for: indexPath) as? TempTableViewCell
            else {return UITableViewCell()}
            
            cell.delegate = self
            cell.tempSegmentedControl.selectedSegmentTintColor = .green
            
            cell.tempSegmentedControl.setTitle("\(Temp.iceNormal.rawValue)", forSegmentAt: 0)
            cell.tempSegmentedControl.setTitle("\(Temp.iceLess.rawValue)", forSegmentAt: 1)
            cell.tempSegmentedControl.setTitle("\(Temp.iceLight.rawValue)", forSegmentAt: 2)
            cell.tempSegmentedControl.setTitle("\(Temp.iceFree.rawValue)", forSegmentAt: 3)
            cell.tempSegmentedControl.setTitle("\(Temp.warm.rawValue)", forSegmentAt: 4)
            cell.tempSegmentedControl.setTitle("\(Temp.hot.rawValue)", forSegmentAt: 5)
            
//            updateDrinkStatus()
            return cell
            
        case .topping:
            guard let cell = orderTableView.dequeueReusableCell(withIdentifier: "\(ToppingsTableViewCell.self)", for: indexPath) as? ToppingsTableViewCell
            else {return UITableViewCell()}
            
            cell.toppingNameLabel.text = Topping.allCases[indexPath.row].rawValue
            cell.toppingPriceLabel.text = "\(ToppingPrice.allCases[indexPath.row].price)"
            cell.addToppingBtn.frame.size.height = 15
            
            if toppingChecked[indexPath.row]{
                cell.addToppingBtn.setImage(UIImage(named: "circleCheckMark"), for: .normal)
                cell.backgroundColor = .green
            } else {
                cell.addToppingBtn.setImage(UIImage(named: "circle"), for: .normal)
                cell.backgroundColor = .none
            }
            
            return cell
        }
        

    }
    
    
    func numberOfSections(in tableView: UITableView) -> Int {
        OrderInfo.allCases.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let orderInfoType = OrderInfo.allCases[section]
        switch orderInfoType {
        case .orderer:
            return "訂購人"
        case .capacity:
            return "容量"
        case .sugar:
            return "甜度"
        case .temp:
            return "溫度"
        case .topping:
            return "外加好料"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
    
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let orderInfoType = OrderInfo.allCases[indexPath.section]
        
        switch orderInfoType {
        
        case .orderer:
            return
        case .capacity:
            return
        case .sugar:
            return
        case .temp:
            return
        case .topping:
            toppingChecked[indexPath.row] = !toppingChecked[indexPath.row]
            
            if toppingChecked[indexPath.row]{
                toppingPrice += ToppingPrice.allCases[indexPath.row].price
                toppingArr[indexPath.row] = Topping.allCases[indexPath.row].rawValue
                
                //轉成 String 以利上傳
                let toppingTrue = toppingArr.filter{$0 != ""}
                let stringToppingTrue = toppingTrue.joined(separator: ",")
                topping = stringToppingTrue
                //從 bool array 轉成 String Array
                let result = toppingChecked.map{$0 == true ? "true":"false"}
                //從 string array 轉成 bool array
                let resultString = result.filter{$0 != ""}
                //將結果承接起來
                toppingArrString = resultString.joined(separator: ",")
            } else {
                toppingPrice -= ToppingPrice.allCases[indexPath.row].price
                toppingArr[indexPath.row] = ""
                
                //轉成 String 以利上傳
                let toppingTrue = toppingArr.filter{$0 != ""}
                let stringToppingTrue = toppingTrue.joined(separator: ",")
                topping = stringToppingTrue
                //從 bool array 轉成 String Array
                let result = toppingChecked.map{$0 == true ? "true":"false"}
                //從 string array 轉成 bool array
                let resultString = result.filter{$0 != ""}
                //將結果承接起來
                toppingArrString = resultString.joined(separator: ",")
            }
            print("Topping: \(toppingArr)")
            updateDrinkStatus()
            updateSubtotal()
        }
        tableView.reloadData()
    }
}

extension OrderViewController: CapacityTableViewCellDelegate {
    func toggleCapacitySegmentedCtrl(with index: Int) {
        print("toggleCapacitySegmentedCtrl")
        switch index {
        case 0:
            drinkPrice = midPrice
            capacity = "\(Capacity.middleLevel.rawValue)"
        case 1:
            drinkPrice = largePrice
            capacity = "\(Capacity.largeLevel.rawValue)"
        default:
            break
        }
        updateDrinkStatus()
        updateSubtotal()
    }
}

extension OrderViewController: SugarTableViewCellDelegate {
    func toggleSugarSegmentedCtrl(with index: Int) {
        print("toggleSugarSegmentedCtrl")
        switch index {
        case 0:
            sugar = "\(Sugar.normal.rawValue)甜"
        case 1:
            sugar = "\(Sugar.less.rawValue)甜"
        case 2:
            sugar = Sugar.half.rawValue
        case 3:
            sugar = "\(Sugar.light.rawValue)甜"
        case 4:
            sugar = "\(Sugar.rare.rawValue)甜"
        case 5:
            sugar = Sugar.none.rawValue
        default:
            break
        }
        updateDrinkStatus()
    }
}

extension OrderViewController: TempTableViewCellDelegate {
    func toggleTempSegmentedCtrl(with index: Int) {
        print("toggleTempSegmentedCtrl")
        
        switch index {
        case 0:
            temp = Temp.iceNormal.rawValue
        case 1:
            temp = Temp.iceLess.rawValue
        case 2:
            temp = Temp.iceLight.rawValue
        case 3:
            temp = Temp.iceFree.rawValue
        case 4:
            temp = Temp.warm.rawValue
        case 5:
            temp = Temp.hot.rawValue
        default:
            break
        }
        updateDrinkStatus()
    }
}


