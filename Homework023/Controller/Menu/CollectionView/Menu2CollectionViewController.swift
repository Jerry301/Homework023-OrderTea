//
//  Menu1CollectionViewController.swift
//  Homework023
//
//  Created by Chun-Yi Lin on 2021/12/26.
//

import UIKit

private let reuseIdentifier = "Cell"

class Menu2CollectionViewController: UICollectionViewController {
    
    var menuRecords = Array<MenuRecord>()
    
    let page = "menu2"
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        MenuController.shared.fetchMenuRecords(page) { result in
            switch result {
            case .success(let menuRecord):
                self.updateUI(with: menuRecord)
            case .failure(let error):
                self.displayError(error, title: "Failed to Fetch Menu2 Items")
            }
        }
        
        configureCellSize()
    }
    
    func configureCellSize (){
        let flowLayout = collectionViewLayout as? UICollectionViewFlowLayout
        let width = UIScreen.main.bounds.width / 2.2
        flowLayout?.itemSize = CGSize(width: width, height: width*1.2)
        flowLayout?.estimatedItemSize = .zero
        flowLayout?.minimumLineSpacing = 1
        flowLayout?.minimumInteritemSpacing = 30
        flowLayout?.scrollDirection = UICollectionView.ScrollDirection.vertical
    }
    
    func updateUI (with drinkItem: [MenuRecord]) {
        DispatchQueue.main.async {
            self.menuRecords = drinkItem
            self.collectionView.reloadData()
        }
    }
    
    func displayError(_ error: Error, title: String) {
        DispatchQueue.main.async {
            let alert = UIAlertController(title: title, message: error.localizedDescription, preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "", style: .default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBSegueAction func showDrinkDetail(_ coder: NSCoder) -> OrderViewController? {
        guard let item = collectionView.indexPathsForSelectedItems?.first?.item
        else {return nil}
        return OrderViewController.init(coder: coder, menuItem: menuRecords, indexPath: item)
    }
    
    
    
    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        // #warning Incomplete implementation, return the number of sections
        return 1
    }
    
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of items
        return menuRecords.count
    }
    
    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
//        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath)
        
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as? Menu2CollectionViewCell else {return UICollectionViewCell()}
        let menuRecord = menuRecords[indexPath.item]
        cell.menu2DrinkNameLabel.text = menuRecord.fields.name
        cell.menu2DrinkMidPriceLabel.text = priceIsZeroFormate(price: menuRecord.fields.midPrice!)
        cell.menu2DrinkLargePriceLabel.text = priceIsZeroFormate(price: menuRecord.fields.largePrice!)
        
        let imageUrl = menuRecord.fields.image.first?.url
        MenuController.shared.fetchImage(urlString: imageUrl!) { result in
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    cell.menu2DrinkImageView.image = image
                }
            case .failure(let networkError):
                switch networkError{
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
}
