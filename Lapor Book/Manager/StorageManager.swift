//
//  StorageManager.swift
//  Lapor Book
//
//  Created by Erlangga Anugrah Arifin on 24/12/23.
//

import Foundation
import FirebaseStorage

final class StorageManager {
  static let instance = StorageManager()
  private init() { }
  private let storage = Storage.storage().reference()
  private var imageReference: StorageReference {
    storage.child("reportImage")
  }
  
  func saveImage(data: Data) async throws -> (path: String, filename: String) {
    let meta = StorageMetadata()
    meta.contentType = "image/jpeg"
    
    let path = "\(UUID().uuidString.lowercased()).jpeg"
    let returnedMetadata = try await imageReference.child(path).putDataAsync(data, metadata: meta)
    
    guard let _ = returnedMetadata.path, let returnedName = returnedMetadata.name else {
      throw URLError(.badServerResponse)
    }
    let imageUrl = try await imageReference.child(path).downloadURL()
    return (imageUrl.absoluteString, returnedName)
  }
}
