//
//  ReportManager.swift
//  Lapor Book
//
//  Created by Erlangga Anugrah Arifin on 24/12/23.
//

import Foundation
import FirebaseFirestore

final class ReportManager {
  static let instance = ReportManager()
  private init() { }
  
  func createReport(title: String, location: String = "-", instance: String, desc: String, path: String, filename: String, lat: Double, long: Double) async throws {
    let user = try AuthManager.instance.getAuthUser()
    let fsUser = try await AuthManager.instance.getFSUser(user: user)
    let autoID = Firestore.firestore().collection("report").document().documentID
    let data : [String: Any] = [
      "date": Timestamp(),
      "desc": desc,
      "id": autoID,
      "userId": user.uid,
      "reportTitle": title,
      "instance": instance,
      "imagePath": path,
      "imageFilename": filename,
      "status": "Posted",
      "latitude": lat,
      "longitude": long,
      "fullname": fsUser.fullname ?? ""
    ]
    try await Firestore.firestore().collection("report").document(autoID).setData(data, merge: true)
  }
  
  func loadAllReports(byId: String = "") async throws -> [ReportModel] {
    var tempArray = [ReportModel]()
    let allQuery = try await Firestore.firestore().collection("report").getDocuments()
    let specificQuery = try await Firestore.firestore().collection("report").whereField("userId", isEqualTo: byId).getDocuments()
    let qs = byId == "" ? allQuery : specificQuery
    for report in qs.documents {
      let timestamp = report["date"] as? Timestamp
      let date = timestamp?.dateValue() as? Date
      let desc = report["desc"] as? String
      let id = report["id"] as? String ?? ""
      let imgFile = report["imageFilename"] as? String
      let imgPath = report["imagePath"] as? String
      let instance = report["instance"] as? String
      let title = report["reportTitle"] as? String
      let uid = report["userId"] as? String
      let lat = report["latitude"] as? Double
      let long = report["longitude"] as? Double
      let fullname = report["fullname"] as? String
      let status = report["status"] as? String
      tempArray.append(ReportModel(date: date, id: id, desc: desc, imgFilename: imgFile, imgPath: imgPath, instance: instance, title: title, userId: uid, lat: lat, long: long, fullname: fullname, status: status))
    }
    return tempArray
  }
  
  func changeStatus(to newStatus: String, id: String) async throws {
    try await Firestore.firestore().collection("report").document(id).setData(["status": newStatus], merge: true)
  }
}
