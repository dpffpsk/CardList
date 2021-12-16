//
//  CardListViewController.swift
//  CreditCardList
//
//  Created by 이니텍 on 2021/12/14.
//

import UIKit
import Kingfisher
import FirebaseDatabase
import FirebaseFirestore

class CardListViewController: UITableViewController {
    
//    //Firebase Realtime Database를 가져올 수 있는 값(데이터베이스의 루트)
//    var ref: DatabaseReference!
    
    //Firebase Firestore Database
    var db = Firestore.firestore()
    
    var creditCardList: [CreditCard] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        //(nibname 설정 후)cell register
        let nibName = UINib(nibName: "CardListCell", bundle: nil)
        tableView.register(nibName, forCellReuseIdentifier: "CardListCell")
        
        
//        //Firebase Realtime Database에서 데이터 읽기
//        ref = Database.database().reference()
//        ref.observe(.value) { snapshot in
//            guard let value = snapshot.value as? [String: [String: Any]] else { return }
//            do {
//                let jsonData = try JSONSerialization.data(withJSONObject: value)
//                let cardData = try JSONDecoder().decode([String: CreditCard].self, from: jsonData)
//                let cardList = Array(cardData.values)
//                self.creditCardList = cardList.sorted { $0.rank < $1.rank } //순위 기준 정렬
//
//                //메인에서 동작하도록 설정
//                DispatchQueue.main.async {
//                    self.tableView.reloadData()
//                }
//            } catch let error {
//                print("ERROR JSON parsing \(error.localizedDescription)]")
//            }
//        }
        
        //Firebase Firestore Database에서 데이터 읽기
        db.collection("creditCardList").addSnapshotListener { snapshot, error in
            guard let documents = snapshot?.documents else {
                print("ERROR Firestore fetching document \(String(describing: error))")
                return
            }
            
            self.creditCardList = documents.compactMap { doc -> CreditCard? in
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: doc.data(), options: [])
                    let creditCard = try JSONDecoder().decode(CreditCard.self, from: jsonData)
                    return creditCard
                } catch let error {
                    print("ERROR JSON Parsing \(error)")
                    return nil
                }
            }.sorted { $0.rank < $1.rank }
            
            //메인에서 동작하도록 설정
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }
    }
    
    //MARK: - numberOfRowsInSection
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return creditCardList.count
    }
    
    //MARK: - cellForRowAt
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "CardListCell", for: indexPath) as? CardListCell else { return UITableViewCell() }
        cell.rankLabel.text = "\(creditCardList[indexPath.row].rank)위"
        cell.promotionLabel.text = "\(creditCardList[indexPath.row].promotionDetail.amount)만원 증정"
        cell.cardNameLabel.text = "\(creditCardList[indexPath.row].name)"
        
        let imageURL = URL(string: creditCardList[indexPath.row].cardImageURL)
        cell.cardImageView.kf.setImage(with: imageURL)
        
        return cell
    }
    
    //MARK: - heightForRowAt
    /// - cell의 높이 지정
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    //    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
    //        return 80
    //    }
    
    
    //MARK: - didSelectRowAt
    //상세화면 전달
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let storyboard = UIStoryboard(name: "Main", bundle: Bundle.main)
        guard let detailViewController = storyboard.instantiateViewController(withIdentifier: "CardDetailViewController") as? CardDetailViewController else { return }
        
        detailViewController.promotionDetail = creditCardList[indexPath.row].promotionDetail
        self.show(detailViewController, sender: nil)
        

//        //Firebase Realtime Database 데이터 쓰기
//        //Option1 : 경로를 알고 있을 경우
//        //let cardID = creditCardList[indexPath.row].id
//        //ref.child("Item\(cardID)/isSelected").setValue(true)
//
//        //Option2 : 경로를 모르는 경우
//        let cardID = creditCardList[indexPath.row].id
//        ref.queryOrdered(byChild: "id").queryEqual(toValue: cardID).observe(.value) { [weak self] snapshot in
//            guard let self = self,
//                  let value = snapshot.value as? [String: [String: Any]],
//                  let key = value.keys.first else { return }
//            self.ref.child("\(key)/isSelected").setValue(true)
//
//        }
        
        //Firebase Firestore Database 데이터 쓰기
        //Option1 : 경로를 알고 있을 경우
        //let cardID = creditCardList[indexPath.row].id
        //db.collection("creditCardList").document("card\(cardID)").updateData(["isSelected" : true])
        
        //Option2 : 경로를 모르는 경우
        let cardID = creditCardList[indexPath.row].id
        db.collection("creditCardList").whereField("id", isEqualTo: cardID).getDocuments { snapshot, _ in
            guard let document = snapshot?.documents.first else {
                print("ERROR Firestore fetching document")
                return
            }
            document.reference.updateData(["isSelected": true])
        }
    }
    
    
    //MARK: - canEditRowAt
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    //MARK: - editingStyle
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        
        if editingStyle == .delete {
//            //Firebase Realtime Database 데이터 삭제
//            //Option1 : 경로 알고 있는 경우
//            //let cardID = creditCardList[indexPath.row].id
//            //ref.child("Item\(cardID)").removeValue()
//
//            //Option2 : 경로 모르는 경우
//            let cardID = creditCardList[indexPath.row].id
//            ref.queryOrdered(byChild: "id").queryEqual(toValue: cardID).observe(.value) { [weak self] snapshot in
//                guard let self = self,
//                      let value = snapshot.value as? [String: [String: Any]],
//                      let key = value.keys.first else { return }
//                self.ref.child(key).removeValue()
//            }
            
            //Firebase Firestore Database 데이터 삭제
            //Option1 : 경로 알고 있는 경우
            let cardID = creditCardList[indexPath.row].id
            db.collection("creditCardList").document("card\(cardID)").delete()
            
            //Option2 : 경로 모르는 경우
            db.collection("creditCardList").whereField("id", isEqualTo: cardID).getDocuments { snapshot, _ in
                guard let document = snapshot?.documents.first else {
                    print("ERROR")
                    return
                }
                document.reference.delete()
            }
        }
    }
}
