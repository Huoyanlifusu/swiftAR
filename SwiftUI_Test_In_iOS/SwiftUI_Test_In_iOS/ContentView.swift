//
//  ContentView.swift
//  SwiftUI_Test_In_iOS
//
//  Created by 张裕阳 on 2023/2/25.
//

import SwiftUI
import MapKit

struct ContentView: View {
    @State private var isOn: Bool = false
    @State private var region = MKCoordinateRegion(center:
                                                    CLLocationCoordinate2D(latitude: 37.334_900,
                                                                           longitude: -122.009_020),
                                                   latitudinalMeters: 300,
                                                   longitudinalMeters: 300)
    
    var body: some View {
        VStack {
            Image(systemName: "globe")
                .imageScale(.large)
                .foregroundColor(.accentColor)
            Toggle(isOn: $isOn) {
                Text("hello world")
                    .bold()
                    .italic()
            }
            Map(coordinateRegion: $region)
            Button(action: {
            }) {
                Text("click me")
                }
                .foregroundColor(.brown)
                
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
