//
//  VideoJson.swift
//  Fun
//
//  Created by Jake Rein on 12/19/18.
//  Copyright © 2018 Jake Rein. All rights reserved.
//

import Foundation
// To parse the JSON, add this file to your project and do:
//
//   let welcome = try? newJSONDecoder().decode(Welcome.self, from: jsonData)

public struct Welcome: Codable {
    public let normal: Normal
    
    public init(normal: Normal) {
        self.normal = normal
    }
}

public struct Normal: Codable {
    public let storage: [Storage]
    
    public init(storage: [Storage]) {
        self.storage = storage
    }
}

public struct Storage: Codable {
    public let quality, source, filename: String
    public let link: String
    public let sub: String
    
    public init(quality: String, source: String, filename: String, link: String, sub: String) {
        self.quality = quality
        self.source = source
        self.filename = filename
        self.link = link
        self.sub = sub
    }
}
