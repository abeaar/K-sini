//
//  JourneySheet.swift
//  K-sini
//
//  Created by  on 10/07/26.
//

import SwiftUI

struct JourneyPageSheet: View {
    
    @Binding var currentDetent: PresentationDetent // tinggi dari sheet
    
    var body: some View {
        
        // if small
        if currentDetent == .height(100) { // placeholder height for small
            // outer
            HStack{
                // left content
                VStack(alignment: .leading){
                    Text("Titik Berikutnya")
                        .font(.callout)
                        .foregroundStyle(.secondary)
                    
                    Text("placeholder") // change with next line instruction
                        .font(.body)
                        .fontWeight(.semibold)
                }
                .padding(.trailing, 60)
                
                Spacer()
                
                // right content
                Button("Lanjut") {
                    // command untuk ke page selanjuntya
                }
                .frame(maxWidth: 80)
                .foregroundColor(.white)
                .padding(15)
                .background(Color("primaryColor"))
                .cornerRadius(50)
                
            }
            .padding(.horizontal, 30)
        }
        
        
        // if tall
        if currentDetent == .height(400) { // placeholder height for large version
            VStack(spacing: 10){
                //text
                HStack{
                    VStack (alignment: .leading){
                        Text("Titik Berikutnya")
                            .font(.callout)
                            .foregroundStyle(.secondary)
                        
                        Text("placeholder") // change with next line instruction
                            .font(.body)
                            .fontWeight(.semibold)
                    }
                    
                    Spacer()
                    
                }
                .padding(.bottom, 10)
                
                // buttons
                Button {
                    // command untuk ke page selanjuntya
                } label: {
                    Text("Lanjut")
                        .fontWeight(.semibold)
                }
                    .frame(maxWidth: .infinity)
                    .foregroundColor(.white)
                    .padding(15)
                    .background(Color("primaryColor"))
                    .cornerRadius(50)
                
                Button {
                    // command untuk buka checkpoint list
                } label: {
                    Text("Detail Perjalanan")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.primary)
                .padding(15)
                .background(Color(.systemGray5))
                .cornerRadius(50)
                
                Button {
                    // command untuk balik ke EndpointsPageView
                } label: {
                    Text("Akhiri Perjalanan")
                        .fontWeight(.semibold)
                }
                .frame(maxWidth: .infinity)
                .foregroundColor(.red)
                .padding(15)
                .cornerRadius(50)
                
            }
            .padding(.horizontal, 20)

            
        }
    }
}

#Preview {
    JourneyPageSheet(
        currentDetent: .constant(.height(400))
    )
}
