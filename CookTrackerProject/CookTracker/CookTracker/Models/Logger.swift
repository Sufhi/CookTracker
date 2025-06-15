// MARK: - Imports
import Foundation
import OSLog

/// アプリ用のログシステム
/// - 開発時とプロダクション時で適切なログレベルを提供
/// - OSLogを使用したシステム統合ログ
struct AppLogger {
    
    // MARK: - Log Categories
    private static let subsystem = "com.cooktracker.app"
    
    static let general = Logger(subsystem: subsystem, category: "general")
    static let coreData = Logger(subsystem: subsystem, category: "coredata")
    static let timer = Logger(subsystem: subsystem, category: "timer")
    static let badge = Logger(subsystem: subsystem, category: "badge")
    static let ui = Logger(subsystem: subsystem, category: "ui")
    
    // MARK: - Log Levels
    enum LogLevel {
        case debug
        case info
        case warning
        case error
        case critical
        
        var osLogType: OSLogType {
            switch self {
            case .debug:
                return .debug
            case .info:
                return .info
            case .warning:
                return .default
            case .error:
                return .error
            case .critical:
                return .fault
            }
        }
        
        var emoji: String {
            switch self {
            case .debug:
                return "🐛"
            case .info:
                return "ℹ️"
            case .warning:
                return "⚠️"
            case .error:
                return "❌"
            case .critical:
                return "🚨"
            }
        }
    }
    
    // MARK: - Configuration
    private static var isDebugMode: Bool {
        #if DEBUG
        return true
        #else
        return false
        #endif
    }
    
    // MARK: - Logging Methods
    
    /// 一般的なログ
    static func log(_ message: String, level: LogLevel = .info, category: Logger = general, file: String = #file, function: String = #function, line: Int = #line) {
        let fileName = (file as NSString).lastPathComponent
        let logMessage = "[\(fileName):\(line)] \(function) - \(message)"
        
        if isDebugMode {
            print("\(level.emoji) \(logMessage)")
        }
        
        category.log(level: level.osLogType, "\(logMessage)")
    }
    
    /// Core Data関連のログ
    static func coreDataLog(_ message: String, level: LogLevel = .info, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: level, category: coreData, file: file, function: function, line: line)
    }
    
    /// タイマー関連のログ
    static func timerLog(_ message: String, level: LogLevel = .info, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: level, category: timer, file: file, function: function, line: line)
    }
    
    /// バッジ関連のログ
    static func badgeLog(_ message: String, level: LogLevel = .info, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: level, category: badge, file: file, function: function, line: line)
    }
    
    /// UI関連のログ
    static func uiLog(_ message: String, level: LogLevel = .info, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: level, category: ui, file: file, function: function, line: line)
    }
    
    /// エラーログ（簡潔な使用法）
    static func error(_ message: String, error: Error? = nil, file: String = #file, function: String = #function, line: Int = #line) {
        var logMessage = message
        if let error = error {
            logMessage += " - Error: \(error.localizedDescription)"
        }
        log(logMessage, level: .error, file: file, function: function, line: line)
    }
    
    /// 成功ログ（簡潔な使用法）
    static func success(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log("✅ \(message)", level: .info, file: file, function: function, line: line)
    }
    
    /// 警告ログ（簡潔な使用法）
    static func warning(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        log(message, level: .warning, file: file, function: function, line: line)
    }
    
    /// デバッグログ（デバッグビルドでのみ出力）
    static func debug(_ message: String, file: String = #file, function: String = #function, line: Int = #line) {
        #if DEBUG
        log(message, level: .debug, file: file, function: function, line: line)
        #endif
    }
}

// MARK: - Convenience Extensions
extension AppLogger {
    
    /// Core Data操作の成功ログ
    static func coreDataSuccess(_ operation: String) {
        coreDataLog("✅ \(operation)成功", level: .info)
    }
    
    /// Core Data操作のエラーログ
    static func coreDataError(_ operation: String, error: Error) {
        coreDataLog("❌ \(operation)エラー: \(error.localizedDescription)", level: .error)
    }
    
    /// タイマー操作ログ
    static func timerAction(_ action: String, details: String = "") {
        let message = details.isEmpty ? action : "\(action) - \(details)"
        timerLog("🕐 \(message)", level: .info)
    }
    
    /// バッジ獲得ログ
    static func badgeEarned(_ badgeType: String) {
        badgeLog("🏆 バッジ獲得: \(badgeType)", level: .info)
    }
    
    /// レベルアップログ
    static func levelUp(newLevel: Int, totalXP: Int) {
        log("🎉 レベルアップ！新しいレベル: \(newLevel) (総XP: \(totalXP))", level: .info)
    }
}