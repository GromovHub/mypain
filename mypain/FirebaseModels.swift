//
//  Project name: mypain
//  File name: FirebaseModels.swift
//
//  Copyright © Gromov V.O., 2024
//


import Foundation
import FirebaseFirestore

struct Car: Codable {
    
    enum CodingKeys: String, CodingKey {
        case name
        case country
        case foundedYear = "founded_year"
    }
    
    var name: String
    var country: String
    var foundedYear: Int
    
    // ---
    private init() {
        self.name = "object with error or no object yet"
        self.country = "object with error or no object yet"
        self.foundedYear = 0
    }
    static let shared = Car()
    // ---
    
    init(name: String, country: String, foundedYear: Int) {
        self.name = name
        self.country = country
        self.foundedYear = foundedYear
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.name = try container.decode(String.self, forKey: .name)
        self.country = try container.decode(String.self, forKey: .country)
        self.foundedYear = try container.decode(Int.self, forKey: .foundedYear)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.name, forKey: .name)
        try container.encode(self.country, forKey: .country)
        try container.encode(self.foundedYear, forKey: .foundedYear)
    }
}

struct CarsData: Codable {
    
    enum CodingKeys: String, CodingKey {
        case carManufacturers = "car_manufacturers"
    }
    
    var carManufacturers: [Car]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        self.carManufacturers = try container.decode([Car].self, forKey: .carManufacturers)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(self.carManufacturers, forKey: .carManufacturers)
    }
}
