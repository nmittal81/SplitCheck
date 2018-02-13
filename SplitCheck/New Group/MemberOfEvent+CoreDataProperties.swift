//
//  MemberOfEvent+CoreDataProperties.swift
//  SplitCheck
//
//  Created by Neha Mittal on 2/13/18.
//  Copyright © 2018 Neha Mittal. All rights reserved.
//
//

import Foundation
import CoreData


extension MemberOfEvent {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<MemberOfEvent> {
        return NSFetchRequest<MemberOfEvent>(entityName: "MemberOfEvent")
    }

    @NSManaged public var fname: String?
    @NSManaged public var drinks: Double
    @NSManaged public var food: Double
    @NSManaged public var total: Double
    @NSManaged public var event: Events?

}

extension MemberOfEvent {
    
    @objc(addEventObject:)
    @NSManaged public func addToEvent(_ value: Events)
    
    @objc(removeEventObject:)
    @NSManaged public func removeFromEvents(_ value: Events)

    
}
