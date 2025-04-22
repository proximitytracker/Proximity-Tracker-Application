//
//  URLSessionExtension.swift
//  Tag Scanner (iOS)
//
//  Created by Jeffrey Abraham on 24.01.23.
//

import Foundation

/// This extension adds async/await support to URLSession on platforms that support it (iOS 13+, macOS 10.15+).
@available(macOS 10.15, watchOS 6.0, iOS 13.0, *)
extension URLSession {
    /// A wrapper around `URLSession.dataTask` using Swift Concurrency (`async`/`await`).
    /// Allows you to fetch data from a URL asynchronously in a cleaner, more readable format.
    /// - Parameter request: The URLRequest to perform.
    /// - Returns: A tuple containing the downloaded Data and the URLResponse.
    /// - Throws: An error if the request fails.
    func asyncData(for request: URLRequest) async throws -> (Data, URLResponse) {
        return try await withCheckedThrowingContinuation { checkedContinuation in
            let task = dataTask(with: request) { data, response, error in
               // If we got both data and a response, return them through the continuation
                                                
                if let data, let response {
                    checkedContinuation.resume(returning: (data, response))
                    // If there was an error, throw it
                }else if let error {
                    checkedContinuation.resume(throwing: error)
                }else {
                    checkedContinuation.resume(throwing: URLError(.cancelled))
                }
            }
            
            task.resume()
        }
    }
}
