import SwiftUI
import Combine

class GameManager: ObservableObject {
    
    @Published var totalScore: Int {
        didSet { UserDefaults.standard.set(totalScore, forKey: "totalScore") }
    }
    @Published var gamesPlayed: Int {
        didSet { UserDefaults.standard.set(gamesPlayed, forKey: "gamesPlayed") }
    }
    @Published var correctAnswers: Int {
        didSet { UserDefaults.standard.set(correctAnswers, forKey: "correctAnswers") }
    }
    @Published var perfectGames: Int {
        didSet { UserDefaults.standard.set(perfectGames, forKey: "perfectGames") }
    }
    @Published var fastAnswers: Int {
        didSet { UserDefaults.standard.set(fastAnswers, forKey: "fastAnswers") }
    }
    @Published var categoriesPlayed: Set<String> {
        didSet { 
            if let encoded = try? JSONEncoder().encode(categoriesPlayed) {
                UserDefaults.standard.set(encoded, forKey: "categoriesPlayed")
            }
        }
    }
    @Published var currentStreak: Int {
        didSet { UserDefaults.standard.set(currentStreak, forKey: "currentStreak") }
    }
    @Published var bestStreak: Int {
        didSet { UserDefaults.standard.set(bestStreak, forKey: "bestStreak") }
    }
    @Published var vibrationEnabled: Bool {
        didSet { UserDefaults.standard.set(vibrationEnabled, forKey: "vibrationEnabled") }
    }
    @Published var questionsPerGame: Int {
        didSet { UserDefaults.standard.set(questionsPerGame, forKey: "questionsPerGame") }
    }
    @Published var totalTimePlayed: Int {
        didSet { UserDefaults.standard.set(totalTimePlayed, forKey: "totalTimePlayed") }
    }
    
    @Published var unlockedAchievements: Set<String> = []
    @Published var newAchievement: Achievement?
    
    init() {
        self.totalScore = UserDefaults.standard.integer(forKey: "totalScore")
        self.gamesPlayed = UserDefaults.standard.integer(forKey: "gamesPlayed")
        self.correctAnswers = UserDefaults.standard.integer(forKey: "correctAnswers")
        self.perfectGames = UserDefaults.standard.integer(forKey: "perfectGames")
        self.fastAnswers = UserDefaults.standard.integer(forKey: "fastAnswers")
        self.currentStreak = UserDefaults.standard.integer(forKey: "currentStreak")
        self.bestStreak = UserDefaults.standard.integer(forKey: "bestStreak")
        self.vibrationEnabled = UserDefaults.standard.object(forKey: "vibrationEnabled") as? Bool ?? true
        self.questionsPerGame = UserDefaults.standard.object(forKey: "questionsPerGame") as? Int ?? 10
        self.totalTimePlayed = UserDefaults.standard.integer(forKey: "totalTimePlayed")
        
        if let data = UserDefaults.standard.data(forKey: "categoriesPlayed"),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
            self.categoriesPlayed = decoded
        } else {
            self.categoriesPlayed = []
        }
        
        loadAchievements()
    }
    
    func loadAchievements() {
        if let data = UserDefaults.standard.data(forKey: "unlockedAchievements"),
           let decoded = try? JSONDecoder().decode(Set<String>.self, from: data) {
            unlockedAchievements = decoded
        }
    }
    
    func saveAchievements() {
        if let encoded = try? JSONEncoder().encode(unlockedAchievements) {
            UserDefaults.standard.set(encoded, forKey: "unlockedAchievements")
        }
    }
    
    func recordGameResult(correct: Int, total: Int, score: Int, fastCount: Int, categoryName: String, timeSpent: Int) {
        gamesPlayed += 1
        correctAnswers += correct
        totalScore += score
        fastAnswers += fastCount
        categoriesPlayed.insert(categoryName)
        totalTimePlayed += timeSpent
        
        if correct == total {
            perfectGames += 1
            currentStreak += 1
            if currentStreak > bestStreak {
                bestStreak = currentStreak
            }
        } else {
            currentStreak = 0
        }
        
        checkAchievements()
    }
    
    func checkAchievements() {
        for achievement in Achievement.allAchievements {
            if !unlockedAchievements.contains(achievement.id) && achievement.isUnlocked(self) {
                unlockAchievement(achievement)
            }
        }
    }
    
    func unlockAchievement(_ achievement: Achievement) {
        unlockedAchievements.insert(achievement.id)
        saveAchievements()
        newAchievement = achievement
        
        if vibrationEnabled {
            let generator = UINotificationFeedbackGenerator()
            generator.notificationOccurred(.success)
        }
    }
    
    func resetProgress() {
        totalScore = 0
        gamesPlayed = 0
        correctAnswers = 0
        perfectGames = 0
        fastAnswers = 0
        categoriesPlayed = []
        currentStreak = 0
        bestStreak = 0
        totalTimePlayed = 0
        unlockedAchievements.removeAll()
        saveAchievements()
    }
}

struct Achievement: Identifiable, Equatable {
    let id: String
    let name: String
    let description: String
    let icon: String
    let color: Color
    let requirement: (GameManager) -> Bool
    
    static func == (lhs: Achievement, rhs: Achievement) -> Bool {
        lhs.id == rhs.id
    }
    
    func isUnlocked(_ manager: GameManager) -> Bool {
        requirement(manager)
    }
    
    static let allAchievements: [Achievement] = [
        Achievement(id: "first_game", name: "First Steps", description: "Complete your first quiz", icon: "figure.walk", color: .green, requirement: { $0.gamesPlayed >= 1 }),
        Achievement(id: "first_perfect", name: "Beginner's Luck", description: "Get your first perfect score", icon: "sparkle", color: .yellow, requirement: { $0.perfectGames >= 1 }),
        Achievement(id: "score_100", name: "Century", description: "Score 100 points in total", icon: "star.fill", color: .yellow, requirement: { $0.totalScore >= 100 }),
        Achievement(id: "score_500", name: "Rising Star", description: "Score 500 points in total", icon: "star.circle.fill", color: .orange, requirement: { $0.totalScore >= 500 }),
        Achievement(id: "score_1000", name: "Superstar", description: "Score 1,000 points in total", icon: "sparkles", color: .purple, requirement: { $0.totalScore >= 1000 }),
        Achievement(id: "score_2500", name: "Champion", description: "Score 2,500 points in total", icon: "medal.fill", color: .blue, requirement: { $0.totalScore >= 2500 }),
        Achievement(id: "score_5000", name: "Legend", description: "Score 5,000 points in total", icon: "crown.fill", color: Color(hex: "ffd700"), requirement: { $0.totalScore >= 5000 }),
        Achievement(id: "score_10000", name: "Mythical", description: "Score 10,000 points in total", icon: "sun.max.fill", color: Color(hex: "ff6b6b"), requirement: { $0.totalScore >= 10000 }),
        Achievement(id: "score_25000", name: "Immortal", description: "Score 25,000 points in total", icon: "bolt.shield.fill", color: Color(hex: "9b59b6"), requirement: { $0.totalScore >= 25000 }),
        Achievement(id: "games_5", name: "Getting Started", description: "Play 5 quizzes", icon: "gamecontroller.fill", color: .blue, requirement: { $0.gamesPlayed >= 5 }),
        Achievement(id: "games_10", name: "Regular Player", description: "Play 10 quizzes", icon: "repeat.circle.fill", color: .cyan, requirement: { $0.gamesPlayed >= 10 }),
        Achievement(id: "games_25", name: "Dedicated Fan", description: "Play 25 quizzes", icon: "heart.fill", color: .red, requirement: { $0.gamesPlayed >= 25 }),
        Achievement(id: "games_50", name: "Quiz Enthusiast", description: "Play 50 quizzes", icon: "flame.fill", color: .orange, requirement: { $0.gamesPlayed >= 50 }),
        Achievement(id: "games_100", name: "Quiz Master", description: "Play 100 quizzes", icon: "trophy.fill", color: Color(hex: "ffd700"), requirement: { $0.gamesPlayed >= 100 }),
        Achievement(id: "games_200", name: "Quiz Addict", description: "Play 200 quizzes", icon: "star.square.fill", color: .purple, requirement: { $0.gamesPlayed >= 200 }),
        Achievement(id: "perfect_3", name: "Triple Perfection", description: "Get 3 perfect quizzes", icon: "checkmark.seal.fill", color: .green, requirement: { $0.perfectGames >= 3 }),
        Achievement(id: "perfect_5", name: "Perfectionist", description: "Get 5 perfect quizzes", icon: "medal.fill", color: .mint, requirement: { $0.perfectGames >= 5 }),
        Achievement(id: "perfect_10", name: "Flawless", description: "Get 10 perfect quizzes", icon: "diamond.fill", color: .teal, requirement: { $0.perfectGames >= 10 }),
        Achievement(id: "perfect_25", name: "Precision Master", description: "Get 25 perfect quizzes", icon: "scope", color: .indigo, requirement: { $0.perfectGames >= 25 }),
        Achievement(id: "perfect_50", name: "Untouchable", description: "Get 50 perfect quizzes", icon: "shield.checkered", color: Color(hex: "e74c3c"), requirement: { $0.perfectGames >= 50 }),
        Achievement(id: "streak_3", name: "Hat Trick", description: "Win 3 perfect quizzes in a row", icon: "flame.fill", color: .orange, requirement: { $0.bestStreak >= 3 }),
        Achievement(id: "streak_5", name: "On Fire!", description: "Win 5 perfect quizzes in a row", icon: "bolt.fill", color: .yellow, requirement: { $0.bestStreak >= 5 }),
        Achievement(id: "streak_7", name: "Lucky Seven", description: "Win 7 perfect quizzes in a row", icon: "7.circle.fill", color: .green, requirement: { $0.bestStreak >= 7 }),
        Achievement(id: "streak_10", name: "Unstoppable", description: "Win 10 perfect quizzes in a row", icon: "burst.fill", color: .red, requirement: { $0.bestStreak >= 10 }),
        Achievement(id: "streak_15", name: "Legendary Streak", description: "Win 15 perfect quizzes in a row", icon: "tornado", color: .purple, requirement: { $0.bestStreak >= 15 }),
        Achievement(id: "streak_20", name: "Unbeatable", description: "Win 20 perfect quizzes in a row", icon: "crown.fill", color: Color(hex: "ffd700"), requirement: { $0.bestStreak >= 20 }),
        Achievement(id: "fast_10", name: "Quick Thinker", description: "Answer 10 questions in under 5 seconds", icon: "hare.fill", color: .cyan, requirement: { $0.fastAnswers >= 10 }),
        Achievement(id: "fast_25", name: "Speedy", description: "Answer 25 questions in under 5 seconds", icon: "gauge.high", color: .blue, requirement: { $0.fastAnswers >= 25 }),
        Achievement(id: "fast_50", name: "Speed Demon", description: "Answer 50 questions in under 5 seconds", icon: "bolt.horizontal.fill", color: .orange, requirement: { $0.fastAnswers >= 50 }),
        Achievement(id: "fast_100", name: "Lightning Fast", description: "Answer 100 questions in under 5 seconds", icon: "hurricane", color: .purple, requirement: { $0.fastAnswers >= 100 }),
        Achievement(id: "fast_250", name: "Time Lord", description: "Answer 250 questions in under 5 seconds", icon: "timer", color: Color(hex: "e74c3c"), requirement: { $0.fastAnswers >= 250 }),
        Achievement(id: "correct_25", name: "Learner", description: "Answer 25 questions correctly", icon: "lightbulb.fill", color: .yellow, requirement: { $0.correctAnswers >= 25 }),
        Achievement(id: "correct_50", name: "Knowledge Seeker", description: "Answer 50 questions correctly", icon: "book.fill", color: .brown, requirement: { $0.correctAnswers >= 50 }),
        Achievement(id: "correct_100", name: "Scholar", description: "Answer 100 questions correctly", icon: "graduationcap.fill", color: .indigo, requirement: { $0.correctAnswers >= 100 }),
        Achievement(id: "correct_250", name: "Expert", description: "Answer 250 questions correctly", icon: "brain.head.profile", color: .pink, requirement: { $0.correctAnswers >= 250 }),
        Achievement(id: "correct_500", name: "Professor", description: "Answer 500 questions correctly", icon: "books.vertical.fill", color: .purple, requirement: { $0.correctAnswers >= 500 }),
        Achievement(id: "correct_1000", name: "Genius", description: "Answer 1,000 questions correctly", icon: "atom", color: Color(hex: "3498db"), requirement: { $0.correctAnswers >= 1000 }),
        Achievement(id: "categories_3", name: "Explorer", description: "Play quizzes in 3 different categories", icon: "map.fill", color: .green, requirement: { $0.categoriesPlayed.count >= 3 }),
        Achievement(id: "categories_5", name: "Adventurer", description: "Play quizzes in 5 different categories", icon: "safari.fill", color: .blue, requirement: { $0.categoriesPlayed.count >= 5 }),
        Achievement(id: "categories_10", name: "Globetrotter", description: "Play quizzes in 10 different categories", icon: "globe.americas.fill", color: .teal, requirement: { $0.categoriesPlayed.count >= 10 }),
        Achievement(id: "categories_15", name: "World Traveler", description: "Play quizzes in 15 different categories", icon: "airplane", color: .cyan, requirement: { $0.categoriesPlayed.count >= 15 }),
        Achievement(id: "categories_all", name: "Sports Guru", description: "Play quizzes in all categories", icon: "figure.run.circle.fill", color: Color(hex: "ffd700"), requirement: { $0.categoriesPlayed.count >= 22 }),
        Achievement(id: "time_30", name: "Half Hour Hero", description: "Play for 30 minutes total", icon: "clock.fill", color: .blue, requirement: { $0.totalTimePlayed >= 1800 }),
        Achievement(id: "time_60", name: "Hour Player", description: "Play for 1 hour total", icon: "hourglass", color: .orange, requirement: { $0.totalTimePlayed >= 3600 }),
        Achievement(id: "time_180", name: "Dedicated", description: "Play for 3 hours total", icon: "hourglass.bottomhalf.filled", color: .purple, requirement: { $0.totalTimePlayed >= 10800 }),
        Achievement(id: "time_300", name: "Marathon Player", description: "Play for 5 hours total", icon: "stopwatch.fill", color: Color(hex: "e74c3c"), requirement: { $0.totalTimePlayed >= 18000 }),
    ]
}

struct GameSettings {
    static let questionsOptions = [5, 10, 15, 20]
}
