import SwiftUI

struct HomeSleepScoreCard: View {
    let sleepScore: SleepScore
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Sleep Score")
                    .font(.headline)
                
                Spacer()
                
                Image(systemName: "chevron.right")
                    .foregroundColor(.gray)
            }
            
            HStack(spacing: 20) {
                ZStack {
                    Circle()
                        .stroke(Color(.systemGray4), lineWidth: 8)
                        .frame(width: 80, height: 80)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(sleepScore.score) / 100)
                        .stroke(sleepScore.color, lineWidth: 8)
                        .frame(width: 80, height: 80)
                        .rotationEffect(.degrees(-90))
                    
                    VStack(spacing: 0) {
                        Text("\(sleepScore.score)")
                            .font(.system(size: 24, weight: .bold))
                        
                        Text("%")
                            .font(.system(size: 14, weight: .medium))
                    }
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(sleepScore.label)
                        .font(.title3)
                        .fontWeight(.semibold)
                        .foregroundColor(sleepScore.color)
                    
                    Text("Last night's sleep quality")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                Spacer()
            }
        }
        .padding()
        .background(Color(.systemGray6))
        .cornerRadius(12)
    }
}
