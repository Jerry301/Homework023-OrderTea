//
//  EditViewController.swift
//  Homework023
//
//  Created by Chun-Yi Lin on 2021/12/28.
//

import UIKit

class EditViewController: UIViewController, UITextFieldDelegate {
    
    @IBOutlet weak var editTableView: UITableView!
    @IBOutlet weak var drinkImageView: UIImageView!
    @IBOutlet weak var drinkNameLabel: UILabel!
    @IBOutlet weak var subtotalLabel: UILabel!
    @IBOutlet weak var minusButton: UIButton!
    @IBOutlet weak var plusButton: UIButton!
    @IBOutlet weak var quantityLabel: UILabel!
    @IBOutlet weak var drinkStatusLabel: UILabel!
    @IBOutlet weak var addToCartButton: UIButton!
    
    
    let orderList: Array<OrderRecord>
    let indexPath: Int
    var orderer: String
    var imageUrl: String
    var drinkName: String
    var capacity: String
    var temp: String
    var sugar: String
    var topping: String?
    var countNum: Int
    var subtotal: Int
    var time: String
    var midPrice: Int
    var largePrice: Int
    var category: String
    var toppingArrString: String
    var orderID: String
    var createdTime: String
    init?(coder: NSCoder, orderList: Array<OrderRecord>, orderID: String, indexPath: Int){
        self.orderList = orderList
        self.indexPath = indexPath
        self.orderer = orderList[indexPath].fields.orderer
        self.imageUrl = orderList[indexPath].fields.imageUrl
        self.drinkName = orderList[indexPath].fields.drinkName
        self.capacity = orderList[indexPath].fields.capacity
        self.sugar = orderList[indexPath].fields.sugar
        self.temp = orderList[indexPath].fields.temp
        self.topping = orderList[indexPath].fields.topping ?? ""
        self.countNum = orderList[indexPath].fields.quantity
        self.subtotal = orderList[indexPath].fields.subtotal
        self.time = orderList[indexPath].fields.time
        self.midPrice = orderList[indexPath].fields.midPrice
        self.largePrice = orderList[indexPath].fields.largePrice
        self.category = orderList[indexPath].fields.category
        self.toppingArrString = orderList[indexPath].fields.toppingsArrString
        self.orderID = orderList[indexPath].id ?? ""
        self.createdTime = orderList[indexPath].createdTime!
        
        super.init(coder: coder)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    var editTime: String?
    var newOrderPrice: Int?
    var drinkPrice = 0
    var toppingPrice = 0
    var toppingChecked = Array(repeating: false, count: Topping.allCases.count)
    var toppingArr = Array(repeating: "", count: Topping.allCases.count)
    var delegate: CountViewController?

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        editTableView.delegate = self
        editTableView.dataSource = self
        editTableView.allowsSelection = true
        editTableView.allowsMultipleSelection = false
        
        fetchImage()
        drinkNameLabel.text = "\(orderList[indexPath].fields.drinkName)"
        quantityLabel.text = "\(orderList[indexPath].fields.quantity)"
        
        if capacity == "??????" {
            drinkPrice = orderList[indexPath].fields.midPrice
        } else {
            drinkPrice = orderList[indexPath].fields.largePrice
        }
        
        toppingPrice = subtotal/countNum - drinkPrice
        
        initTopping()
        updateDrinkStatus()
        createdTimeFormatter()
        updateSubtotal()
    }
    
    func initTopping (){
        toppingArr = toppingArrString.components(separatedBy: ",")
        
        for i in 0...Topping.allCases.count-1 {
            if toppingArr[i] == "false" {
                toppingArr[i] = ""
            }
            if toppingArr[i] == "true" {
                toppingChecked[i] = true
                toppingArr[i] = Topping.allCases[i].rawValue
            }
        }
    }
    
    func createdTimeFormatter() {
        let now = Date()
        let formatter = DateFormatter()
        formatter.timeZone = TimeZone.current
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        editTime = formatter.string(from: now)
    }
    
    func updateDrinkStatus(){
        if topping == "" {
            drinkStatusLabel.text = "\(capacity), \(sugar), \(temp)"
        } else {
            drinkStatusLabel.text = "\(capacity), \(sugar), \(temp), \(topping!)"
        }
    }
    
    func updateSubtotal(){
        newOrderPrice = drinkPrice + toppingPrice
        subtotalLabel.text = "$ \(newOrderPrice! * countNum)"
    }
    
    func fetchImage (){
        MenuController.shared.fetchImage(urlString: imageUrl) { result in
            switch result{
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
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        self.view.endEditing(true)
        
        orderer = textField.text!
        return true
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "??????", style: .default, handler: { (_) in
            self.dismiss(animated: true) {
                self.delegate?.fetchOrder()
            }
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func minusBtn(_ sender: UIButton) {
        if countNum > 1 {
            countNum -= 1
        } else {
            countNum = 1
        }
        
        quantityLabel.text = "\(countNum)"
        updateSubtotal()
    }
    
    
    @IBAction func plusBtn(_ sender: UIButton) {
        if countNum < 100 {
            countNum += 1
            quantityLabel.text = "\(countNum)"
            updateSubtotal()
        }
    }
    
    
    @IBAction func addToCart(_ sender: UIButton) {
        
        let updateOrderField = UpdateOrderField(orderer: orderer, capacity: capacity, sugar: sugar, temp: temp, topping: topping ?? "", quantity: countNum, subtotal: newOrderPrice!*countNum, toppingsArrString: toppingArrString, time: editTime!)
        
        let updateOrderRecord = UpdateOrderRecord(id: orderID, fields: updateOrderField)
        
        let updateOrder = UpdateOrder(records: [updateOrderRecord])
        
        if updateOrderField.orderer == "" {
            self.showAlert(title: "??????", message: "?????????????????????")
        } else {
            MenuController.shared.updateOrder(orderData: updateOrder) { result in
                switch result {
                case .success(let content):
                    print("Update success:\(content)")
                    
                    if content.contains("records"){
                        print("Records are avaliable.")
                        
                        DispatchQueue.main.async {
                            self.showAlert(title: "?????????", message: "???????????????")
                        }
                    }else {
                        print("Records are not avaliable.")
                        DispatchQueue.main.async {
                            self.showAlert(title: "?????????", message: "?????????????????????")
                        }
                    }
                case .failure(let error):
                    print("Update failure: \(error)")
                    DispatchQueue.main.async {
                        self.showAlert(title: "?????????", message: "?????????????????????")
                    }
                }
            }
        }
    }
    
    
}

extension EditViewController: UITableViewDataSource, UITableViewDelegate{
    
    func numberOfSections(in tableView: UITableView) -> Int {
        OrderInfo.allCases.count
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let orderInfoType = OrderInfo.allCases[section]
        switch orderInfoType{
        case .orderer:
            return "?????????"
        case .capacity:
            return "??????"
        case .sugar:
            return "??????"
        case .temp:
            return "??????"
        case .topping:
            return "????????????"
        }
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        30
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        70
    }
    
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
        let orderInfoType = OrderInfo.allCases[indexPath.section]
        
        switch orderInfoType {
        case .orderer:
            guard let cell = editTableView.dequeueReusableCell(withIdentifier: "\(OrdererTableViewCell.self)") as? OrdererTableViewCell
            else {return UITableViewCell()}
            
            cell.ordererTextField.delegate = self
            cell.ordererTextField.text = orderer
            return cell
            
        case .capacity:
            guard let cell = editTableView.dequeueReusableCell(withIdentifier: "\(CapacityTableViewCell.self)", for: indexPath) as? CapacityTableViewCell
            else {return UITableViewCell()}
            
            cell.delegate = self
            cell.capacitySegmentedControl.selectedSegmentIndex = -1
            
            switch capacity {
            case "\(Capacity.middleLevel.rawValue)":
                cell.capacitySegmentedControl.selectedSegmentIndex = 0
            case "\(Capacity.largeLevel.rawValue)":
                cell.capacitySegmentedControl.selectedSegmentIndex = 1
            default:
                break
            }
            
            cell.capacitySegmentedControl.selectedSegmentTintColor = .green
            if largePrice == 0 {
                cell.capacitySegmentedControl.removeSegment(at: 1, animated: false)
                cell.capacitySegmentedControl.setTitle("\(Capacity.middleLevel.rawValue)", forSegmentAt: 0)
                self.capacity = cell.capacitySegmentedControl.titleForSegment(at: cell.capacitySegmentedControl.selectedSegmentIndex)!
            }else {
                cell.capacitySegmentedControl.setTitle("\(Capacity.middleLevel.rawValue)", forSegmentAt: 0)
                cell.capacitySegmentedControl.setTitle("\(Capacity.largeLevel.rawValue)", forSegmentAt: 1)
                self.capacity = cell.capacitySegmentedControl.titleForSegment(at: cell.capacitySegmentedControl.selectedSegmentIndex)!
            }
            return cell
            
        case .sugar:
            guard let cell = editTableView.dequeueReusableCell(withIdentifier: "\(SugarTableViewCell.self)", for: indexPath) as? SugarTableViewCell
            else {return UITableViewCell()}
            
            cell.delegate = self
            cell.sugarSegmentedControl.selectedSegmentIndex = -1
            
            switch sugar {
            case "\(Sugar.normal.rawValue)???":
                cell.sugarSegmentedControl.selectedSegmentIndex = 0
            case "\(Sugar.less.rawValue)???":
                cell.sugarSegmentedControl.selectedSegmentIndex = 1
            case "\(Sugar.half.rawValue)":
                cell.sugarSegmentedControl.selectedSegmentIndex = 2
            case "\(Sugar.light.rawValue)???":
                cell.sugarSegmentedControl.selectedSegmentIndex = 3
            case "\(Sugar.rare.rawValue)???":
                cell.sugarSegmentedControl.selectedSegmentIndex = 4
            case "\(Sugar.none.rawValue)":
                cell.sugarSegmentedControl.selectedSegmentIndex = 5
            default:
                break
            }
            
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
            guard let cell = editTableView.dequeueReusableCell(withIdentifier: "\(TempTableViewCell.self)", for: indexPath) as? TempTableViewCell
            else {return UITableViewCell()}
            
            cell.delegate = self
            
            cell.tempSegmentedControl.selectedSegmentIndex = -1
            
            switch temp {
            case "\(Temp.iceNormal.rawValue)":
                cell.tempSegmentedControl.selectedSegmentIndex = 0
            case "\(Temp.iceLess.rawValue)":
                cell.tempSegmentedControl.selectedSegmentIndex = 1
            case "\(Temp.iceLight.rawValue)":
                cell.tempSegmentedControl.selectedSegmentIndex = 2
            case "\(Temp.iceFree.rawValue)":
                cell.tempSegmentedControl.selectedSegmentIndex = 3
            case "\(Temp.warm.rawValue)":
                cell.tempSegmentedControl.selectedSegmentIndex = 4
            case "\(Temp.hot.rawValue)":
                cell.tempSegmentedControl.selectedSegmentIndex = 5
            default:
                break
            }
            
            cell.tempSegmentedControl.selectedSegmentTintColor = .green
            
            cell.tempSegmentedControl.setTitle("\(Temp.iceNormal.rawValue)", forSegmentAt: 0)
            cell.tempSegmentedControl.setTitle("\(Temp.iceLess.rawValue)", forSegmentAt: 1)
            cell.tempSegmentedControl.setTitle("\(Temp.iceLight.rawValue)", forSegmentAt: 2)
            cell.tempSegmentedControl.setTitle("\(Temp.iceFree.rawValue)", forSegmentAt: 3)
            cell.tempSegmentedControl.setTitle("\(Temp.warm.rawValue)", forSegmentAt: 4)
            cell.tempSegmentedControl.setTitle("\(Temp.hot.rawValue)", forSegmentAt: 5)
            
            updateDrinkStatus()
            return cell
            
        case .topping:
            guard let cell = editTableView.dequeueReusableCell(withIdentifier: "\(ToppingsTableViewCell.self)", for: indexPath) as? ToppingsTableViewCell
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
                                
                let toppingTrue = toppingArr.filter{ $0 != ""}
                let stringToppingTrue = toppingTrue.joined(separator: ",")
                
                topping = stringToppingTrue
                
                let result = toppingChecked.map{$0 == true ? "true":"false"}
                
                let resultString = result.filter{$0 != ""}
                toppingArrString = resultString.joined(separator: ",")
                
            } else {
                toppingPrice -= ToppingPrice.allCases[indexPath.row].price
                toppingArr[indexPath.row] = ""
                
                let toppingTrue = toppingArr.filter{ $0 != ""}
                let stringToppingTrue = toppingTrue.joined(separator: ",")
                
                topping = stringToppingTrue
                
                let result = toppingChecked.map{$0 == true ? "true":"false"}
                
                let resultString = result.filter{$0 != ""}
                toppingArrString = resultString.joined(separator: ",")
            }
            updateDrinkStatus()
            updateSubtotal()
        }
        tableView.reloadData()
    }
}

extension EditViewController: CapacityTableViewCellDelegate {
    func toggleCapacitySegmentedCtrl(with index: Int) {
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
        
        updateSubtotal()
        updateDrinkStatus()
    }
}

extension EditViewController: SugarTableViewCellDelegate {
    func toggleSugarSegmentedCtrl(with index: Int) {
        
        switch index {
        case 0:
            sugar = "\(Sugar.normal.rawValue)???"
        case 1:
            sugar = "\(Sugar.less.rawValue)???"
        case 2:
            sugar = "\(Sugar.half.rawValue)"
        case 3:
            sugar = "\(Sugar.light.rawValue)???"
        case 4:
            sugar = "\(Sugar.rare.rawValue)???"
        case 5:
            sugar = "\(Sugar.none.rawValue)"
        default:
            break
        }
        
        updateDrinkStatus()
    }
}

extension EditViewController: TempTableViewCellDelegate {
    func toggleTempSegmentedCtrl(with index: Int) {
        
        switch index {
        case 0:
            temp = "\(Temp.iceNormal.rawValue)"
        case 1:
            temp = "\(Temp.iceLess.rawValue)"
        case 2:
            temp = "\(Temp.iceLight.rawValue)"
        case 3:
            temp = "\(Temp.iceFree.rawValue)"
        case 4:
            temp = "\(Temp.warm.rawValue)"
        case 5:
            temp = "\(Temp.hot.rawValue)"
        default:
            break
        }
        updateDrinkStatus()
    }
}
