import SwiftUI
import MapKit

struct MapKitView: View {
  @State private var showTitle = true
  var coordinatePoint: CLLocationCoordinate2D
  @Binding var region: MKCoordinateRegion
  let annotations = [CurrentUsersAnnotation()]
  
  var body: some View {
    GeometryReader(content: { geo in
      Map(coordinateRegion: $region, showsUserLocation: true, annotationItems: self.annotations) { _ in
        MapPin(coordinate: coordinatePoint, tint: .red)
      }
    })
    .navigationTitle("Lokasi Laporan")
    .navigationBarTitleDisplayMode(.inline)
  }
}


#Preview {
  NavigationStack {
    MapKitView(coordinatePoint: CLLocationCoordinate2D(latitude: -6.982621126115729, longitude: 110.40859819108337), region: .constant(MKCoordinateRegion(center: CLLocationCoordinate2D(latitude: -6.982621126115729, longitude: 110.40859819108337), latitudinalMeters: 1000, longitudinalMeters: 1000)))
  }
}
struct CurrentUsersAnnotation: Identifiable {
  let id = UUID() // Always unique on map
}
