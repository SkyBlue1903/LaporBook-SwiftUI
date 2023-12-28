//
//  AddReportView.swift
//  Lapor Book
//
//  Created by Erlangga Anugrah Arifin on 23/12/23.
//

import SwiftUI

@MainActor
final class AddReportViewModel: ObservableObject {
  @Published var judul: String = ""
  @Published var deskripsi: String = ""
  @Published var selected: String = "Jalanan"
  @Published var image: Image? = nil
  @Published var coordinatePoint: (Double, Double) = (0, 0) // Latitude, Longitude
  
  func create(success: @escaping () -> (), failure: @escaping (Error) -> ()) {
    Task {
      do {
        let render = ImageRenderer(content: image!)
        let result = try await StorageManager.instance.saveImage(data: (render.uiImage?.jpegData(compressionQuality: 1))!)
        try await ReportManager.instance.createReport(title: self.judul, instance: self.selected, desc: self.deskripsi, path: result.path, filename: result.filename, lat: self.coordinatePoint.0, long: self.coordinatePoint.1)
        success()
      } catch {
        failure(error)
      }
    }
  }
}

struct AddReportView: View {
  @Binding var isPresented: Bool
  @StateObject private var viewModel = AddReportViewModel()
  @StateObject var location = LocationManager()
  @State private var imageSheetView: Bool = false
  @State private var shouldPresentImagePicker: Bool = false
  @State private var shouldPresentCamera: Bool = false
  
  @FocusState var descFocus: Bool
  
  var instances: [String] = ["Jalanan", "Pembangunan", "Revitalisasi", "Renovasi"]
  var body: some View {
    NavigationStack {
      ScrollView(.vertical, content: {
        VStack(spacing: 16) {
          CustomTextFieldView(fieldBinding: $viewModel.judul, fieldName: "Judul Laporan")
          VStack(alignment: .leading){
            Text("Foto Laporan")
              .fontWeight(.bold)
            
            if let userImage = viewModel.image {
              userImage
                .resizable()
                .scaledToFit()
                .frame(maxWidth: .infinity)
                .frame(height: 300)
                .clipped()
                .overlay(
                  RoundedRectangle(cornerRadius: 14)
                    .stroke(.gray, lineWidth: 2)
                    .opacity(descFocus ? 1 : 0.5)
                )
                .cornerRadius(14)
                .onTapGesture {
                  self.imageSheetView.toggle()
                }
                .sheet(isPresented: $shouldPresentImagePicker) {
                  SUImagePickerView(sourceType: self.shouldPresentCamera ? .camera : .photoLibrary, image: $viewModel.image, isPresented: self.$shouldPresentImagePicker)
                }
                .actionSheet(isPresented: $imageSheetView) { () -> ActionSheet in
                  ActionSheet(title: Text("Pilih Foto"), message: Text("Pilih satu foto sebagai dokumentasi laporan"), buttons: [ActionSheet.Button.default(Text("Kamera"), action: {
                    self.shouldPresentImagePicker = true
                    self.shouldPresentCamera = true
                  }), ActionSheet.Button.default(Text("Galeri..."), action: {
                    self.shouldPresentImagePicker = true
                    self.shouldPresentCamera = false
                  }), ActionSheet.Button.cancel()])
                }
            } else {
              VStack(spacing: 16) {
                Image(systemName: "photo.on.rectangle.angled")
                  .resizable()
                  .aspectRatio(contentMode: .fit)
                  .frame(maxWidth: .infinity)
                  .frame(height: 100)
                  .foregroundColor(.gray)
                
                Text("Tap disini untuk tambah/ganti foto...")
                  .foregroundColor(.gray)
              }
              .frame(maxWidth: .infinity)
              .frame(height: 300)
              .overlay(
                RoundedRectangle(cornerRadius: 14)
                  .stroke(.gray, lineWidth: 2)
                  .opacity(descFocus ? 1 : 0.5)
              )
              .onTapGesture {
                self.imageSheetView.toggle()
              }
              .sheet(isPresented: $shouldPresentImagePicker) {
                SUImagePickerView(sourceType: self.shouldPresentCamera ? .camera : .photoLibrary, image: $viewModel.image, isPresented: self.$shouldPresentImagePicker)
              }
              .actionSheet(isPresented: $imageSheetView) { () -> ActionSheet in
                ActionSheet(title: Text("Pilih Foto"), message: Text("Pilih satu foto sebagai dokumentasi laporan"), buttons: [ActionSheet.Button.default(Text("Kamera"), action: {
                  self.shouldPresentImagePicker = true
                  self.shouldPresentCamera = true
                }), ActionSheet.Button.default(Text("Galeri..."), action: {
                  self.shouldPresentImagePicker = true
                  self.shouldPresentCamera = false
                }), ActionSheet.Button.cancel()])
              }
            }
          }
          VStack(alignment: .leading) {
            Text("Instansi")
              .fontWeight(.bold)
            Picker("Selected Instance", selection: $viewModel.selected) {
              ForEach(instances, id: \.self) { each in
                Text(each)
              }
            }
            .frame(maxWidth: .infinity)
            .pickerStyle(.wheel)
            .overlay(
              RoundedRectangle(cornerRadius: 14)
                .stroke(.gray, lineWidth: 2)
                .opacity(descFocus ? 1 : 0.5)
            )
          }
          
          VStack(alignment: .leading) {
            Text("Deskripsi Laporan")
              .fontWeight(.bold)
            TextField("Deskripsikan laporan Anda di sini...", text: $viewModel.deskripsi, axis: .vertical)
              .frame(height: /*@START_MENU_TOKEN@*/100/*@END_MENU_TOKEN@*/)
              .padding()
              .autocorrectionDisabled()
              .textInputAutocapitalization(.never)
              .keyboardType(.emailAddress)
              .overlay(
                RoundedRectangle(cornerRadius: 14)
                  .stroke(descFocus ? Color(hex: LB.AppColors.textFieldFocused) : .gray, lineWidth: 2)
                  .opacity(descFocus ? 1 : 0.5)
              )
              .focused($descFocus)
          }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal)
      })
      .toolbar(content: {
        ToolbarItem(placement: .topBarLeading) {
          Button(action: {
            self.isPresented.toggle()
          }, label: {
            Text("Batal")
          })
        }
        
        ToolbarItem(placement: .topBarTrailing) {
          Button(action: {
            viewModel.create() {
              self.isPresented.toggle()
            } failure: { err in
              print("Error saving firestore / storage:", err.localizedDescription)
            }
            
          }, label: {
            Text("Tambah")
          })
        }
      })
      .onAppear(perform: {
        viewModel.coordinatePoint.0 = location.locationManager.location?.coordinate.latitude ?? 0
        viewModel.coordinatePoint.1 = location.locationManager.location?.coordinate.longitude ?? 0
      })
      .navigationTitle("Tambah Laporan")
    }
  }
}

#Preview {
  AddReportView(isPresented: .constant(true))
}
