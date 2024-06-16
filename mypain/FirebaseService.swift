//
//  Project name: mypain
//  File name: FirebaseService.swift
//
//  Copyright © Gromov V.O., 2024
//


import Foundation
import FirebaseFirestore
import FirebaseFirestoreSwift

final class FirebaseService {
    
    init() {
        print("firebase service created")
    }
    
    private let collectionName = "cars"
    private lazy var db = Firestore.firestore().collection(collectionName)
    private var listener: ListenerRegistration?
    
    func getDataFromFirestore(completion: @escaping (QuerySnapshot)->Void) {
        
        self.db.getDocuments { query, error in
            guard error == nil else { print("get docs error"); return }
            guard let query = query else {print("query error"); return }
            print("collection \"\(self.collectionName)\" contains \(query.count) objects")
            completion(query)
        }
    }
    
    func getDataFromFirestoreAsync() async -> QuerySnapshot? {
        do {
            let querySnapshot = try await self.db.getDocuments()
            print("collection \"\(self.collectionName)\" contains \(querySnapshot.count) objects")
            return querySnapshot
        } catch {
            print(error.localizedDescription)
            return nil
        }
    }
    
    func updateDocument(withID docID: String, fields: [AnyHashable: Any]) {
        db.document(docID).updateData(fields)
        
    }
    
    func updateDocument2(withID docID: String, fields: [String: Any]) {
        db.document(docID).setData(fields, merge: true)
    }
    
    func convertDocumentToObjectManual(document: QueryDocumentSnapshot) -> Car {
        var result: Car
        
        let carData = document.data()
        let name = carData["name"] as? String ?? "no"
        let country = carData["country"] as? String ?? "no"
        let foundedYear = carData["founded_year"] as? Int ?? 0
        result = Car(name: name, country: country, foundedYear: foundedYear)
        
        //      or try document.data(as: Car.self)
        
        return result
    }
    
    func convertDocumentToObjectCodable(document: QueryDocumentSnapshot) -> Car {
        var result: Car
        
        do {
            result = try document.data(as: Car.self)
            return result
            
        } catch {
            print(error.localizedDescription)
            return Car.shared
        }
        
    }
    
    func loadDataToFirestore(car: Car) {
        do {
            try self.db.addDocument(from: car)
        } catch let error {
            print(error.localizedDescription)
        }
    }
    
    func loadDataToFirestoreAsyncManual(fields: [String: Any]) {
        Task {
            do {
                let ref = try await db.addDocument(data: fields)
                print("added doc with id \(ref.documentID)")
            } catch {
                print(error.localizedDescription)
            }
        }
    }
    
    func addDBListener(completion: @escaping (QuerySnapshot)->Void) {
        listener = self.db.addSnapshotListener { query, error in
            guard error == nil else {print("snapshot error"); return }
            guard let query = query else {print("snapshot query error"); return }
            print("db updated. now \(query.count) elements")
            completion(query)
        }
        print("listener added")
    }
    
    func removeDBListener() {
        listener?.remove()
    }
    
    enum FirebaseQueryOperator {
        case equalTo, notEqualTo,lessThan, greaterThan, lessThanOrEqualTo, greaterThanOrEqualTo
    }
    
    func getDataFromFirestoreWithQuery(
        fieldName: String,
        queryOperator: FirebaseQueryOperator,
        value: Any,
        completion: @escaping (QuerySnapshot)->Void
    ) {
        var dbWithQuery = db.whereField("name", isNotEqualTo: "")
        
        switch queryOperator {
        case .equalTo:
            dbWithQuery = db.whereField(fieldName, isEqualTo: value)
        case .notEqualTo:
            dbWithQuery = db.whereField(fieldName, isNotEqualTo: value)
        case .lessThan:
            dbWithQuery = db.whereField(fieldName, isLessThan: value)
        case .greaterThan:
            dbWithQuery = db.whereField(fieldName, isGreaterThan: value)
        case .lessThanOrEqualTo:
            dbWithQuery = db.whereField(fieldName, isLessThanOrEqualTo: value)
        case .greaterThanOrEqualTo:
            dbWithQuery = db.whereField(fieldName, isGreaterThanOrEqualTo: value)
        }
        
        dbWithQuery.getDocuments { query, error in
            guard error == nil else { print("get docs error"); return }
            guard let query = query else {print("query error"); return }
            print("collection by query \"\(self.collectionName)\" contains \(query.count) objects")
            completion(query)
        }
        
    }
}
