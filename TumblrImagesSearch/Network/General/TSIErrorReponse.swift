//
//  TSIErrorReponse.swift
//  TumblrImagesSearch
//
//  Created by Mihail COSTRACI on 07.02.2022.
//

import Foundation

protocol TSIErrorReponse {
    
    func debugRequest(_ request: URLRequest)
    func debugResponse(_ result: (data: Data, response: URLResponse), decoder: JSONDecoder)
    func processResponse<T: Decodable>(_ result: (data: Data, response: URLResponse),
                                       decoder: JSONDecoder) throws -> APIClientResponse<T>
}

extension TSIErrorReponse {
    
    func processResponse<T: Decodable>(_ result: (data: Data, response: URLResponse),
                                       decoder: JSONDecoder) throws -> APIClientResponse<T> {
        
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        debugResponse(result, decoder: decoder)
        
        guard let response = result.response as? HTTPURLResponse else {
            throw TSIError(code: 0, codeKey: TSIErrorKeys.UNKNOWN_ERROR)
        }
        
        let successStatusRange = Range(uncheckedBounds: (lower: 200, upper: 300))
        
        if successStatusRange.contains(response.statusCode) {
            // Check if response 'Body' is not nil
            guard result.data.count > 0 else {
                return APIClientResponse(value: true as! T, response: result.response)
            }
            
            let jsonDict: [String: Any]?
            let jsonArray: [Any]?
            
            do {
                let jsonObject = try JSONSerialization.jsonObject(with: result.data, options: .mutableLeaves)
                jsonDict = jsonObject as? [String: Any]
                jsonArray = jsonObject as? [Any]
                
            } catch let error as NSError {
                throw TSIError(nsError: error)
            }
            
            if let _ = jsonDict {
                do {
                    let value = try decoder.decode(T.self, from: result.data)
                    return APIClientResponse(value: value, response: result.response)
                    
                } catch {
                    debugPrint("error: \(error)")
                    throw error
                }
                
            } else if let _ = jsonArray {
                let value = try decoder.decode(T.self, from: result.data)
                return APIClientResponse(value: value, response: result.response)
            }
            
            else {
                throw TSIError(code: TSIErrorKeys.UNKNOWN_ERROR.rawValue)
            }
            
        } else {
            let jsonObject = try JSONSerialization.jsonObject(with: result.data, options: .mutableLeaves)
            if let jsonDict = jsonObject as? [String: Any] {
                
                if let errorMessage = jsonDict["message"] as? String {
                    
                    throw TSIError(code: TSIErrorKeys.toRawValue(code: errorMessage),
                                   message: errorMessage)
                }
                    
                if let errorDictObject = jsonDict as? [String: [String]] {
                    
                    var errorMessage = TSIErrorKeys(rawValue: response.statusCode)?.localized() ?? ""
                    
                    if let firstValue = errorDictObject.first, let firstMessage = firstValue.value.first {
                        errorMessage = firstMessage
                    }
                    
                    throw TSIError(code: response.statusCode,
                                   message: errorMessage,
                                   userInfo: errorDictObject)
                    
                } else {
                    let errorMessage = HTTPURLResponse.localizedString(forStatusCode: response.statusCode).capitalized
                    throw TSIError(code: response.statusCode, message: errorMessage)
                }
            } else {
                let errorMessage = HTTPURLResponse.localizedString(forStatusCode: response.statusCode).capitalized
                throw TSIError(code: response.statusCode, message: errorMessage)
            }
        }
    }
    
    func debugRequest(_ request: URLRequest) {
        
        #if DEBUG
        let httpMethod = request.httpMethod ?? ""
        let urlString = request.url?.absoluteString ?? ""
        let header = request.allHTTPHeaderFields ?? [String: String]()
        
        print("\n")
        print("*** Request \(httpMethod): \(urlString)")
        print("    Headers: \(header)")
        
        guard let httpBody = request.httpBody else { return }
        
        do {
            let _httpBody = try JSONSerialization.jsonObject(with: httpBody)
            print("    Body: \(_httpBody)")
        } catch {
            print("Error in body serialization: \(error)")
        }
        
        print("\n")
        #endif
    }
    
    func debugResponse(_ result: (data: Data, response: URLResponse), decoder: JSONDecoder) {
        
        #if DEBUG
        guard let response = result.response as? HTTPURLResponse else {
            return
        }
        
        let urlString = response.url?.absoluteString ?? ""
        
        print("\n")
        print("*** Response url: \(urlString)")
        print("    Status Code: \(response.statusCode)")
        print("    Headers: \(response.allHeaderFields)")
            
        do {
            let jsonObject = try JSONSerialization.jsonObject(with: result.data, options: .allowFragments)
            guard let httpBody = jsonObject as? [String: Any] else {
                return
            }
            print("    Body: \(httpBody)")
        } catch {
            print("Error in body serialization: \(error)")
        }
        
        print("\n")
        #endif
    }
}
