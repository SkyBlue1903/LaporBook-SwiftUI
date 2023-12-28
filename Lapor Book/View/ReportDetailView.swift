//
//  ReportDetailView.swift
//  Lapor Book
//
//  Created by Erlangga Anugrah Arifin on 26/12/23.
//

import SwiftUI
import MapKit
import SDWebImageSwiftUI

struct ReportDetailView: View {
  @State private var coordinate: CLLocationCoordinate2D = CLLocationCoordinate2D(latitude: 0, longitude: 0)
  @State private var region: MKCoordinateRegion = MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: 0, longitude: 0), latitudinalMeters: 1000, longitudinalMeters: 1000)
  
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
      NavigationLink(destination: MapKitView(coordinatePoint: CLLocationCoordinate2D(latitude: data?.lat ?? 0, longitude: data?.long ?? 0), region: $region)) {
        HStack {
          Image(systemName: "map.fill")
            .foregroundStyle(.accent)
            .font(.title2)
            .frame(width: 20)
          Text("Lokasi Laporan")
        }
      }
      
      Section {
        Button("Ubah Status...") {
          
        }
      }
      
      Section {
        Button(action: {}, label: {
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
//    .confirmation
    .onAppear(perform: {
      self.region.center.latitude = data?.lat ?? 0
      self.region.center.longitude = data?.long ?? 0
      self.coordinate.latitude = data?.lat ?? 0
      self.coordinate.longitude = data?.long ?? 0
    })
    .navigationTitle("Detail Laporan")
  }
}

#Preview {
  NavigationStack {
    ReportDetailView()
  }
}


