//
//  GitHubUsers.swift
//  Model Generated using http://www.jsoncafe.com/
//  Created on February 22, 2019

import Foundation
import SwiftyJSON


class GitHubUsers : NSObject, NSCoding{
    
    var incompleteResults : Bool!
    var items : [GitHubUser]!
    var totalCount : Int!
    
    /**
     * Instantiate the instance using the passed json values to set the properties values
     */
    init(fromJson json: JSON!){
        if json.isEmpty{
            return
        }
        incompleteResults = json["incomplete_results"].boolValue
        items = [GitHubUser]()
        let itemsArray = json["items"].arrayValue
        for itemsJson in itemsArray{
            let value = GitHubUser(fromJson: itemsJson)
            items.append(value)
        }
        totalCount = json["total_count"].intValue
    }
    
    /**
     * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
     */
    func toDictionary() -> [String:Any]
    {
        var dictionary = [String:Any]()
        if incompleteResults != nil{
            dictionary["incomplete_results"] = incompleteResults
        }
        if items != nil{
            var dictionaryElements = [[String:Any]]()
            for itemsElement in items {
                dictionaryElements.append(itemsElement.toDictionary())
            }
            dictionary["items"] = dictionaryElements
        }
        if totalCount != nil{
            dictionary["total_count"] = totalCount
        }
        return dictionary
    }
    
    /**
     * NSCoding required initializer.
     * Fills the data from the passed decoder
     */
    @objc required init(coder aDecoder: NSCoder)
    {
        incompleteResults = aDecoder.decodeObject(forKey: "incomplete_results") as? Bool
        items = aDecoder.decodeObject(forKey: "items") as? [GitHubUser]
        totalCount = aDecoder.decodeObject(forKey: "total_count") as? Int
    }
    
    /**
     * NSCoding required method.
     * Encodes mode properties into the decoder
     */
    func encode(with aCoder: NSCoder)
    {
        if incompleteResults != nil{
            aCoder.encode(incompleteResults, forKey: "incomplete_results")
        }
        if items != nil{
            aCoder.encode(items, forKey: "items")
        }
        if totalCount != nil{
            aCoder.encode(totalCount, forKey: "total_count")
        }
        
    }
    
}
