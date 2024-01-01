//
//  ReportDetailView.swift
//  Lapor Book
//
//  Created by Erlangga Anugrah Arifin on 26/12/23.
//

import SwiftUI
import MapKit
import SDWebImageSwiftUI

@MainActor
final class ReportDetailViewModel: ObservableObject {
  @Published var user: FSUser = FSUser(uid: "", email: "", fullname: "", phone: "", role: "")
  @Published var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
  @Published var region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), latitudinalMeters: 1000, longitudinalMeters: 1000)
  @Published var comment: String = ""
  @Published var allComments: [CommentModel] = []
  
  func changeStatus(to newStatus: String, reportId: String) async throws {
    try await ReportManager.instance.changeStatus(to: newStatus, reportId: reportId)
  }
  
  func addComm(reportId: String) async throws {
    let auth = try AuthManager.instance.getAuthUser()
    let result = try await AuthManager.instance.getFSUser(user: auth)
    try await ReportManager.instance.createComment(reportId: reportId, content: self.comment, author: result.fullname ?? "")
  }
  
  func delComm(reportId: String, commentId: String) async throws {
    try await ReportManager.instance.deleteComment(reportId: reportId, commentId: commentId)
  }
  
  func delReport(reportId: String) async throws {
    try await ReportManager.instance.deleteReport(reportId: reportId)
  }
}

struct ReportDetailView: View {
  @Environment(\.presentationMode) var presentation
  @State private var changeStatusDialog: Bool = false
  @State private var addComentDetent: Bool = false
  @State private var deleteDialog: Bool = false
  @StateObject private var viewModel = ReportDetailViewModel()
  
  var data: ReportModel?
  
  var body: some View {
    List {
      WebImage(url: URL(string: data?.imgPath ?? ""))
        .resizable()
        .placeholder(content: {
          ProgressView()
            .font(.title)
            .frame(height: UIScreen.main.bounds.height * 0.3)
            .frame(maxWidth: .infinity)
        })
        .onFailure(perform: { _ in
          VStack(spacing: 16) {
            Image(systemName: "wifi.slash")
              .font(.largeTitle)
            Text("Gagal mengunduh")
          }
        })
        .scaledToFit()
        .frame(height: UIScreen.main.bounds.height * 0.3)
        .frame(maxWidth: .infinity)
        .frame(alignment: .center)
      ReportDetailLabelView(data: data?.fullname ?? "", title: "Nama Pelapor", imageSystemName: "person.fill")
      ReportDetailLabelView(data: String(date: data?.date ?? Date(), format: "dd MMMM yyy"), title: "Tanggal Laporan", imageSystemName: "calendar")
      ReportDetailLabelView(data: data?.status ?? "", title: "Status Laporan", imageSystemName: "doc.fill")
      ReportDetailLabelView(data: data?.instance ?? "", title: "Instansi", imageSystemName: "building.fill")
      ReportDetailLabelView(data: data?.desc ?? "", title: "Deskripsi Laporan", imageSystemName: "quote.opening")
      NavigationLink(destination: MapKitView(coordinatePoint: CLLocationCoordinate2D(latitude: data?.lat ?? 0, longitude: data?.long ?? 0), region: $viewModel.region)) {
        HStack {
          Image(systemName: "map.fill")
            .foregroundStyle(.accent)
            .font(.title2)
            .frame(width: 20)
          Text("Lokasi Laporan")
        }
      }
      
      Section {
        if viewModel.user.role == "Admin" {
          Button("Ubah Status...") {
            self.changeStatusDialog.toggle()
          }
          .sheet(isPresented: $addComentDetent, onDismiss: {
            Task {
              do {
                viewModel.allComments = try await ReportManager.instance.loadAllComments(reportId: data?.id ?? "")
              }
            }
          }, content: {
            AddComentView(detent: $addComentDetent, reportId: data?.id ?? "")
              .presentationDetents([.medium])
          })
          .confirmationDialog("", isPresented: $changeStatusDialog) {
            Button("Posted") {
              Task {
                do {
                  try await viewModel.changeStatus(to: "Posted", reportId: data?.id ?? "")
                  presentation.wrappedValue.dismiss()
                }
              }
            }
            Button("Process") {
              Task {
                do {
                  try await viewModel.changeStatus(to: "Process", reportId: data?.id ?? "")
                  presentation.wrappedValue.dismiss()
                }
              }
            }
            Button("Done") {
              Task {
                do {
                  try await viewModel.changeStatus(to: "Done", reportId: data?.id ?? "")
                  presentation.wrappedValue.dismiss()
                }
              }
            }
          } message: {
            Text("Ubah status laporan...")
          }
        }
        Button("Hapus Laporan", role: .destructive, action: {
          self.deleteDialog.toggle()
        })
        .confirmationDialog("Aksi ini tidak dapat dibatalkan", isPresented: $deleteDialog, titleVisibility: .visible) {
          Button(role: .destructive) {
            Task {
              do {
                try await viewModel.delReport(reportId: data?.id ?? "")
                presentation.wrappedValue.dismiss()
              }
            }
          } label: {
            Text("Hapus")
          }
        }
      }
      
      Section {
        if viewModel.allComments.isEmpty {
          Button(action: {}, label: {
            Text("Komentar masih kosong")
          })
          .disabled(true)
        } else {
          ForEach(viewModel.allComments, id: \.self) { each in
            CommentView(fullname: each.author ?? "", time: each.date ?? Date(), content: each.content ?? "")
              .deleteDisabled(viewModel.user.fullname == each.author ?? "" ? false : true)
          }
          .onDelete(perform: { indexSet in
            for index in indexSet {
              let comment = viewModel.allComments[index]
              Task {
                do {
                  try await deleteComment(at: indexSet, reportId: data?.id ?? "", commentId: viewModel.allComments[index].id ?? "")
                }
              }
            }
          })
          
        }
      } header: {
        HStack {
          Text("Daftar Komentar")
          Spacer()
          Button(action: {
            self.addComentDetent.toggle()
          }, label: {
            Text("Tambah Komentar")
              .font(.system(size: 12, weight: .semibold))
          })
        }
      }
      
    }
    .onAppear(perform: {
      self.viewModel.region.center.latitude = data?.lat ?? 0
      self.viewModel.region.center.longitude = data?.long ?? 0
      self.viewModel.coordinate.latitude = data?.lat ?? 0
      self.viewModel.coordinate.longitude = data?.long ?? 0
      Task {
        do {
          viewModel.allComments = try await ReportManager.instance.loadAllComments(reportId: data?.id ?? "")
          let auth = try AuthManager.instance.getAuthUser()
          viewModel.user = try await AuthManager.instance.getFSUser(user: auth)
        } catch {
          print("Error getting user role:", error.localizedDescription)
        }
      }
    })
    .navigationTitle("Detail Laporan")
  }
  
  func deleteComment(at offsets: IndexSet, reportId: String, commentId: String) async throws {
    for index in offsets {
      let commentAuthor = viewModel.allComments[index].author
      if viewModel.user.fullname == commentAuthor {
        do {
          try await viewModel.delComm(reportId: reportId, commentId: commentId)
          viewModel.allComments.remove(atOffsets: offsets)
        }
      }
    }
  }
}

#Preview {
  NavigationStack {
    ReportDetailView(data: ReportModel(date: Date(), id: "123", desc: "Dummy Description", imgFilename: "", imgPath: "", instance: "Suatu Instansi", title: "", userId: "", lat: 0, long: 0, fullname: "SpongeBob SquarePants", status: "Done"))
  }
}




struct CommentView: View {
  var fullname: String
  var time: Date
  var content: String
  
  var body: some View {
    VStack(alignment: .leading) {
      HStack(spacing: 5) {
        Text(fullname)
          .font(.system(size: 12, weight: .semibold))
        Text("\(time.toStringAgo())")
        
          .font(.system(size: 11))
          .foregroundStyle(.gray)
        //              .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/)
      }
      .lineLimit(1)
      Text(content)
    }
  }
}
