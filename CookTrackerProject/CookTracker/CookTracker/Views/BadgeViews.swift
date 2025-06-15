// MARK: - Imports
import SwiftUI
import CoreData

// MARK: - Badge Card View
struct BadgeCardView: View {
    let badge: Badge
    let size: BadgeSize
    
    enum BadgeSize {
        case small, medium, large
        
        var dimension: CGFloat {
            switch self {
            case .small: return 60
            case .medium: return 80
            case .large: return 120
            }
        }
        
        var iconSize: CGFloat {
            switch self {
            case .small: return 24
            case .medium: return 32
            case .large: return 48
            }
        }
    }
    
    var body: some View {
        VStack(spacing: size == .large ? 12 : 8) {
            // バッジアイコン
            ZStack {
                // 背景円
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [
                                badge.swiftUIColor.opacity(0.8),
                                badge.swiftUIColor.opacity(0.4)
                            ],
                            center: .topLeading,
                            startRadius: 0,
                            endRadius: size.dimension
                        )
                    )
                    .frame(width: size.dimension, height: size.dimension)
                
                // 境界線（レア度に応じて）
                Circle()
                    .stroke(badge.swiftUIColor, lineWidth: badge.borderWidth)
                    .frame(width: size.dimension, height: size.dimension)
                
                // アイコン
                Image(systemName: badge.iconName)
                    .font(.system(size: size.iconSize, weight: .bold))
                    .foregroundColor(.white)
                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
            }
            
            // バッジ情報（medium, large のみ）
            if size != .small {
                VStack(spacing: 4) {
                    Text(badge.title)
                        .font(size == .large ? .headline : .subheadline)
                        .fontWeight(.semibold)
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.center)
                    
                    if size == .large {
                        Text(badge.badgeDescription)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                            .lineLimit(2)
                        
                        Text(badge.formattedEarnedDate)
                            .font(.caption2)
                            .foregroundColor(.secondary)
                    }
                }
            }
        }
        .frame(maxWidth: size == .large ? 150 : nil)
    }
}

// MARK: - Badge Grid View
struct BadgeGridView: View {
    let badges: [Badge]
    let columns: Int
    let badgeSize: BadgeCardView.BadgeSize
    
    init(badges: [Badge], columns: Int = 3, badgeSize: BadgeCardView.BadgeSize = .medium) {
        self.badges = badges
        self.columns = columns
        self.badgeSize = badgeSize
    }
    
    private var gridColumns: [GridItem] {
        Array(repeating: GridItem(.flexible()), count: columns)
    }
    
    var body: some View {
        LazyVGrid(columns: gridColumns, spacing: 16) {
            ForEach(badges, id: \.id) { badge in
                BadgeCardView(badge: badge, size: badgeSize)
            }
        }
    }
}

// MARK: - Badge Acquisition Animation
struct BadgeAcquisitionView: View {
    let badges: [BadgeType]
    let onComplete: () -> Void
    
    @State private var currentBadgeIndex = 0
    @State private var scale: CGFloat = 0.1
    @State private var opacity: Double = 0
    @State private var sparkleRotation: Double = 0
    @State private var showNextButton = false
    
    var currentBadge: BadgeType? {
        guard currentBadgeIndex < badges.count else { return nil }
        return badges[currentBadgeIndex]
    }
    
    var body: some View {
        ZStack {
            // 背景
            Color.black.opacity(0.8)
                .ignoresSafeArea()
            
            VStack(spacing: 30) {
                if let badge = currentBadge {
                    // バッジ獲得アニメーション
                    VStack(spacing: 20) {
                        // "バッジ獲得！" テキスト
                        Text("バッジ獲得！")
                            .font(.largeTitle)
                            .fontWeight(.bold)
                            .foregroundColor(.yellow)
                            .scaleEffect(scale)
                            .opacity(opacity)
                        
                        // バッジ表示
                        ZStack {
                            // バッジアイコン
                            ZStack {
                                Circle()
                                    .fill(
                                        RadialGradient(
                                            colors: [
                                                Color(red: badge.color.primaryColor.red,
                                                     green: badge.color.primaryColor.green,
                                                     blue: badge.color.primaryColor.blue).opacity(0.8),
                                                Color(red: badge.color.primaryColor.red,
                                                     green: badge.color.primaryColor.green,
                                                     blue: badge.color.primaryColor.blue).opacity(0.4)
                                            ],
                                            center: .topLeading,
                                            startRadius: 0,
                                            endRadius: 80
                                        )
                                    )
                                    .frame(width: 120, height: 120)
                                
                                Image(systemName: badge.iconName)
                                    .font(.system(size: 50, weight: .bold))
                                    .foregroundColor(.white)
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                            }
                            .scaleEffect(scale)
                            .opacity(opacity)
                            
                            // キラキラエフェクト
                            ForEach(0..<8, id: \.self) { index in
                                Image(systemName: "sparkle")
                                    .font(.title2)
                                    .foregroundColor(.yellow)
                                    .offset(
                                        x: cos(Double(index) * .pi / 4) * 100,
                                        y: sin(Double(index) * .pi / 4) * 100
                                    )
                                    .rotationEffect(.degrees(sparkleRotation))
                                    .opacity(opacity * 0.8)
                            }
                        }
                        
                        // バッジ情報
                        VStack(spacing: 8) {
                            Text(badge.title)
                                .font(.title2)
                                .fontWeight(.bold)
                                .foregroundColor(.white)
                            
                            Text(badge.description)
                                .font(.body)
                                .foregroundColor(.white.opacity(0.8))
                                .multilineTextAlignment(.center)
                                .padding(.horizontal)
                        }
                        .scaleEffect(scale)
                        .opacity(opacity)
                    }
                    
                    // 次へ・完了ボタン
                    if showNextButton {
                        Button(action: {
                            nextBadge()
                        }) {
                            Text(currentBadgeIndex < badges.count - 1 ? "次へ" : "完了")
                                .font(.headline)
                                .fontWeight(.semibold)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(
                                    RoundedRectangle(cornerRadius: 12)
                                        .fill(Color.blue)
                                )
                                .padding(.horizontal, 40)
                        }
                        .transition(.opacity)
                    }
                }
            }
        }
        .onAppear {
            showBadgeAnimation()
        }
    }
    
    private func showBadgeAnimation() {
        // アニメーション開始
        withAnimation(.spring(response: 0.8, dampingFraction: 0.6)) {
            scale = 1.0
            opacity = 1.0
        }
        
        // キラキラ回転アニメーション
        withAnimation(.linear(duration: 3).repeatForever(autoreverses: false)) {
            sparkleRotation = 360
        }
        
        // 2秒後に次へボタン表示
        DispatchQueue.main.asyncAfter(deadline: .now() + 2) {
            withAnimation(.easeInOut(duration: 0.5)) {
                showNextButton = true
            }
        }
    }
    
    private func nextBadge() {
        if currentBadgeIndex < badges.count - 1 {
            // 次のバッジへ
            currentBadgeIndex += 1
            resetAnimation()
            showBadgeAnimation()
        } else {
            // 完了
            onComplete()
        }
    }
    
    private func resetAnimation() {
        scale = 0.1
        opacity = 0
        showNextButton = false
    }
}

// MARK: - Badge List View
struct BadgeListView: View {
    let user: User
    @StateObject private var badgeSystem = BadgeSystem.shared
    @State private var userBadges: [Badge] = []
    
    var body: some View {
        ScrollView {
            VStack(spacing: 24) {
                // ヘッダー
                VStack(spacing: 8) {
                    Text("獲得バッジ")
                        .font(.title2)
                        .fontWeight(.bold)
                    
                    Text("\(userBadges.count) / \(BadgeType.allCases.count) 個獲得")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                }
                
                // バッジ一覧
                if userBadges.isEmpty {
                    // 空の状態
                    VStack(spacing: 16) {
                        Image(systemName: "trophy")
                            .font(.system(size: 60))
                            .foregroundColor(.brown.opacity(0.5))
                        
                        Text("まだバッジがありません")
                            .font(.headline)
                            .fontWeight(.medium)
                        
                        Text("料理を作ってバッジを獲得しましょう！")
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                    .padding()
                } else {
                    // バッジグリッド
                    BadgeGridView(badges: userBadges, columns: 3, badgeSize: .medium)
                        .padding()
                }
                
                // 未獲得バッジのプレビュー
                unavailableBadgesSection
            }
        }
        .onAppear {
            loadUserBadges()
        }
    }
    
    @ViewBuilder
    private var unavailableBadgesSection: some View {
        VStack(alignment: .leading, spacing: 16) {
            Text("未獲得バッジ")
                .font(.headline)
                .fontWeight(.semibold)
                .padding(.horizontal)
            
            let unavailableBadges = BadgeType.allCases.filter { badgeType in
                !userBadges.contains { $0.badgeTypeEnum == badgeType }
            }
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 3), spacing: 16) {
                ForEach(unavailableBadges, id: \.self) { badgeType in
                    VStack(spacing: 8) {
                        ZStack {
                            Circle()
                                .fill(Color.gray.opacity(0.2))
                                .frame(width: 80, height: 80)
                            
                            Circle()
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                                .frame(width: 80, height: 80)
                            
                            Image(systemName: badgeType.iconName)
                                .font(.system(size: 32, weight: .bold))
                                .foregroundColor(.gray.opacity(0.5))
                        }
                        
                        Text(badgeType.title)
                            .font(.caption)
                            .foregroundColor(.secondary)
                            .multilineTextAlignment(.center)
                    }
                }
            }
            .padding(.horizontal)
        }
    }
    
    private func loadUserBadges() {
        userBadges = badgeSystem.getUserBadges(user: user)
    }
}

// MARK: - Preview
struct BadgeViews_Previews: PreviewProvider {
    static var previews: some View {
        Group {
            // Badge Card Preview
            BadgeCardPreview()
                .previewDisplayName("Badge Card")
            
            // Badge Acquisition Preview
            BadgeAcquisitionView(badges: [.firstCook, .streak3]) {
                print("バッジアニメーション完了")
            }
            .previewDisplayName("Badge Acquisition")
        }
    }
}

// MARK: - Preview Helper
struct BadgeCardPreview: View {
    var body: some View {
        let context = PersistenceController.preview.container.viewContext
        let badge = Badge(context: context)
        badge.badgeType = BadgeType.firstCook.rawValue
        badge.earnedAt = Date()
        
        return BadgeCardView(badge: badge, size: .large)
            .environment(\.managedObjectContext, context)
    }
}