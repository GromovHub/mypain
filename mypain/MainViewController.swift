//
//  Project name: mypain
//  File name: MainViewController.swift
//
//  Copyright © Gromov V.O., 2024
//


import UIKit
import FirebaseFirestore

class MainViewController: UIViewController {
    
    // init firebase
    let firebase: FirebaseService = FirebaseService()
    
    let mainTable = UITableView()
    
    // local data for views
    var query: QuerySnapshot? = nil {
        didSet {
            print("query recieved")
            mainTable.reloadData()
            callAlert()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        callDBAsync()
        
        // add autoupdate
        firebase.addDBListener {
            self.query = $0
            self.callAlert()
        }
    }
    
    override func viewIsAppearing(_ animated: Bool) {
        view.addSubview(self.mainTable)
        mainTable.dataSource = self
        mainTable.delegate = self
        mainTable.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        mainTable.frame = view.bounds
        mainTable.backgroundColor = .red
        mainTable.rowHeight = 150
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        // remove autoupdate
        firebase.removeDBListener()
    }
    
    func callAlert() {
        let alertController = UIAlertController(title: "DB updated", message: "", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default)
        alertController.addAction(action)
        present(alertController, animated: true)
    }
}


// MARK: - Firebase

extension MainViewController {
    
    // call db with completion handler
    private func callDBCompletion() {
        firebase.getDataFromFirestore { [weak self] query in
            guard let self = self else {print("no self"); return }
            self.query = query
            // show only the first object
            let object = firebase.convertDocumentToObjectCodable(document: query.documents[0])
            dump(object)
        }
    }
    
    // call db with await
    private func callDBAsync() {
        Task {
            self.query = await firebase.getDataFromFirestoreAsync()
            guard let query = query else {print("query error main vc"); return }
            // show only the first object
            let object = firebase.convertDocumentToObjectCodable(document: query.documents[0])
            dump(object)
        }
    }
    
    // call db by specific query
    private func callDBCompletionWithQuery(fieldName: String,
                                           queryOperator: FirebaseService.FirebaseQueryOperator,
                                           value: Any) {
        firebase
            .getDataFromFirestoreWithQuery(
                fieldName: fieldName,
                queryOperator: queryOperator,
                value: value) { [weak self] query in
                    guard let self = self else {print("no self"); return }
                    self.query = query
                    print("---divider---show all objects---")
                    for i in query.documents {
                        let object = firebase.convertDocumentToObjectCodable(document: i)
                        dump(object)
                    }
                }
    }
}

// MARK: - TableView

extension MainViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        var config = cell.defaultContentConfiguration()
        guard let query = query else {
            print("query error cellForRowAt"); return UITableViewCell()
        }
        let carForIndex = firebase
            .convertDocumentToObjectCodable(document: query.documents[indexPath.row])
        config.text = """
name: \(carForIndex.name)
country: \(carForIndex.country)
founded: \(carForIndex.foundedYear)
id: \(query.documents[indexPath.row].documentID)
"""
        cell.contentConfiguration = config
        return cell
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let query = query else {print("no query"); return 1 }
        return query.count
    }
}

