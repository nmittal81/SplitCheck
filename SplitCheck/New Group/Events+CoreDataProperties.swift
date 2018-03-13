//
//  Events+CoreDataProperties.swift
//  SplitCheck
//
//  Created by Neha Mittal on 2/13/18.
//  Copyright © 2018 Neha Mittal. All rights reserved.
//
//

import Foundation
import CoreData


extension Events {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Events> {
        return NSFetchRequest<Events>(entityName: "Events")
    }

    @NSManaged public var title: String?
    @NSManaged public var amount: Double
    @NSManaged public var date: String?
    @NSManaged public var location: String?
    @NSManaged public var number: Int16
    @NSManaged public var members: NSSet?
    @NSManaged public var latitude: Double
    @NSManaged public var longitude: Double
    
}

// MARK: Generated accessors for members
extension Events {

    @objc(addMembersObject:)
    @NSManaged public func addToMembers(_ value: MemberOfEvent)

    @objc(removeMembersObject:)
    @NSManaged public func removeFromMembers(_ value: MemberOfEvent)

    @objc(addMembers:)
    @NSManaged public func addToMembers(_ values: NSSet)

    @objc(removeMembers:)
    @NSManaged public func removeFromMembers(_ values: NSSet)

}
