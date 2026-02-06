import SwiftUI

struct Question: Identifiable, Hashable {
    let id = UUID()
    let text: String
    let options: [String]
    let correctAnswer: Int
    let difficulty: Difficulty
    
    enum Difficulty: String, CaseIterable {
        case easy = "Easy"
        case medium = "Medium"
        case hard = "Hard"
        
        var color: Color {
            switch self {
            case .easy: return .green
            case .medium: return .orange
            case .hard: return .red
            }
        }
        
        var points: Int {
            switch self {
            case .easy: return 10
            case .medium: return 20
            case .hard: return 30
            }
        }
    }
}

struct QuizCategory: Identifiable, Hashable {
    let id = UUID()
    let name: String
    let icon: String
    let color: Color
    let gradient: [Color]
    let questions: [Question]
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
    static func == (lhs: QuizCategory, rhs: QuizCategory) -> Bool {
        lhs.id == rhs.id
    }
}

struct QuizResult: Identifiable {
    let id = UUID()
    let category: QuizCategory
    let correctAnswers: Int
    let totalQuestions: Int
    let score: Int
    let date: Date
    
    var percentage: Double {
        Double(correctAnswers) / Double(totalQuestions) * 100
    }
    
    var grade: String {
        switch percentage {
        case 90...100: return "🏆 Champion!"
        case 70..<90: return "🥇 Excellent!"
        case 50..<70: return "🥈 Good Job!"
        case 30..<50: return "🥉 Not Bad"
        default: return "💪 Keep Trying!"
        }
    }
}

struct AppTheme {
    static let primaryGradient = LinearGradient(
        colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
        startPoint: .topLeading,
        endPoint: .bottomTrailing
    )
    
    static let backgroundGradient = LinearGradient(
        colors: [Color(hex: "0f0c29"), Color(hex: "302b63"), Color(hex: "24243e")],
        startPoint: .top,
        endPoint: .bottom
    )
    
    static let cardBackground = Color(hex: "1a1a2e")
    static let accentColor = Color(hex: "e94560")
    static let goldColor = Color(hex: "ffd700")
    static let silverColor = Color(hex: "c0c0c0")
    static let bronzeColor = Color(hex: "cd7f32")
}

extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3:
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6:
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8:
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (1, 1, 1, 0)
        }
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue: Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
