//
//  Model.swift
//  Lapor Book
//
//  Created by Erlangga Anugrah Arifin on 23/12/23.
//

import Foundation
import FirebaseAuth

struct AuthUser {
  let uid: String
  let email: String?
  init(user: User) {
    self.uid = user.uid
    self.email = user.email
  }
}

struct FSUser {
  let uid: String
  let email: String?
  let fullname: String?
  init(uid: String, email: String?, fullname: String?) {
    self.uid = uid
    self.email = email
    self.fullname = fullname
  }
}
