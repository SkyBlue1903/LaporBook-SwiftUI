//
//  AuthManager.swift
//  Lapor Book
//
//  Created by Erlangga Anugrah Arifin on 23/12/23.
//

import Foundation
import Firebase

final class AuthManager {
  static let instance = AuthManager()
  private init() {}
  
  func createUser(email: String, password: String, fullname: String, phone: String) async throws {
    let auth = try await Auth.auth().createUser(withEmail: email, password: password)
    let result = AuthUser(user: auth.user)
    
    var fsData: [String: Any] = [
      "id": result.uid,
      "fullname": fullname,
      "phone": phone
    ]
    if let email = result.email {
      fsData["email"] = email
    }
    
    try await Firestore.firestore().collection("user").document(result.uid).setData(fsData, merge: false)
  }
  
  func signInUser(email: String, password: String) async throws -> FSUser {
    let auth = try await Auth.auth().signIn(withEmail: email, password: password)
    let result = AuthUser(user: auth.user)
    return try await getFSUser(user: result)
  }
  
  
  func getFSUser(user: AuthUser) async throws -> FSUser {
    let snapshot = try await Firestore.firestore().collection("user").document(user.uid).getDocument()
    guard let data = snapshot.data(), let id = data["id"] as? String else {
      throw URLError(.badServerResponse)
    }
    
    let email = data["email"] as? String
    let fullname = data["fullname"] as? String
    let phone = data["phone"] as? String
    
    return FSUser(uid: id, email: email, fullname: fullname)
  }
  
  func logoutUser() throws {
    try Auth.auth().signOut()
  }
  
  func getAuthUser() throws -> AuthUser {
    guard let auth = Auth.auth().currentUser else {
      throw URLError(.badServerResponse)
    }
    return AuthUser(user: auth)
  }
}
