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
  @Published var userRole: String = ""
  @Published var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
  @Published var region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), latitudinalMeters: 1000, longitudinalMeters: 1000)
  func changeStatus(to newStatus: String, reportId: String) async throws {
    do {
      try await ReportManager.instance.changeStatus(to: newStatus, id: reportId)
    } catch {
      print("Error change status:", error.localizedDescription)
    }
  }
}

struct ReportDetailView: View {
  @Environment(\.presentationMode) var presentation
  @State private var changeStatusDialog: Bool = false
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
      
      if viewModel.userRole == "Admin" {
        Section {
          Button("Ubah Status...") {
            changeStatusDialog.toggle()
          }
        }
      }
      
      Section {
        Button(action: {
          
        }, label: {
          Text("Komentar masih kosong")
        })
        .disabled(true)
      } header: {
        HStack {
          Text("Daftar Komentar")
          Spacer()
          Button(action: /*@START_MENU_TOKEN@*/{}/*@END_MENU_TOKEN@*/, label: {
            Text("Tambah Komentar")
              .font(.system(size: 12, weight: .semibold))
          })
        }
      }

    }
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
                        
    .onAppear(perform: {
      self.viewModel.region.center.latitude = data?.lat ?? 0
      self.viewModel.region.center.longitude = data?.long ?? 0
      self.viewModel.coordinate.latitude = data?.lat ?? 0
      self.viewModel.coordinate.longitude = data?.long ?? 0
      Task {
        do {
          let auth = try AuthManager.instance.getAuthUser()
          let result = try await AuthManager.instance.getFSUser(user: auth)
          viewModel.userRole = result.role ?? ""
        } catch {
          print("Error getting user role:", error.localizedDescription)
        }
      }
    })
    .navigationTitle("Detail Laporan")
  }
}

#Preview {
  NavigationStack {
    ReportDetailView(data: ReportModel(date: Date(), id: "123", desc: "Dummy Description", imgFilename: "", imgPath: "", instance: "Suatu Instansi", title: "", userId: "", lat: 0, long: 0, fullname: "SpongeBob SquarePants", status: "Done"))
  }
}


