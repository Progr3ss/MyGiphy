//
//  ViewController.swift
//  MyGiphy
//
//  Created by Martin  Chibwe on 12/16/19.
//  Copyright © 2019 Tomorrow Ideas. All rights reserved.
//

import UIKit
import Alamofire
import SDWebImage

class collvwCell: UICollectionViewCell {
    
    @IBOutlet var GIFimgvw: UIImageView!
}

class ViewController: UIViewController {
    
    @IBOutlet var searchBarGif: UISearchBar!
    @IBOutlet var collvwGif: UICollectionView!
    var arrayOfData = [NSDictionary]()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let keyboardToolbar = UIToolbar()
        keyboardToolbar.sizeToFit()
        let flexBarButton = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneBarButton = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(dismissKeyboard))
        keyboardToolbar.items = [flexBarButton, doneBarButton]
        searchBarGif.inputAccessoryView = keyboardToolbar
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(true)
    }
    
    @objc func dismissKeyboard() {
        view.endEditing(true)
    }
    
    func loadGif(strSearch: String)
    {
        
        let urlString:String = "http://api.giphy.com/v1/gifs/search?api_key=OyrKI453xRrSro1fOs2iZjbrMOcieu4K&q=\(strSearch)"
        
        Alamofire.request(urlString, method: .get,  encoding: URLEncoding.default, headers: nil).responseJSON { (response:DataResponse<Any>) in
            switch(response.result) {
                
            case .success(_):

                if response.result.value != nil{
                    let dict :NSDictionary = response.result.value! as! NSDictionary
                    self.arrayOfData = [NSDictionary]()
                    self.arrayOfData = dict.object(forKey: "data") as! [NSDictionary]
                    self.collvwGif.reloadData()
                }
                break
                
            case .failure(_):
                self.view.makeToast("Somthing went wrong")
                print(response.result.error)
                break
                
            }
        }
    }
}

extension ViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return arrayOfData.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! collvwCell
        
        let dict: NSDictionary = arrayOfData[indexPath.row].object(forKey: "images") as! NSDictionary
        let dictFixedHeight: NSDictionary = dict.object(forKey: "fixed_height") as! NSDictionary
        let strUrl: String = dictFixedHeight.object(forKey: "url") as! String

        cell.GIFimgvw.sd_setImage(with: URL(string: strUrl), placeholderImage: UIImage(named: "placeholder.png"))
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        return CGSize(width: self.view.frame.size.width/4, height: self.view.frame.size.width/4)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let strTitle: String = arrayOfData[indexPath.row].object(forKey: "title") as! String
        let strSource: String = arrayOfData[indexPath.row].object(forKey: "source") as! String
        let strSourceWebsite: String = arrayOfData[indexPath.row].object(forKey: "source_tld") as! String
        
        let dict: NSDictionary = arrayOfData[indexPath.row].object(forKey: "images") as! NSDictionary
        let dictFixedHeight: NSDictionary = dict.object(forKey: "fixed_height") as! NSDictionary
        let strUrl: String = dictFixedHeight.object(forKey: "url") as! String


        let alert = EMAlertController(title: "Gif \(indexPath.row+1)", message: "Title: \(strTitle) \n\nSource: \(strSource) \n\nSource Website: \(strSourceWebsite)")

        
        alert.addTextField { (textField) in
          textField?.placeholder = "Enter  Comment"
        }

        let cancel = EMAlertAction(title: "Done", style: .cancel)
        alert.addAction(cancel)
        present(alert, animated: true, completion: nil)
    }
}

extension ViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchBar.text!.count > 1{
            loadGif(strSearch: searchBar.text!)
        }
    }
    
    func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        arrayOfData.removeAll()
        self.view.endEditing(true)
        searchBar.text = ""
        collvwGif.reloadData()
    }
}
