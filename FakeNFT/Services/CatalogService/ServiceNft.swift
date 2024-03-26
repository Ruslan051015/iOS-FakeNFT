//
//  ServiceNft.swift
//  FakeNFT
//
//  Created by Георгий Ксенодохов on 28.02.2024.
//

import Foundation

protocol NftServiceLoading {
  func loadOrderId(completion: @escaping ([String]) -> Void)
  func loadLikes(completion: @escaping (Likes) -> Void)
}

protocol NftServicePut {
  func putToCart(id: [String])
  func putToFavorite(id: [String])
}

protocol NftServiceFull: NftServiceLoading, NftServicePut {}

final class ServiceNft: NftServiceFull {
  
  func loadOrderId(completion: @escaping ([String]) -> Void) {
    var urlRequest = URLRequest(url: URL(string: RequestConstants.baseURL + "/api/v1/orders/1")!)
    urlRequest.setValue(RequestConstants.token,
                        forHTTPHeaderField: "X-Practicum-Mobile-Token")
    urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
    URLSession.shared.dataTask(with: urlRequest) { data, _, _ in
      guard let data else {
        return
      }
      let result = try? JSONDecoder().decode(OrderNft.self, from: data)
      if let nfts = result?.nfts {
        DispatchQueue.main.async {
          completion(nfts)
        }
      }
    }.resume()
  }
  
  func loadLikes(completion: @escaping (Likes) -> Void) {
    var urlRequest = URLRequest(url: URL(string: RequestConstants.baseURL + "/api/v1/profile/1")!)
    urlRequest.setValue(RequestConstants.token,
                        forHTTPHeaderField: "X-Practicum-Mobile-Token")
    urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
    URLSession.shared.dataTask(with: urlRequest) { data, _, _ in
      guard let data else {
        return
      }
      let result = try? JSONDecoder().decode(Likes.self, from: data)
      if let nft = result {
        DispatchQueue.main.async {
          completion(nft)
        }
      }
    }.resume()
  }
  
  func putToCart(id: [String]) {
    var urlRequest: URLRequest
    if id.isEmpty {
      urlRequest = URLRequest(url: URL(string: RequestConstants.baseURL +
                                       "/api/v1/orders/1")!)
    } else {
      urlRequest = URLRequest(url: URL(string: RequestConstants.baseURL +
                                       "/api/v1/orders/1?nfts=" +
                                       id.joined(separator: ","))!)
    }
    urlRequest.setValue(RequestConstants.token,
                        forHTTPHeaderField: "X-Practicum-Mobile-Token")
    urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
    urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    urlRequest.httpMethod = "PUT"
    URLSession.shared.dataTask(with: urlRequest) { _, response, error in
      if let error = error {
        print("Error: \(error)")
      } else if let httpResponse = response as? HTTPURLResponse {
        switch httpResponse.statusCode {
        case 200...299:
          print("Запрос выполнен успешно")
          print(httpResponse.statusCode)
        case 400...499:
          print("Ошибка клиентской стороны")
        case 500...599:
          print("Ошибка серверной стороны")
        default:
          print("Неизвестный статус кода: \(httpResponse.statusCode)")
          
        }
      }
    }.resume()
  }
  
  func putToFavorite(id: [String]) {
    var urlRequest: URLRequest
    if id.isEmpty {
      urlRequest = URLRequest(url: URL(string: RequestConstants.baseURL +
                                       "/api/v1/profile/1")!)
    } else {
      urlRequest = URLRequest(url: URL(string: RequestConstants.baseURL +
                                       "/api/v1/profile/1?likes=" +
                                       id.joined(separator: ","))!)
    }
    urlRequest.setValue(RequestConstants.token,
                        forHTTPHeaderField: "X-Practicum-Mobile-Token")
    urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
    urlRequest.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
    urlRequest.httpMethod = "PUT"
    URLSession.shared.dataTask(with: urlRequest) { _, response, error in
      if let error {
        print("Error: \(error.localizedDescription)")
      } else if let httpResponse = response as? HTTPURLResponse {
        switch httpResponse.statusCode {
        case 200...299:
          print("Запрос выполнен успешно")
          print(httpResponse.statusCode)
        case 400...499:
          print("Ошибка клиентской стороны")
        case 500...599:
          print("Ошибка серверной стороны")
        default:
          print("Неизвестный статус кода: \(httpResponse.statusCode)")
        }
      }
    }.resume()
  }
}
