// MARK: - Imports
import SwiftUI

/// 調理タイマーのメイン画面
/// - 直感的なタイマー操作
/// - プログレスサークル表示
/// - クイック時間設定
struct CookingTimerView: View {
    
    // MARK: - Properties
    @ObservedObject var timer: CookingTimer
    @Environment(\.dismiss) private var dismiss
    @State private var selectedMinutes = 10
    @State private var showingTimePicker = false
    @State private var showingCompletionView = false
    
    private let quickTimes = [5, 10, 15, 20, 30, 45, 60]
    
    // MARK: - Body
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // メインタイマー表示
                timerDisplaySection
                
                // 進捗インジケーター
                progressSection
                
                // クイック時間設定
                if !timer.isRunning && timer.timeRemaining == 0 {
                    quickTimeSection
                }
                
                // 時間設定ボタン
                if !timer.isRunning && timer.timeRemaining == 0 {
                    customTimeButton
                }
                
                Spacer()
                
                // コントロールボタン
                controlButtonsSection
                
                Spacer()
            }
            .padding()
            .navigationTitle("調理タイマー")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("閉じる") {
                        if timer.isRunning {
                            timer.stopTimer()
                        }
                        dismiss()
                    }
                }
            }
            .onChange(of: timer.isFinished) { isFinished in
                if isFinished {
                    showingCompletionView = true
                }
            }
            .sheet(isPresented: $showingTimePicker) {
                TimePickerView(selectedMinutes: $selectedMinutes) {
                    timer.setQuickTime(minutes: selectedMinutes)
                    showingTimePicker = false
                }
            }
            .sheet(isPresented: $showingCompletionView) {
                TimerCompletionView {
                    timer.resetTimer()
                    showingCompletionView = false
                }
            }
        }
    }
    
    // MARK: - View Components
    @ViewBuilder
    private var timerDisplaySection: some View {
        VStack(spacing: 16) {
            Text(timer.formattedTime)
                .font(.system(size: 72, weight: .thin, design: .monospaced))
                .foregroundColor(timer.isRunning ? .brown : .primary)
                .animation(.easeInOut(duration: 0.3), value: timer.isRunning)
            
            if timer.isRunning {
                Text("\(timer.progressPercentage)% 完了")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
            } else if timer.timeRemaining > 0 {
                Text("一時停止中")
                    .font(.subheadline)
                    .foregroundColor(.orange)
            }
        }
    }
    
    @ViewBuilder
    private var progressSection: some View {
        if timer.initialTime > 0 {
            ZStack {
                // 背景サークル
                Circle()
                    .stroke(Color.brown.opacity(0.2), lineWidth: 8)
                    .frame(width: 200, height: 200)
                
                // 進捗サークル
                Circle()
                    .trim(from: 0, to: timer.progress)
                    .stroke(Color.brown, style: StrokeStyle(lineWidth: 8, lineCap: .round))
                    .frame(width: 200, height: 200)
                    .rotationEffect(.degrees(-90))
                    .animation(.easeInOut(duration: 1), value: timer.progress)
                
                // 中央のアイコン
                Image(systemName: timer.isRunning ? "flame.fill" : timer.timeRemaining > 0 ? "pause.fill" : "timer")
                    .font(.system(size: 40))
                    .foregroundColor(timer.isRunning ? .brown : .secondary)
                    .animation(.easeInOut(duration: 0.3), value: timer.isRunning)
            }
        }
    }
    
    @ViewBuilder
    private var quickTimeSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            Text("クイック設定")
                .font(.headline)
                .fontWeight(.semibold)
            
            LazyVGrid(columns: Array(repeating: GridItem(.flexible()), count: 4), spacing: 12) {
                ForEach(quickTimes, id: \.self) { minutes in
                    Button(action: {
                        timer.setQuickTime(minutes: minutes)
                    }) {
                        VStack(spacing: 4) {
                            Text("\(minutes)")
                                .font(.title2)
                                .fontWeight(.semibold)
                            Text("分")
                                .font(.caption)
                        }
                        .foregroundColor(.brown)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(Color.brown.opacity(0.1))
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
        }
    }
    
    @ViewBuilder
    private var customTimeButton: some View {
        Button(action: {
            showingTimePicker = true
        }) {
            HStack {
                Image(systemName: "clock")
                Text("カスタム時間設定")
            }
            .font(.subheadline)
            .fontWeight(.medium)
            .foregroundColor(.brown)
            .padding(.horizontal, 20)
            .padding(.vertical, 12)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .stroke(Color.brown, lineWidth: 1)
            )
        }
        .buttonStyle(.plain)
    }
    
    @ViewBuilder
    private var controlButtonsSection: some View {
        HStack(spacing: 20) {
            if timer.timeRemaining > 0 || timer.isRunning {
                // リセットボタン
                Button(action: {
                    timer.resetTimer()
                }) {
                    Image(systemName: "arrow.clockwise")
                        .font(.title2)
                        .foregroundColor(.secondary)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(Color.gray.opacity(0.1))
                        )
                }
                .buttonStyle(.plain)
            }
            
            // メインコントロールボタン
            Button(action: {
                if timer.timeRemaining == 0 {
                    // タイマーが設定されていない場合
                    return
                } else if timer.isRunning {
                    timer.pauseTimer()
                } else {
                    timer.resumeTimer()
                }
            }) {
                Image(systemName: timer.isRunning ? "pause.fill" : "play.fill")
                    .font(.system(size: 32))
                    .foregroundColor(.white)
                    .frame(width: 80, height: 80)
                    .background(
                        Circle()
                            .fill(timer.timeRemaining > 0 ? Color.brown : Color.gray)
                    )
                    .scaleEffect(timer.isRunning ? 1.1 : 1.0)
                    .animation(.easeInOut(duration: 0.2), value: timer.isRunning)
            }
            .buttonStyle(.plain)
            .disabled(timer.timeRemaining == 0)
            
            // 開始ボタン（タイマーが設定されている場合）
            if timer.timeRemaining > 0 && !timer.isRunning && timer.timeRemaining == timer.initialTime {
                Button(action: {
                    timer.startTimer(duration: timer.timeRemaining)
                }) {
                    Image(systemName: "play.fill")
                        .font(.title2)
                        .foregroundColor(.white)
                        .frame(width: 60, height: 60)
                        .background(
                            Circle()
                                .fill(Color.green)
                        )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal)
    }
}

// MARK: - Time Picker View
struct TimePickerView: View {
    @Binding var selectedMinutes: Int
    let onConfirm: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Text("調理時間を設定")
                    .font(.title2)
                    .fontWeight(.semibold)
                
                Picker("時間", selection: $selectedMinutes) {
                    ForEach(1...120, id: \.self) { minute in
                        Text("\(minute)分").tag(minute)
                    }
                }
                .pickerStyle(WheelPickerStyle())
                .frame(height: 200)
                
                Button("設定") {
                    onConfirm()
                }
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .tint(.brown)
                
                Spacer()
            }
            .padding()
            .navigationTitle("時間設定")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button("キャンセル") {
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Timer Completion View
struct TimerCompletionView: View {
    let onDismiss: () -> Void
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        NavigationView {
            VStack(spacing: 30) {
                Spacer()
                
                // 完了アニメーション
                ZStack {
                    Circle()
                        .fill(Color.brown.opacity(0.1))
                        .frame(width: 150, height: 150)
                    
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.brown)
                }
                
                VStack(spacing: 16) {
                    Text("調理完了！")
                        .font(.title)
                        .fontWeight(.bold)
                        .foregroundColor(.brown)
                    
                    Text("お疲れ様でした！\n美味しく出来上がりましたか？")
                        .font(.subheadline)
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.center)
                }
                
                Spacer()
                
                VStack(spacing: 12) {
                    Button("調理記録を追加") {
                        // 将来実装：調理記録画面への遷移
                        onDismiss()
                        dismiss()
                    }
                    .buttonStyle(.borderedProminent)
                    .controlSize(.large)
                    .tint(.brown)
                    
                    Button("新しいタイマー") {
                        onDismiss()
                        dismiss()
                    }
                    .buttonStyle(.bordered)
                    .controlSize(.large)
                    .tint(.brown)
                }
                
                Spacer()
            }
            .padding()
            .navigationTitle("完了")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar {
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button("閉じる") {
                        onDismiss()
                        dismiss()
                    }
                }
            }
        }
    }
}

// MARK: - Preview
struct CookingTimerView_Previews: PreviewProvider {
    static var previews: some View {
        CookingTimerView(timer: CookingTimer())
    }
}
