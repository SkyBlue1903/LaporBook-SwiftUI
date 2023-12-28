//
//  Extensions.swift
//  Lapor Book
//
//  Created by Erlangga Anugrah Arifin on 22/12/23.
//

import SwiftUI
import MapKit

// MARK: - Extension of Color
extension Color {
  init(hex: String) {
    var hexSanitized = hex.trimmingCharacters(in: .whitespacesAndNewlines)
    hexSanitized = hexSanitized.replacingOccurrences(of: "#", with: "")
    
    var rgb: UInt64 = 0
    
    Scanner(string: hexSanitized).scanHexInt64(&rgb)
    
    let red = Double((rgb & 0xFF0000) >> 16) / 255.0
    let green = Double((rgb & 0x00FF00) >> 8) / 255.0
    let blue = Double(rgb & 0x0000FF) / 255.0
    
    self.init(red: red, green: green, blue: blue)
  }
}

// MARK: - Extension of String
extension String {
  init(date: Date, format: String) {
    let formatter = DateFormatter()
    formatter.dateFormat = format
    self.init(formatter.string(from: date))
  }
}

// MARK: - Extension of MKCordinateRegion in MapKit framework
extension MKCoordinateRegion {
  ///Identify the length of the span in meters north to south
  var spanLatitude: Measurement<UnitLength>{
    let loc1 = CLLocation(latitude: center.latitude - span.latitudeDelta * 0.5, longitude: center.longitude)
    let loc2 = CLLocation(latitude: center.latitude + span.latitudeDelta * 0.5, longitude: center.longitude)
    let metersInLatitude = loc1.distance(from: loc2)
    return Measurement(value: metersInLatitude, unit: UnitLength.meters)
  }
}
