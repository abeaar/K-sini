//
//  GuidanceLayer.swift
//  K-sini
//
//  Created by Tiko Aqsa Alif Nugroho on 07/07/26.
//

import SwiftUI
import MapKit

struct GuidanceLayer: MapContent {

    var pathways: [Pathway] = []
    var levelID: String = ""
    var currentPathwayIndex: Int? = nil

    var body: some MapContent {
        if pathways.count > 1 {
            ForEach(0..<(pathways.count - 1), id: \.self) { index in
                let from = pathways[index]
                let to = pathways[index + 1]
                
                if from.levelID == levelID && to.levelID == levelID {
                    let isPassed = currentPathwayIndex != nil && index < currentPathwayIndex!
                    
                    MapPolyline(coordinates: [from.coordinate, to.coordinate])
                    .stroke(
                        isPassed ? .gray : .blue,
                        style: StrokeStyle(lineWidth: 12, lineCap: .round, lineJoin: .round)
                    )
                }
            }
        }

        ForEach(pathways.filter({ $0.levelID == levelID }), id: \.id) { pathway in
            let isFinal = pathway.directions.contains { $0.to.isEmpty }
            let indexInRoute = pathways.firstIndex(where: { $0.id == pathway.id }) ?? 0
            
            let isPassed = currentPathwayIndex != nil && indexInRoute < currentPathwayIndex!
            let isCurrent = currentPathwayIndex != nil && indexInRoute == currentPathwayIndex!
            
            let isFirst = indexInRoute == 0
            let isLast = indexInRoute == pathways.count - 1
            let isPreviewMode = currentPathwayIndex == nil
            
            // "Titik Akhir" (isLast) always prominent, "Titik Awal" (isFirst) only in preview
            let isProminent = isCurrent || isLast || (isPreviewMode && isFirst)
            
            Annotation("", coordinate: pathway.coordinate) {
                ZStack {
                    Circle()
                        .fill(isPassed ? Color.gray : (isFinal ? Color.red : Color.blue))
                        .frame(width: isProminent ? 36 : 24, height: isProminent ? 36 : 24)
                        .overlay(
                            Circle().stroke(Color.white, lineWidth: isProminent ? 3 : 0)
                        )
                    
                    Image(systemName: iconName(for: pathway.category))
                        .font(.system(size: isProminent ? 16 : 12, weight: .bold))
                        .foregroundColor(.white)
                }
                .overlay(alignment: .top) {
                    if isProminent {
                        let labelText = isCurrent ? "You are here" : (isFirst ? "Titik Awal" : "Titik Akhir")
                        let labelColor = (isFinal || (isPreviewMode && isLast)) ? Color.red : Color.blue
                        
                        Text(labelText)
                            .font(.caption)
                            .bold()
                            .fixedSize()
                            .padding(.horizontal, 8)
                            .padding(.vertical, 4)
                            .background(labelColor)
                            .foregroundColor(.white)
                            .clipShape(Capsule())
                            .offset(y: -30)
                    }
                }
            }
        }
    }
    
    private func iconName(for category: String) -> String {
        switch category.lowercased() {
        case "continues": return "figure.walk"
        case "change-level": return "stairs"
        case "ticket-gate": return "creditcard.fill"
        default: return "circle.fill"
        }
    }

}
