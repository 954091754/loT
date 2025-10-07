//
//  ContentView.swift
//  IoT
//
//  Created by 罗兴志 on 2025/10/7.
//

import SwiftUI

// MARK: - 数据模型
struct IoTTech: Identifiable {
    let id = UUID()
    let name: String
    let description: String
}

// MARK: - 技术列表
let iotTechList: [IoTTech] = [
    IoTTech(name: "CoreBluetooth", description: "蓝牙 BLE 设备通信（智能灯、手环、门锁）"),
    IoTTech(name: "MQTT", description: "轻量级消息协议，用于设备状态上报与控制"),
    IoTTech(name: "WebSocket", description: "实时数据交互通道，适合监控场景"),
    IoTTech(name: "HomeKit", description: "苹果官方智能家居框架"),
    IoTTech(name: "Bonjour", description: "局域网设备发现与自动配网"),
    IoTTech(name: "SmartConfig", description: "Wi-Fi 配网技术（ESP、AirKiss）"),
    IoTTech(name: "CryptoKit", description: "数据加密与安全通信"),
    IoTTech(name: "Siri Shortcuts", description: "语音控制与智能家居自动化"),
    IoTTech(name: "Push Notification", description: "设备状态变化的通知提醒"),
    IoTTech(name: "Firebase / AWS IoT", description: "云端设备管理与数据同步")
]

// MARK: - 主页面
struct ContentView: View {
    var body: some View {
        NavigationStack {
            List(iotTechList) { tech in
                NavigationLink(destination: destinationView(for: tech)) {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(tech.name)
                            .font(.headline)
                        Text(tech.description)
                            .font(.subheadline)
                            .foregroundColor(.secondary)
                    }
                    .padding(.vertical, 6)
                }
            }
            .navigationTitle("IoT 技术实验室")
        }
    }

    // MARK: - 动态跳转目标
    @ViewBuilder
    private func destinationView(for tech: IoTTech) -> some View {
        switch tech.name {
        case "CoreBluetooth":
            CoreBluetoothView()
        case "MQTT":
            MQTTView()
        default:
            IoTDetailView(tech: tech)
        }
    }
}

// MARK: - 通用详情页（其他项使用）
struct IoTDetailView: View {
    let tech: IoTTech

    var body: some View {
        VStack(spacing: 20) {
            Image(systemName: "network")
                .resizable()
                .frame(width: 80, height: 80)
                .foregroundColor(.accentColor)

            Text(tech.name)
                .font(.largeTitle)
                .bold()

            Text(tech.description)
                .font(.body)
                .multilineTextAlignment(.center)
                .padding(.horizontal)

            Spacer()
            Text("🚧 功能开发中：\(tech.name)")
                .foregroundColor(.gray)
            Spacer()
        }
        .padding()
        .navigationTitle(tech.name)
        .navigationBarTitleDisplayMode(.inline)
    }
}

#Preview {
    ContentView()
}
