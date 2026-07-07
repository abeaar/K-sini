import SwiftUI

struct JourneyHeaderView: View {
    var body: some View {
        
        ZStack(alignment: .top) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Instruction 1")
                        .font(.title)
                        .bold()
                        .foregroundStyle(.primary)
                    
                    Text("Line 2")
                        .font(.title2)
                        .foregroundStyle(.primary)
                }
                Spacer()
            }
            .padding(.top)
            .padding(.horizontal, 24)
            .padding(.bottom, 24)
            .background(Color(.systemBackground))
            
            .overlay(alignment: .bottomTrailing) {
                Image(systemName: "map")
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 120, height: 120)
                    .clipShape(Circle())
                    .overlay(
                        Circle()
                            .stroke(Color(.systemBackground), lineWidth: 6)
                    )
                    .offset(x: -24, y: 50)
            }
        }
    }
}

#Preview {
    JourneyHeaderView()
}
