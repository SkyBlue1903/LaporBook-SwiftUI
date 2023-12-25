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
  
  func createReport(title: String, location: String = "-", instance: String, desc: String, path: String, filename: String) async throws {
    let user = try AuthManager.instance.getAuthUser()
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
      "status": "Posted"
    ]
    try await Firestore.firestore().collection("report").document(autoID).setData(data, merge: true)
  }
  
  func loadAllReports() async throws -> [ReportModel] {
    var tempArray = [ReportModel]()
    let qs = try await Firestore.firestore().collection("report").getDocuments()
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
      tempArray.append(ReportModel(date: date, id: id, desc: desc, imgFilename: imgFile, imgPath: imgPath, instance: instance, title: title, userId: uid))
    }
    return tempArray
  }
}
