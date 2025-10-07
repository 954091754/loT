//
//  MQTTView.swift
//  IoT
//
//  Created by 罗兴志 on 2025/10/7.
//

import SwiftUI
import CocoaMQTT

// MARK: - MQTT 客户端管理器
final class MQTTManager: NSObject, ObservableObject, CocoaMQTTDelegate {
    @Published var messages: [String] = []
    @Published var isConnected = false
    
    private var mqtt: CocoaMQTT?
    
    func connect(host: String, port: UInt16, clientID: String = "iOSClient-\(UUID().uuidString.prefix(4))") {
        mqtt = CocoaMQTT(clientID: clientID, host: host, port: port)
        mqtt?.delegate = self
        mqtt?.keepAlive = 60
        mqtt?.autoReconnect = true
        mqtt?.enableSSL = false
        mqtt?.connect()
    }
    
    func disconnect() {
        mqtt?.disconnect()
        isConnected = false
    }
    
    func subscribe(topic: String) {
        mqtt?.subscribe(topic)
    }
    
    func publish(topic: String, message: String) {
        mqtt?.publish(CocoaMQTTMessage(topic: topic, string: message))
    }
    
    // MARK: - CocoaMQTTDelegate
    func mqtt(_ mqtt: CocoaMQTT, didConnectAck ack: CocoaMQTTConnAck) {
        DispatchQueue.main.async {
            self.isConnected = true
            self.messages.append("✅ 已连接到 MQTT Broker")
        }
    }
    
    func mqtt(_ mqtt: CocoaMQTT, didReceiveMessage message: CocoaMQTTMessage, id: UInt16) {
        let text = message.string ?? "(空消息)"
        DispatchQueue.main.async {
            self.messages.append("📩 收到消息: \(text)")
        }
    }
    
    func mqttDidDisconnect(_ mqtt: CocoaMQTT, withError err: Error?) {
        DispatchQueue.main.async {
            self.isConnected = false
            self.messages.append("❌ 已断开连接")
        }
    }
}

// MARK: - SwiftUI 界面
struct MQTTView: View {
    @StateObject private var manager = MQTTManager()
    @State private var host = "test.mosquitto.org"
    @State private var port: UInt16 = 1883
    @State private var topic = "iot/demo"
    @State private var message = ""
    
    var body: some View {
        VStack(spacing: 20) {
            // 连接区域
            VStack(alignment: .leading) {
                TextField("Host", text: $host)
                    .textFieldStyle(.roundedBorder)
                HStack {
                    TextField("Port", value: $port, formatter: NumberFormatter())
                        .keyboardType(.numberPad)
                        .textFieldStyle(.roundedBorder)
                    Spacer()
                    Button(manager.isConnected ? "断开" : "连接") {
                        if manager.isConnected {
                            manager.disconnect()
                        } else {
                            manager.connect(host: host, port: port)
                        }
                    }
                    .buttonStyle(.borderedProminent)
                }
            }
            .padding()
            
            // 订阅与发送
            VStack(alignment: .leading) {
                TextField("Topic", text: $topic)
                    .textFieldStyle(.roundedBorder)
                HStack {
                    TextField("Message", text: $message)
                        .textFieldStyle(.roundedBorder)
                    Button("发布") {
                        manager.publish(topic: topic, message: message)
                        message = ""
                    }
                    .disabled(!manager.isConnected)
                    .buttonStyle(.bordered)
                }
                Button("订阅主题") {
                    manager.subscribe(topic: topic)
                }
                .disabled(!manager.isConnected)
                .buttonStyle(.bordered)
            }
            .padding()
            
            Divider()
            
            // 消息日志
            List(manager.messages, id: \.self) { msg in
                Text(msg)
                    .font(.system(size: 14))
            }
        }
        .navigationTitle("MQTT 客户端")
    }
}
