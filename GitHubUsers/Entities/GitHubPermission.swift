//
//  GitHubPermission.swift
//  Model Generated using http://www.jsoncafe.com/ 
//  Created on February 22, 2019

import Foundation
import SwiftyJSON


class GitHubPermission : NSObject, NSCoding{

    var admin : Bool!
    var pull : Bool!
    var push : Bool!

	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
        admin = json["admin"].boolValue
        pull = json["pull"].boolValue
        push = json["push"].boolValue
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
        if admin != nil{
        	dictionary["admin"] = admin
        }
        if pull != nil{
        	dictionary["pull"] = pull
        }
        if push != nil{
        	dictionary["push"] = push
        }
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
		admin = aDecoder.decodeObject(forKey: "admin") as? Bool
		pull = aDecoder.decodeObject(forKey: "pull") as? Bool
		push = aDecoder.decodeObject(forKey: "push") as? Bool
	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    func encode(with aCoder: NSCoder)
	{
		if admin != nil{
			aCoder.encode(admin, forKey: "admin")
		}
		if pull != nil{
			aCoder.encode(pull, forKey: "pull")
		}
		if push != nil{
			aCoder.encode(push, forKey: "push")
		}

	}

}
