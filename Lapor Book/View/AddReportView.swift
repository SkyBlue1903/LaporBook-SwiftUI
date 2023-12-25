//
//  AddReportView.swift
//  Lapor Book
//
//  Created by Erlangga Anugrah Arifin on 23/12/23.
//

import SwiftUI

extension UIImage {
  convenience init?(view: SwiftUI.Image) {
    let size = CGSize(width: 100, height: 100)  // Set a size for the image, adjust as needed
    let controller = UIHostingController(rootView: view.frame(width: size.width, height: size.height))
    
    let renderer = UIGraphicsImageRenderer(size: size)
    
    let image = renderer.image { _ in
      controller.view.drawHierarchy(in: controller.view.bounds, afterScreenUpdates: true)
    }
    
    self.init(cgImage: image.cgImage!)
  }
}

@MainActor
final class AddReportViewModel: ObservableObject {
  @Published var judul: String = ""
  @Published var deskripsi: String = ""
  @Published var selected: String = "Jalanan"
  @Published var image: Image? = Image("sample")
  
  func create(judul: String, deskripsi: String, instansi: String, success: @escaping () -> (), failure: @escaping (Error) -> ()) {
    Task {
      do {
        //        if let uiImage = UIImage(view: image!) {
        //          if let data = uiImage.jpegData(compressionQuality: 0.8) {
        //
        //            try await StorageManager.instance.saveImage(data: data)
        ////            try await ReportManager.instance.createReport(title: judul, instance: instansi, desc: deskripsi)
        //            success()
        //          }
        //        }
        
        let render = ImageRenderer(content: image!)
        let result = try await StorageManager.instance.saveImage(data: (render.uiImage?.jpegData(compressionQuality: 1))!)
        try await ReportManager.instance.createReport(title: self.judul, instance: self.selected, desc: self.deskripsi, path: result.path, filename: result.filename)
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
          
          //            VStack(alignment: .leading) {
          //              Text("Foto Pendukung")
          //                .fontWeight(.bold)
          //              Spacer()
          ////              ZStack {
          ////                image!
          ////                  .resizable()
          ////                  .aspectRatio(contentMode: .fill)
          ////                  .clipped()
          ////              }
          //              .frame(maxWidth: .infinity)
          //              .frame(height: 200)
          //              .overlay(
          //                RoundedRectangle(cornerRadius: 14)
          //                  .stroke(descFocus ? Color(hex: LB.AppColors.textFieldFocused) : .gray, lineWidth: 2)
          //                  .opacity(descFocus ? 1 : 0.5)
          //              )
          //            }
          
          
          VStack(alignment: .leading){
            Text("Foto Laporan")
              .fontWeight(.bold)
            viewModel.image!
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
          //            .border(/*@START_MENU_TOKEN@*/Color.black/*@END_MENU_TOKEN@*/)
          
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
            viewModel.create(judul: viewModel.judul, deskripsi: viewModel.deskripsi, instansi: viewModel.selected) {
              self.isPresented.toggle()
            } failure: { err in
              print("Error saving firestore / storage:", err.localizedDescription)
            }
            
          }, label: {
            Text("Tambah")
          })
        }
      })
      .navigationTitle("Tambah Laporan")
    }
  }
}

#Preview {
  AddReportView(isPresented: .constant(true))
}
