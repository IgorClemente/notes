//
//  Note.swift
//  Notes
//
//  Created by MACBOOK AIR on 18/02/2018.
//  Copyright © 2018 MACBOOK AIR. All rights reserved.
//

import Foundation

extension Note {
    
    var updateAtAsDate: Date {
        guard let updateAt = updateAt else {
            return Date()
        }
        return Date(timeIntervalSince1970: updateAt.timeIntervalSince1970)
    }
    
    var createAtAsDate: Date {
        guard let createAt = createAt else {
            return Date()
        }
        return Date(timeIntervalSince1970: createAt.timeIntervalSince1970)
    }
    
    var alphabetizedTags: [Tag]? {
        guard let tags = tags as? Set<Tag> else {
            return nil
        }
        
        return tags.sorted(by: {
            guard let tag0 = $0.name else { return true }
            guard let tag1 = $1.name else { return true }
            return tag0 < tag1
        })
    }
    
    var alphabetizedTagsAsString: String? {
        guard let tags = alphabetizedTags, tags.count > 0 else {
            return nil
        }
        
        let names = tags.flatMap { $0.name }
        return names.joined(separator: ", ")
    }
}
