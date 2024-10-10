//
//  JPFMapView.swift
//  SwiftUILearning
//
//  Created by 金鹏飞 on 2024/9/23.
//

import SwiftUI
import MapKit

struct JPFMapView: View{
    @State private var region = MKCoordinateRegion(
        center: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194),
        span: MKCoordinateSpan(latitudeDelta: 0.05, longitudeDelta: 0.05)
    )
    
    let locations = [
        Location(coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), title: "San Francisco"),
        Location(coordinate: CLLocationCoordinate2D(latitude: 34.0522, longitude: -118.2437), title: "Los Angeles"),
        Location(coordinate: CLLocationCoordinate2D(latitude: 40.7128, longitude: -74.0060), title: "New York")
    ]
    
    var body: some View {
        Map {
            Marker("San Francisco City Hall", coordinate: locations[0].coordinate)
                .tint(.orange)
            Marker("San Francisco Public Library", coordinate: locations[1].coordinate)
                .tint(.blue)
            Annotation("Diller Civic Center Playground", coordinate: locations[2].coordinate) {
                ZStack {
                    RoundedRectangle(cornerRadius: 5)
                        .fill(Color.yellow)
                    Text("🛝")
                        .padding(5)
                }.onTapGesture {
                    NSLog("jpf")
                }
            }
        }
        .mapControlVisibility(.hidden)
    }
}


struct Location: Identifiable {
    let id = UUID()
    let coordinate: CLLocationCoordinate2D
    let title: String
    
    static let sample = Location(coordinate: CLLocationCoordinate2D(latitude: 37.7749, longitude: -122.4194), title: "New York")
}

#Preview {
    JPFMapView()
}
