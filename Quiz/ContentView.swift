
import SwiftUI

struct ContentView: View {
    @State private var showSplash = true
    @StateObject private var gameManager = GameManager()
    
    var body: some View {
        ZStack {
            if showSplash {
                SplashScreenView()
                    .transition(.opacity)
            } else {
                MainMenuView()
                    .environmentObject(gameManager)
                    .transition(.opacity)
            }
            
            if let achievement = gameManager.newAchievement {
                AchievementPopupView(achievement: achievement) {
                    gameManager.newAchievement = nil
                }
                .transition(.move(edge: .top).combined(with: .opacity))
                .zIndex(100)
            }
        }
        .animation(.easeInOut(duration: 0.3), value: gameManager.newAchievement != nil)
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 2.5) {
                withAnimation(.easeInOut(duration: 0.5)) {
                    showSplash = false
                }
            }
        }
    }
}

struct AchievementPopupView: View {
    let achievement: Achievement
    let onDismiss: () -> Void
    
    var body: some View {
        VStack {
            HStack(spacing: 16) {
                ZStack {
                    Circle()
                        .fill(achievement.color.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: achievement.icon)
                        .font(.system(size: 24))
                        .foregroundColor(achievement.color)
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("Achievement Unlocked!")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Text(achievement.name)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                Button(action: onDismiss) {
                    Image(systemName: "xmark")
                        .font(.system(size: 14, weight: .bold))
                        .foregroundColor(.white.opacity(0.5))
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(AppTheme.cardBackground)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(achievement.color.opacity(0.5), lineWidth: 2)
                    )
            )
            .shadow(color: achievement.color.opacity(0.3), radius: 20, x: 0, y: 10)
            .padding(.horizontal, 20)
            .padding(.top, 60)
            
            Spacer()
        }
        .onAppear {
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                onDismiss()
            }
        }
    }
}

struct SplashScreenView: View {
    @State private var scale: CGFloat = 0.5
    @State private var opacity: Double = 0
    @State private var rotation: Double = 0
    
    private let ringColors: [Color] = [.blue, .purple, .red, .yellow, .green]
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                ZStack {
                    ForEach(0..<5, id: \.self) { index in
                        Circle()
                            .stroke(
                                LinearGradient(
                                    colors: [ringColors[index].opacity(0.3)],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: 3
                            )
                            .frame(width: CGFloat(100 + index * 30), height: CGFloat(100 + index * 30))
                            .rotationEffect(.degrees(rotation + Double(index * 20)))
                    }
                    
                    Text("🏆")
                        .font(.system(size: 70))
                        .scaleEffect(scale)
                }
                
                VStack(spacing: 10) {
                    Text("SP QUIZ")
                        .font(.system(size: 40, weight: .black, design: .rounded))
                        .foregroundStyle(
                            LinearGradient(
                                colors: [Color(hex: "ffd700"), Color(hex: "ff8c00")],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                    
                    Text("Test your knowledge!")
                        .font(.system(size: 18, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.7))
                }
                .opacity(opacity)
            }
        }
        .onAppear {
            withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
                scale = 1
            }
            withAnimation(.easeIn(duration: 0.8).delay(0.3)) {
                opacity = 1
            }
            withAnimation(.linear(duration: 20).repeatForever(autoreverses: false)) {
                rotation = 360
            }
        }
    }
}

struct MainMenuView: View {
    @EnvironmentObject var gameManager: GameManager
    @State private var selectedCategory: QuizCategory?
    @State private var showingQuiz = false
    @State private var showingSettings = false
    @State private var showingAchievements = false
    @State private var showingDifficultyPicker = false
    @State private var selectedDifficulty: Question.Difficulty = .medium
    @State private var animateCards = false
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient
                    .ignoresSafeArea()
                
                GeometryReader { geo in
                    ZStack {
                        Circle()
                            .fill(Color.purple.opacity(0.1))
                            .frame(width: 300, height: 300)
                            .blur(radius: 60)
                            .offset(x: -100, y: -200)
                        
                        Circle()
                            .fill(Color.blue.opacity(0.1))
                            .frame(width: 250, height: 250)
                            .blur(radius: 50)
                            .offset(x: geo.size.width - 100, y: geo.size.height - 300)
                    }
                }
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 24) {
                        HStack {
                            VStack(alignment: .leading, spacing: 4) {
                                Text("SP QUIZ")
                                    .font(.system(size: 32, weight: .black, design: .rounded))
                                    .foregroundStyle(
                                        LinearGradient(
                                            colors: [Color(hex: "ffd700"), Color(hex: "ff8c00")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                
                                Text("\(QuizData.categories.count) categories • \(totalQuestions) questions")
                                    .font(.system(size: 14, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                            
                            Spacer()
                            
                            HStack(spacing: 12) {
                                Button(action: { showingAchievements = true }) {
                                    ZStack(alignment: .topTrailing) {
                                        Image(systemName: "trophy.fill")
                                            .font(.system(size: 22))
                                            .foregroundColor(Color(hex: "ffd700"))
                                            .padding(12)
                                            .background(Color.white.opacity(0.1))
                                            .clipShape(Circle())
                                        
                                        if !gameManager.unlockedAchievements.isEmpty {
                                            Text("\(gameManager.unlockedAchievements.count)")
                                                .font(.system(size: 10, weight: .bold))
                                                .foregroundColor(.white)
                                                .padding(4)
                                                .background(Color.red)
                                                .clipShape(Circle())
                                                .offset(x: 4, y: -4)
                                        }
                                    }
                                }
                                
                                Button(action: { showingSettings = true }) {
                                    Image(systemName: "gearshape.fill")
                                        .font(.system(size: 22))
                                        .foregroundColor(.white.opacity(0.7))
                                        .padding(12)
                                        .background(Color.white.opacity(0.1))
                                        .clipShape(Circle())
                                }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.top, 20)
                        
                        PlayerStatsCard()
                            .padding(.horizontal)
                        
                        DifficultySelector(selectedDifficulty: $selectedDifficulty)
                            .padding(.horizontal)
                        
                        HStack {
                            Text("Choose a category")
                                .font(.system(size: 20, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                            
                            Spacer()
                        }
                        .padding(.horizontal)
                        
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(Array(QuizData.categories.enumerated()), id: \.element.id) { index, category in
                                CategoryCardView(category: category, difficulty: selectedDifficulty)
                                    .scaleEffect(animateCards ? 1 : 0.8)
                                    .opacity(animateCards ? 1 : 0)
                                    .animation(
                                        .spring(response: 0.5, dampingFraction: 0.7)
                                        .delay(Double(index) * 0.05),
                                        value: animateCards
                                    )
                                    .onTapGesture {
                                        selectedCategory = category
                                        showingQuiz = true
                                    }
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 30)
                    }
                }
            }
            .navigationDestination(isPresented: $showingQuiz) {
                if let category = selectedCategory {
                    QuizView(category: category, difficulty: selectedDifficulty)
                        .environmentObject(gameManager)
                }
            }
            .sheet(isPresented: $showingSettings) {
                SettingsView()
                    .environmentObject(gameManager)
            }
            .sheet(isPresented: $showingAchievements) {
                AchievementsView()
                    .environmentObject(gameManager)
            }
        }
        .onAppear {
            withAnimation {
                animateCards = true
            }
        }
    }
    
    var totalQuestions: Int {
        QuizData.categories.reduce(0) { $0 + $1.questions.count }
    }
}

struct PlayerStatsCard: View {
    @EnvironmentObject var gameManager: GameManager
    
    var body: some View {
        HStack(spacing: 0) {
            StatItemView(icon: "star.fill", value: "\(gameManager.totalScore)", label: "Total Score", color: Color(hex: "ffd700"))
            
            Divider()
                .frame(height: 40)
                .background(Color.white.opacity(0.2))
            
            StatItemView(icon: "gamecontroller.fill", value: "\(gameManager.gamesPlayed)", label: "Games", color: .blue)
            
            Divider()
                .frame(height: 40)
                .background(Color.white.opacity(0.2))
            
            StatItemView(icon: "checkmark.circle.fill", value: "\(gameManager.correctAnswers)", label: "Correct", color: .green)
        }
        .padding(.vertical, 20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct DifficultySelector: View {
    @Binding var selectedDifficulty: Question.Difficulty
    
    var body: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("Select Difficulty")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white.opacity(0.8))
            
            HStack(spacing: 12) {
                ForEach(Question.Difficulty.allCases, id: \.self) { difficulty in
                    DifficultyButton(
                        difficulty: difficulty,
                        isSelected: selectedDifficulty == difficulty
                    ) {
                        withAnimation(.spring(response: 0.3)) {
                            selectedDifficulty = difficulty
                        }
                    }
                }
            }
        }
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(Color.white.opacity(0.05))
        )
    }
}

struct DifficultyButton: View {
    let difficulty: Question.Difficulty
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: difficultyIcon)
                    .font(.system(size: 24))
                
                Text(difficulty.rawValue)
                    .font(.system(size: 12, weight: .bold))
                
                Text("+\(difficulty.points) pts")
                    .font(.system(size: 10, weight: .medium))
                    .opacity(0.7)
            }
            .foregroundColor(isSelected ? .white : difficulty.color)
            .frame(maxWidth: .infinity)
            .padding(.vertical, 16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(isSelected ? difficulty.color : difficulty.color.opacity(0.2))
            )
            .overlay(
                RoundedRectangle(cornerRadius: 16)
                    .stroke(difficulty.color, lineWidth: isSelected ? 0 : 2)
            )
        }
    }
    
    var difficultyIcon: String {
        switch difficulty {
        case .easy: return "leaf.fill"
        case .medium: return "flame.fill"
        case .hard: return "bolt.fill"
        }
    }
}

struct StatItemView: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

struct CategoryCardView: View {
    let category: QuizCategory
    let difficulty: Question.Difficulty
    @State private var isPressed = false
    
    var questionsCount: Int {
        category.questions.filter { $0.difficulty == difficulty }.count
    }
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(
                        LinearGradient(
                            colors: category.gradient,
                            startPoint: .topLeading,
                            endPoint: .bottomTrailing
                        )
                    )
                    .frame(width: 70, height: 70)
                    .shadow(color: category.color.opacity(0.5), radius: 10, x: 0, y: 5)
                
                Text(category.icon)
                    .font(.system(size: 35))
            }
            
            VStack(spacing: 4) {
                Text(category.name)
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                
                Text("\(questionsCount) questions")
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.6))
            }
            
            HStack(spacing: 4) {
                Circle()
                    .fill(difficulty.color)
                    .frame(width: 8, height: 8)
                
                Text(difficulty.rawValue)
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(difficulty.color)
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 4)
            .background(
                Capsule()
                    .fill(difficulty.color.opacity(0.2))
            )
        }
        .padding(.vertical, 20)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(
                            LinearGradient(
                                colors: [category.color.opacity(0.5), category.color.opacity(0.1)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            lineWidth: 1
                        )
                )
        )
        .shadow(color: category.color.opacity(0.2), radius: 15, x: 0, y: 10)
        .scaleEffect(isPressed ? 0.95 : 1)
        .animation(.spring(response: 0.3, dampingFraction: 0.6), value: isPressed)
        .onLongPressGesture(minimumDuration: .infinity, pressing: { pressing in
            isPressed = pressing
        }, perform: {})
    }
}

struct QuizView: View {
    let category: QuizCategory
    let difficulty: Question.Difficulty
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var currentQuestionIndex = 0
    @State private var selectedAnswer: Int?
    @State private var isAnswered = false
    @State private var score = 0
    @State private var correctAnswers = 0
    @State private var showResult = false
    @State private var timeRemaining = 30
    @State private var timer: Timer?
    @State private var animateQuestion = false
    @State private var shuffledQuestions: [Question] = []
    @State private var fastAnswersCount = 0
    @State private var totalTimeSpent = 0
    
    var currentQuestion: Question? {
        guard !shuffledQuestions.isEmpty, currentQuestionIndex < shuffledQuestions.count else { return nil }
        return shuffledQuestions[currentQuestionIndex]
    }
    
    var progress: Double {
        guard !shuffledQuestions.isEmpty else { return 0 }
        return Double(currentQuestionIndex + 1) / Double(shuffledQuestions.count)
    }
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            if showResult {
                ResultView(
                    category: category,
                    correctAnswers: correctAnswers,
                    totalQuestions: shuffledQuestions.count,
                    score: score
                )
                .environmentObject(gameManager)
            } else if let question = currentQuestion {
                VStack(spacing: 0) {
                    QuizHeaderView(
                        category: category,
                        currentQuestion: currentQuestionIndex + 1,
                        totalQuestions: shuffledQuestions.count,
                        score: score,
                        timeRemaining: timeRemaining,
                        progress: progress,
                        onClose: { dismiss() }
                    )
                    
                    ScrollView(showsIndicators: false) {
                        VStack(spacing: 24) {
                            HStack {
                                DifficultyBadge(difficulty: question.difficulty)
                                Spacer()
                                Text("+\(question.difficulty.points) points")
                                    .font(.system(size: 14, weight: .bold))
                                    .foregroundColor(question.difficulty.color)
                            }
                            .padding(.horizontal)
                            
                            QuestionCardView(question: question.text)
                                .opacity(animateQuestion ? 1 : 0)
                                .offset(y: animateQuestion ? 0 : 20)
                            
                            VStack(spacing: 12) {
                                ForEach(0..<question.options.count, id: \.self) { index in
                                    AnswerButtonView(
                                        text: question.options[index],
                                        index: index,
                                        isSelected: selectedAnswer == index,
                                        isCorrect: index == question.correctAnswer,
                                        isAnswered: isAnswered
                                    )
                                    .opacity(animateQuestion ? 1 : 0)
                                    .offset(y: animateQuestion ? 0 : 20)
                                    .animation(
                                        .spring(response: 0.5, dampingFraction: 0.7)
                                        .delay(Double(index) * 0.1),
                                        value: animateQuestion
                                    )
                                    .onTapGesture {
                                        if !isAnswered {
                                            selectAnswer(index)
                                        }
                                    }
                                }
                            }
                            .padding(.horizontal)
                            
                            if isAnswered {
                                Button(action: nextQuestion) {
                                    HStack {
                                        Text(currentQuestionIndex < shuffledQuestions.count - 1 ? "Next Question" : "Show Results")
                                            .font(.system(size: 18, weight: .bold, design: .rounded))
                                        
                                        Image(systemName: "arrow.right")
                                            .font(.system(size: 16, weight: .bold))
                                    }
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .padding(.vertical, 18)
                                    .background(
                                        LinearGradient(
                                            colors: [Color(hex: "667eea"), Color(hex: "764ba2")],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .cornerRadius(16)
                                    .shadow(color: Color(hex: "667eea").opacity(0.4), radius: 15, x: 0, y: 10)
                                }
                                .padding(.horizontal)
                                .transition(.move(edge: .bottom).combined(with: .opacity))
                            }
                        }
                        .padding(.vertical, 24)
                    }
                }
            } else {
                VStack {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                    Text("Loading...")
                        .font(.system(size: 16, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(.top, 16)
                }
            }
        }
        .navigationBarHidden(true)
        .onAppear {
            setupQuiz()
        }
        .onDisappear {
            timer?.invalidate()
        }
    }
    
    func setupQuiz() {
        let filteredQuestions = category.questions.filter { $0.difficulty == difficulty }
        let count = min(gameManager.questionsPerGame, filteredQuestions.count)
        shuffledQuestions = Array(filteredQuestions.shuffled().prefix(count))
        startTimer()
        withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
            animateQuestion = true
        }
    }
    
    func startTimer() {
        timeRemaining = 30
        timer?.invalidate()
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { _ in
            if timeRemaining > 0 {
                timeRemaining -= 1
            } else {
                timeUp()
            }
        }
    }
    
    func selectAnswer(_ index: Int) {
        guard let question = currentQuestion else { return }
        timer?.invalidate()
        selectedAnswer = index
        isAnswered = true
        
        totalTimeSpent += (30 - timeRemaining)
        
        if timeRemaining >= 25 {
            fastAnswersCount += 1
        }
        
        if index == question.correctAnswer {
            correctAnswers += 1
            score += question.difficulty.points + timeRemaining
        }
        
        if gameManager.vibrationEnabled {
            let generator = UIImpactFeedbackGenerator(style: index == question.correctAnswer ? .light : .heavy)
            generator.impactOccurred()
        }
    }
    
    func timeUp() {
        if !isAnswered {
            isAnswered = true
            if gameManager.vibrationEnabled {
                let generator = UINotificationFeedbackGenerator()
                generator.notificationOccurred(.warning)
            }
        }
    }
    
    func nextQuestion() {
        if currentQuestionIndex < shuffledQuestions.count - 1 {
            withAnimation(.easeOut(duration: 0.2)) {
                animateQuestion = false
            }
            
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                currentQuestionIndex += 1
                selectedAnswer = nil
                isAnswered = false
                startTimer()
                
                withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                    animateQuestion = true
                }
            }
        } else {
            timer?.invalidate()
            gameManager.recordGameResult(
                correct: correctAnswers,
                total: shuffledQuestions.count,
                score: score,
                fastCount: fastAnswersCount,
                categoryName: category.name,
                timeSpent: totalTimeSpent
            )
            withAnimation(.spring()) {
                showResult = true
            }
        }
    }
}

struct QuizHeaderView: View {
    let category: QuizCategory
    let currentQuestion: Int
    let totalQuestions: Int
    let score: Int
    let timeRemaining: Int
    let progress: Double
    let onClose: () -> Void
    
    var body: some View {
        VStack(spacing: 16) {
            HStack {
                Button(action: onClose) {
                    Image(systemName: "xmark")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white.opacity(0.7))
                        .padding(12)
                        .background(Color.white.opacity(0.1))
                        .clipShape(Circle())
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Text(category.icon)
                        .font(.system(size: 20))
                    Text(category.name)
                        .font(.system(size: 16, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                }
                
                Spacer()
                
                HStack(spacing: 4) {
                    Image(systemName: "clock.fill")
                        .font(.system(size: 14))
                    Text("\(timeRemaining)")
                        .font(.system(size: 16, weight: .bold, design: .monospaced))
                }
                .foregroundColor(timeRemaining <= 10 ? .red : .white)
                .padding(.horizontal, 12)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(timeRemaining <= 10 ? Color.red.opacity(0.2) : Color.white.opacity(0.1))
                )
            }
            
            VStack(spacing: 8) {
                HStack {
                    Text("Question \(currentQuestion) of \(totalQuestions)")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.white.opacity(0.7))
                    
                    Spacer()
                    
                    HStack(spacing: 4) {
                        Image(systemName: "star.fill")
                            .foregroundColor(AppTheme.goldColor)
                        Text("\(score)")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.2))
                            .frame(height: 8)
                        
                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: category.gradient,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progress, height: 8)
                            .animation(.spring(response: 0.5), value: progress)
                    }
                }
                .frame(height: 8)
            }
        }
        .padding()
        .background(
            Rectangle()
                .fill(Color.black.opacity(0.2))
        )
    }
}

struct DifficultyBadge: View {
    let difficulty: Question.Difficulty
    
    var body: some View {
        HStack(spacing: 4) {
            Circle()
                .fill(difficulty.color)
                .frame(width: 8, height: 8)
            
            Text(difficulty.rawValue)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(difficulty.color)
        }
        .padding(.horizontal, 12)
        .padding(.vertical, 6)
        .background(
            Capsule()
                .fill(difficulty.color.opacity(0.2))
        )
    }
}

struct QuestionCardView: View {
    let question: String
    
    var body: some View {
        VStack {
            Text(question)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.center)
                .lineSpacing(4)
        }
        .padding(24)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 24)
                .fill(AppTheme.cardBackground)
                .overlay(
                    RoundedRectangle(cornerRadius: 24)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
        )
        .padding(.horizontal)
    }
}

struct AnswerButtonView: View {
    let text: String
    let index: Int
    let isSelected: Bool
    let isCorrect: Bool
    let isAnswered: Bool
    
    var backgroundColor: Color {
        if !isAnswered {
            return isSelected ? Color.white.opacity(0.2) : AppTheme.cardBackground
        }
        if isCorrect {
            return Color.green.opacity(0.3)
        }
        if isSelected && !isCorrect {
            return Color.red.opacity(0.3)
        }
        return AppTheme.cardBackground
    }
    
    var borderColor: Color {
        if !isAnswered {
            return isSelected ? Color.white.opacity(0.5) : Color.white.opacity(0.1)
        }
        if isCorrect {
            return Color.green
        }
        if isSelected && !isCorrect {
            return Color.red
        }
        return Color.white.opacity(0.1)
    }
    
    var iconName: String? {
        if !isAnswered { return nil }
        if isCorrect { return "checkmark.circle.fill" }
        if isSelected && !isCorrect { return "xmark.circle.fill" }
        return nil
    }
    
    let letters = ["A", "B", "C", "D"]
    
    var body: some View {
        HStack(spacing: 16) {
            Text(letters[index])
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .frame(width: 36, height: 36)
                .background(
                    Circle()
                        .fill(
                            isAnswered && isCorrect ? Color.green :
                            isAnswered && isSelected && !isCorrect ? Color.red :
                            Color.white.opacity(0.2)
                        )
                )
            
            Text(text)
                .font(.system(size: 16, weight: .medium, design: .rounded))
                .foregroundColor(.white)
                .multilineTextAlignment(.leading)
            
            Spacer()
            
            if let icon = iconName {
                Image(systemName: icon)
                    .font(.system(size: 24))
                    .foregroundColor(isCorrect ? .green : .red)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity, alignment: .leading)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(backgroundColor)
                .overlay(
                    RoundedRectangle(cornerRadius: 16)
                        .stroke(borderColor, lineWidth: 2)
                )
        )
        .scaleEffect(isSelected && !isAnswered ? 0.98 : 1)
        .animation(.spring(response: 0.3), value: isSelected)
    }
}

struct ResultView: View {
    let category: QuizCategory
    let correctAnswers: Int
    let totalQuestions: Int
    let score: Int
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var animateScore = false
    @State private var showConfetti = false
    
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
    
    var gradeColor: Color {
        switch percentage {
        case 90...100: return AppTheme.goldColor
        case 70..<90: return Color.green
        case 50..<70: return Color.blue
        case 30..<50: return AppTheme.bronzeColor
        default: return Color.gray
        }
    }
    
    var body: some View {
        ZStack {
            AppTheme.backgroundGradient
                .ignoresSafeArea()
            
            if showConfetti && percentage >= 70 {
                ConfettiView()
            }
            
            ScrollView(showsIndicators: false) {
                VStack(spacing: 32) {
                    ZStack {
                        Circle()
                            .fill(
                                RadialGradient(
                                    colors: [gradeColor.opacity(0.3), gradeColor.opacity(0)],
                                    center: .center,
                                    startRadius: 0,
                                    endRadius: 100
                                )
                            )
                            .frame(width: 200, height: 200)
                        
                        Text(percentage >= 70 ? "🏆" : percentage >= 50 ? "🎯" : "📚")
                            .font(.system(size: 80))
                            .scaleEffect(animateScore ? 1 : 0.5)
                            .animation(.spring(response: 0.6, dampingFraction: 0.5), value: animateScore)
                    }
                    
                    VStack(spacing: 8) {
                        Text(grade)
                            .font(.system(size: 36, weight: .black, design: .rounded))
                            .foregroundColor(gradeColor)
                        
                        Text("Quiz Completed")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(.white.opacity(0.7))
                    }
                    
                    VStack(spacing: 24) {
                        ZStack {
                            Circle()
                                .stroke(Color.white.opacity(0.1), lineWidth: 12)
                                .frame(width: 150, height: 150)
                            
                            Circle()
                                .trim(from: 0, to: animateScore ? CGFloat(percentage / 100) : 0)
                                .stroke(
                                    LinearGradient(
                                        colors: category.gradient,
                                        startPoint: .topLeading,
                                        endPoint: .bottomTrailing
                                    ),
                                    style: StrokeStyle(lineWidth: 12, lineCap: .round)
                                )
                                .frame(width: 150, height: 150)
                                .rotationEffect(.degrees(-90))
                                .animation(.spring(response: 1, dampingFraction: 0.8).delay(0.3), value: animateScore)
                            
                            VStack(spacing: 4) {
                                Text("\(Int(percentage))%")
                                    .font(.system(size: 36, weight: .black, design: .rounded))
                                    .foregroundColor(.white)
                                
                                Text("accuracy")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white.opacity(0.6))
                            }
                        }
                        
                        HStack(spacing: 0) {
                            ResultStatView(
                                icon: "checkmark.circle.fill",
                                value: "\(correctAnswers)",
                                label: "Correct",
                                color: .green
                            )
                            
                            Divider()
                                .frame(height: 50)
                                .background(Color.white.opacity(0.2))
                            
                            ResultStatView(
                                icon: "xmark.circle.fill",
                                value: "\(totalQuestions - correctAnswers)",
                                label: "Wrong",
                                color: .red
                            )
                            
                            Divider()
                                .frame(height: 50)
                                .background(Color.white.opacity(0.2))
                            
                            ResultStatView(
                                icon: "star.fill",
                                value: "\(score)",
                                label: "Points",
                                color: AppTheme.goldColor
                            )
                        }
                    }
                    .padding(24)
                    .background(
                        RoundedRectangle(cornerRadius: 24)
                            .fill(AppTheme.cardBackground)
                            .overlay(
                                RoundedRectangle(cornerRadius: 24)
                                    .stroke(Color.white.opacity(0.1), lineWidth: 1)
                            )
                    )
                    .padding(.horizontal)
                    
                    VStack(spacing: 12) {
                        Button(action: { dismiss() }) {
                            HStack {
                                Image(systemName: "arrow.counterclockwise")
                                    .font(.system(size: 16, weight: .bold))
                                Text("Play Again")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(
                                LinearGradient(
                                    colors: category.gradient,
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .cornerRadius(16)
                            .shadow(color: category.color.opacity(0.4), radius: 15, x: 0, y: 10)
                        }
                        
                        Button(action: { dismiss() }) {
                            HStack {
                                Image(systemName: "house.fill")
                                    .font(.system(size: 16, weight: .bold))
                                Text("Main Menu")
                                    .font(.system(size: 18, weight: .bold, design: .rounded))
                            }
                            .foregroundColor(.white.opacity(0.8))
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 18)
                            .background(Color.white.opacity(0.1))
                            .cornerRadius(16)
                        }
                    }
                    .padding(.horizontal)
                }
                .padding(.vertical, 40)
            }
        }
        .onAppear {
            withAnimation {
                animateScore = true
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                showConfetti = true
            }
        }
    }
}

struct ResultStatView: View {
    let icon: String
    let value: String
    let label: String
    let color: Color
    
    var body: some View {
        VStack(spacing: 8) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(color)
            
            Text(value)
                .font(.system(size: 24, weight: .bold, design: .rounded))
                .foregroundColor(.white)
            
            Text(label)
                .font(.system(size: 11, weight: .medium))
                .foregroundColor(.white.opacity(0.6))
        }
        .frame(maxWidth: .infinity)
    }
}

struct SettingsView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.dismiss) private var dismiss
    @State private var showResetAlert = false
    
    func formatTime(_ seconds: Int) -> String {
        let hours = seconds / 3600
        let minutes = (seconds % 3600) / 60
        if hours > 0 {
            return "\(hours)h \(minutes)m"
        } else {
            return "\(minutes)m"
        }
    }
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        SettingsSection(title: "Game Settings") {
                            VStack(alignment: .leading, spacing: 12) {
                                Text("Questions per Quiz")
                                    .font(.system(size: 16, weight: .medium))
                                    .foregroundColor(.white)
                                
                                HStack(spacing: 12) {
                                    ForEach(GameSettings.questionsOptions, id: \.self) { count in
                                        Button(action: {
                                            gameManager.questionsPerGame = count
                                        }) {
                                            Text("\(count)")
                                                .font(.system(size: 16, weight: .bold))
                                                .foregroundColor(gameManager.questionsPerGame == count ? .white : .white.opacity(0.6))
                                                .frame(width: 50, height: 44)
                                                .background(
                                                    RoundedRectangle(cornerRadius: 12)
                                                        .fill(gameManager.questionsPerGame == count ? Color.purple : Color.white.opacity(0.1))
                                                )
                                        }
                                    }
                                }
                            }
                            
                            Divider()
                                .background(Color.white.opacity(0.1))
                            
                            Toggle(isOn: $gameManager.vibrationEnabled) {
                                HStack(spacing: 12) {
                                    Image(systemName: "iphone.radiowaves.left.and.right")
                                        .foregroundColor(.green)
                                    Text("Haptic Feedback")
                                        .foregroundColor(.white)
                                }
                            }
                            .tint(.purple)
                        }
                        
                        SettingsSection(title: "Your Statistics") {
                            StatRow(icon: "star.fill", title: "Total Score", value: "\(gameManager.totalScore)", color: Color(hex: "ffd700"))
                            StatRow(icon: "gamecontroller.fill", title: "Games Played", value: "\(gameManager.gamesPlayed)", color: .blue)
                            StatRow(icon: "checkmark.circle.fill", title: "Correct Answers", value: "\(gameManager.correctAnswers)", color: .green)
                            StatRow(icon: "medal.fill", title: "Perfect Games", value: "\(gameManager.perfectGames)", color: .mint)
                            StatRow(icon: "flame.fill", title: "Best Streak", value: "\(gameManager.bestStreak)", color: .orange)
                            StatRow(icon: "bolt.fill", title: "Fast Answers", value: "\(gameManager.fastAnswers)", color: .yellow)
                            StatRow(icon: "folder.fill", title: "Categories Played", value: "\(gameManager.categoriesPlayed.count)/22", color: .cyan)
                            StatRow(icon: "clock.fill", title: "Time Played", value: formatTime(gameManager.totalTimePlayed), color: .indigo)
                            StatRow(icon: "trophy.fill", title: "Achievements", value: "\(gameManager.unlockedAchievements.count)/\(Achievement.allAchievements.count)", color: .purple)
                        }
                        
                        Button(action: { showResetAlert = true }) {
                            HStack {
                                Image(systemName: "trash.fill")
                                Text("Reset All Progress")
                            }
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.red)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 16)
                            .background(
                                RoundedRectangle(cornerRadius: 16)
                                    .fill(Color.red.opacity(0.1))
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 16)
                                            .stroke(Color.red.opacity(0.3), lineWidth: 1)
                                    )
                            )
                        }
                        .padding(.horizontal)
                        
                        Text("SP Quiz v1.0")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.white.opacity(0.5))
                            .padding(.top, 20)
                            .padding(.bottom, 40)
                    }
                    .padding(.top, 20)
                }
            }
            .navigationTitle("Settings")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .toolbarBackground(Color.clear, for: .navigationBar)
            .alert("Reset Progress?", isPresented: $showResetAlert) {
                Button("Cancel", role: .cancel) { }
                Button("Reset", role: .destructive) {
                    gameManager.resetProgress()
                }
            } message: {
                Text("This will delete all your scores, achievements, and statistics. This action cannot be undone.")
            }
        }
    }
}

struct SettingsSection<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text(title)
                .font(.system(size: 14, weight: .semibold))
                .foregroundColor(.white.opacity(0.6))
                .padding(.horizontal)
            
            VStack(spacing: 16) {
                content
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color.white.opacity(0.05))
            )
            .padding(.horizontal)
        }
    }
}

struct StatRow: View {
    let icon: String
    let title: String
    let value: String
    let color: Color
    
    var body: some View {
        HStack {
            Image(systemName: icon)
                .foregroundColor(color)
                .frame(width: 30)
            
            Text(title)
                .foregroundColor(.white.opacity(0.8))
            
            Spacer()
            
            Text(value)
                .font(.system(size: 16, weight: .bold))
                .foregroundColor(.white)
        }
    }
}

struct AchievementsView: View {
    @EnvironmentObject var gameManager: GameManager
    @Environment(\.dismiss) private var dismiss
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
        NavigationStack {
            ZStack {
                AppTheme.backgroundGradient
                    .ignoresSafeArea()
                
                ScrollView {
                    VStack(spacing: 24) {
                        VStack(spacing: 12) {
                            ZStack {
                                Circle()
                                    .stroke(Color.white.opacity(0.1), lineWidth: 8)
                                    .frame(width: 120, height: 120)
                                
                                Circle()
                                    .trim(from: 0, to: CGFloat(gameManager.unlockedAchievements.count) / CGFloat(Achievement.allAchievements.count))
                                    .stroke(
                                        LinearGradient(
                                            colors: [Color(hex: "ffd700"), Color(hex: "ff8c00")],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        style: StrokeStyle(lineWidth: 8, lineCap: .round)
                                    )
                                    .frame(width: 120, height: 120)
                                    .rotationEffect(.degrees(-90))
                                
                                VStack(spacing: 2) {
                                    Text("\(gameManager.unlockedAchievements.count)")
                                        .font(.system(size: 32, weight: .black))
                                        .foregroundColor(.white)
                                    
                                    Text("of \(Achievement.allAchievements.count)")
                                        .font(.system(size: 14, weight: .medium))
                                        .foregroundColor(.white.opacity(0.6))
                                }
                            }
                            
                            Text("Achievements Unlocked")
                                .font(.system(size: 18, weight: .bold))
                                .foregroundColor(.white)
                        }
                        .padding(.top, 20)
                        
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(Achievement.allAchievements) { achievement in
                                AchievementCard(
                                    achievement: achievement,
                                    isUnlocked: gameManager.unlockedAchievements.contains(achievement.id)
                                )
                            }
                        }
                        .padding(.horizontal)
                        .padding(.bottom, 40)
                    }
                }
            }
            .navigationTitle("Achievements")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("Done") {
                        dismiss()
                    }
                    .foregroundColor(.white)
                }
            }
            .toolbarBackground(Color.clear, for: .navigationBar)
        }
    }
}

struct AchievementCard: View {
    let achievement: Achievement
    let isUnlocked: Bool
    
    var body: some View {
        VStack(spacing: 12) {
            ZStack {
                Circle()
                    .fill(isUnlocked ? achievement.color.opacity(0.2) : Color.white.opacity(0.05))
                    .frame(width: 60, height: 60)
                
                if isUnlocked {
                    Image(systemName: achievement.icon)
                        .font(.system(size: 28))
                        .foregroundColor(achievement.color)
                } else {
                    Image(systemName: "lock.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.3))
                }
            }
            
            VStack(spacing: 4) {
                Text(achievement.name)
                    .font(.system(size: 14, weight: .bold))
                    .foregroundColor(isUnlocked ? .white : .white.opacity(0.5))
                    .multilineTextAlignment(.center)
                
                Text(achievement.description)
                    .font(.system(size: 11))
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
        }
        .padding(16)
        .frame(maxWidth: .infinity)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(isUnlocked ? achievement.color.opacity(0.1) : Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 20)
                        .stroke(isUnlocked ? achievement.color.opacity(0.3) : Color.white.opacity(0.1), lineWidth: 1)
                )
        )
    }
}

struct ConfettiView: View {
    @State private var confetti: [ConfettiPiece] = []
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                ForEach(confetti) { piece in
                    Text(piece.emoji)
                        .font(.system(size: piece.size))
                        .position(piece.position)
                        .opacity(piece.opacity)
                }
            }
            .onAppear {
                createConfetti(in: geometry.size)
            }
        }
        .allowsHitTesting(false)
    }
    
    func createConfetti(in size: CGSize) {
        let emojis = ["🎉", "🎊", "⭐️", "✨", "🏆", "🥇", "🎯", "💫"]
        
        for _ in 0..<50 {
            let piece = ConfettiPiece(
                emoji: emojis.randomElement()!,
                position: CGPoint(x: CGFloat.random(in: 0...size.width), y: -50),
                size: CGFloat.random(in: 20...40),
                opacity: 1
            )
            confetti.append(piece)
        }
        
        for i in 0..<confetti.count {
            let delay = Double.random(in: 0...1)
            let duration = Double.random(in: 2...4)
            
            withAnimation(.easeOut(duration: duration).delay(delay)) {
                confetti[i].position.y = size.height + 100
                confetti[i].position.x += CGFloat.random(in: -100...100)
            }
            
            withAnimation(.easeIn(duration: duration * 0.5).delay(delay + duration * 0.5)) {
                confetti[i].opacity = 0
            }
        }
    }
}

struct ConfettiPiece: Identifiable {
    let id = UUID()
    let emoji: String
    var position: CGPoint
    let size: CGFloat
    var opacity: Double
}

#Preview {
    ContentView()
}
