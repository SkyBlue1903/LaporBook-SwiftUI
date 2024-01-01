//
//  Model.swift
//  Lapor Book
//
//  Created by Erlangga Anugrah Arifin on 23/12/23.
//

import Foundation
import Firebase

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
  let phone: String?
  let role: String?
  init(uid: String, email: String?, fullname: String?, phone: String?, role: String?) {
    self.uid = uid
    self.email = email
    self.fullname = fullname
    self.phone = phone
    self.role = role
  }
}

struct ReportModel: Hashable, Codable {
  let date: Date?
  let id: String?
  let desc: String?
  let imgFilename: String?
  let imgPath: String?
  let instance: String?
  let title: String?
  let userId: String?
  let lat: Double?
  let long: Double?
  let fullname: String?
  let status: String?
}

struct CommentModel: Hashable, Codable {
  let date: Date?
  let content: String?
  let author: String?
  let id: String?
}
