//
//  GitHubLicense.swift
//  Model Generated using http://www.jsoncafe.com/ 
//  Created on February 22, 2019

import Foundation
import SwiftyJSON


class GitHubLicense : NSObject, NSCoding{

    var key : String!
    var name : String!
    var nodeId : String!
    var spdxId : String!
    var url : String!

	/**
	 * Instantiate the instance using the passed json values to set the properties values
	 */
	init(fromJson json: JSON!){
		if json.isEmpty{
			return
		}
        key = json["key"].stringValue
        name = json["name"].stringValue
        nodeId = json["node_id"].stringValue
        spdxId = json["spdx_id"].stringValue
        url = json["url"].stringValue
	}

	/**
	 * Returns all the available property values in the form of [String:Any] object where the key is the approperiate json key and the value is the value of the corresponding property
	 */
	func toDictionary() -> [String:Any]
	{
		var dictionary = [String:Any]()
        if key != nil{
        	dictionary["key"] = key
        }
        if name != nil{
        	dictionary["name"] = name
        }
        if nodeId != nil{
        	dictionary["node_id"] = nodeId
        }
        if spdxId != nil{
        	dictionary["spdx_id"] = spdxId
        }
        if url != nil{
        	dictionary["url"] = url
        }
		return dictionary
	}

    /**
    * NSCoding required initializer.
    * Fills the data from the passed decoder
    */
    @objc required init(coder aDecoder: NSCoder)
	{
		key = aDecoder.decodeObject(forKey: "key") as? String
		name = aDecoder.decodeObject(forKey: "name") as? String
		nodeId = aDecoder.decodeObject(forKey: "node_id") as? String
		spdxId = aDecoder.decodeObject(forKey: "spdx_id") as? String
		url = aDecoder.decodeObject(forKey: "url") as? String
	}

    /**
    * NSCoding required method.
    * Encodes mode properties into the decoder
    */
    func encode(with aCoder: NSCoder)
	{
		if key != nil{
			aCoder.encode(key, forKey: "key")
		}
		if name != nil{
			aCoder.encode(name, forKey: "name")
		}
		if nodeId != nil{
			aCoder.encode(nodeId, forKey: "node_id")
		}
		if spdxId != nil{
			aCoder.encode(spdxId, forKey: "spdx_id")
		}
		if url != nil{
			aCoder.encode(url, forKey: "url")
		}

	}

}
