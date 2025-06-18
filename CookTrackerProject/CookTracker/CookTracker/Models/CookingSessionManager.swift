import Foundation
import SwiftUI
import Combine

/// 調理セッションの状態を全アプリで共有管理するシングルトンマネージャー
/// 単一責任: アプリ全体の調理セッション状態を一元管理
class CookingSessionManager: ObservableObject {
    static let shared = CookingSessionManager()
    
    /// 現在アクティブな調理セッション（アプリ全体で共有）
    @Published var currentSession: CookingSessionTimer?
    
    /// 現在調理中のレシピ情報
    @Published var currentRecipe: Recipe?
    
    /// 共有補助タイマー（アプリ全体で統一）
    @Published var sharedHelperTimer = CookingTimer()
    
    /// Combineの購読を管理
    private var cancellables = Set<AnyCancellable>()
    
    private init() {}
    
    /// 新しい調理セッションを開始
    /// - Parameters:
    ///   - recipe: 調理するレシピ
    /// - Returns: 作成された調理セッションタイマー
    func startCookingSession(for recipe: Recipe) -> CookingSessionTimer {
        // 既存のセッションがある場合は停止
        if let existingSession = currentSession {
            existingSession.finishCooking()
        }
        
        // 既存の購読をクリア
        cancellables.removeAll()
        
        // 新しいセッションを作成して開始
        let newSession = CookingSessionTimer()
        currentSession = newSession
        currentRecipe = recipe
        
        // セッションの変更を監視してUI更新を伝播
        newSession.objectWillChange
            .sink { [weak self] _ in
                DispatchQueue.main.async {
                    self?.objectWillChange.send()
                }
            }
            .store(in: &cancellables)
        
        // 調理を開始
        newSession.startCooking()
        
        print("🔥 CookingSessionManager: セッション開始 - isRunning: \(newSession.isRunning)")
        
        return newSession
    }
    
    /// 調理セッションを終了
    func finishCookingSession() {
        currentSession?.finishCooking()
        currentSession = nil
        currentRecipe = nil
        
        // 購読をクリアしてメモリリークを防ぐ
        cancellables.removeAll()
    }
    
    /// 現在調理中かどうか
    var isCurrentlyCooking: Bool {
        return currentSession?.isRunning == true || currentSession?.isPaused == true
    }
    
    /// 現在のセッション状態テキスト
    var currentSessionStatusText: String {
        guard let session = currentSession else { return "" }
        
        if session.isRunning {
            return "調理中"
        } else if session.isPaused {
            return "一時停止中"
        } else {
            return ""
        }
    }
}