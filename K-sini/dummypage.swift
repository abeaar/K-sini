import SwiftUI
import MapKit

struct DummyPage: View {
    @State private var position: MapCameraPosition = .region(
        MKCoordinateRegion(
            center: CLLocationCoordinate2D(latitude: 3.1578, longitude: 101.7117),
            span: MKCoordinateSpan(latitudeDelta: 0.01, longitudeDelta: 0.01)
        )
    )

    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            Map(position: $position) {
                UserAnnotation()
            }
            .frame(width: 200, height: 200)
            .clipShape(Circle())
            .overlay(
                Circle().stroke(Color.blue, lineWidth: 2)
            )
            .padding(16)
        }
    }
}

#Preview {
    DummyPage()
}
