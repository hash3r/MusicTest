//
//  RestAPI.swift
//  MusicTest
//
//  Created by Vladimir Gnatiuk on 11/3/15.
//  Copyright © 2015 Vladimir Gnatiuk. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

/// REST singleton class for communicating with the services
public class RestAPI {
	
	///  A shared instance of `RestAPI`, used by top-level request methods
	static let sharedInstance = RestAPI()
	
	/// Alamofire manager  that responsible for creating and managing `Request` objects
	private let manager = Alamofire.Manager()
	
	/**
	Submit poll
	- parameter name: user name
	- parameter selection: user's selection
	*/
	public func submittPoll(name: String, selection: String, success:(JSON) -> (), failure: (error: NSError?) -> ()) {
		let router = Router.SubmitPoll(name, selection)
		manager.request(router).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    success(json)
                }
            case .Failure(let error):
                failure(error: error)
            }
		}
	}
    
    /**
     Get poll results
     */
    public func pollResults(success:(JSON) -> (), failure: (error: NSError?) -> ()) {
        let router = Router.PollResults
        manager.request(router).validate().responseJSON { response in
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    success(json)
                }
            case .Failure(let error):
                failure(error: error)
            }
        }
    }
}


/// Router helps to manage requests to specific target
enum Router: URLRequestConvertible {
	
	/// Base url
	static let baseURLString = "https://demo7130406.mockable.io"
	
	/// Target list
	case SubmitPoll(String, String)
	case PollResults
    
	/// HTTP method for specific target
	var method: Alamofire.Method {
		switch self {
		case .SubmitPoll:
			return .POST
        case .PollResults:
            return .GET
		}
        
	}

	/// Path for specific target for base URL
	var path: String {
		switch self {
		case .SubmitPoll:
			return "/submit-poll"
        case .PollResults:
            return "/poll-results"
		}
	}

	/// Parameters for specific target
	var params: Dictionary<String, AnyObject> {
		switch self {
        case .SubmitPoll(let name, let selection):
            return ["name": name, "selection": selection]
        default:
            return Dictionary<String, AnyObject>()
		}
	}
	
	// MARK: URLRequestConvertible
	
	var URLRequest: NSMutableURLRequest {
		let URL = NSURL(string: Router.baseURLString)!
		let mutableURLRequest = NSMutableURLRequest(URL: URL.URLByAppendingPathComponent(path))
		mutableURLRequest.HTTPMethod = method.rawValue
		
//		Sign request with api key if needed
//		if let token = Router.authAPIKey {
//			mutableURLRequest.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
//		}
	
//		switch self {
//		case .SubmitPoll(_, _):
//			return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: params).0
//        default:
//            return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: params).0
//		}
        return Alamofire.ParameterEncoding.URL.encode(mutableURLRequest, parameters: params).0
	}
}