//
//  CoreBluetoothView.swift
//  IoT
//
//  Created by 罗兴志 on 2025/10/7.
//

import SwiftUI
import CoreBluetooth
import Combine

struct CoreBluetoothView: View {
    @StateObject private var bleManager = BLEManager()

    var body: some View {
        List(bleManager.peripherals, id: \.identifier) { peripheral in
            VStack(alignment: .leading) {
                Text(peripheral.name ?? "未知设备")
                    .font(.headline)
                Text(peripheral.identifier.uuidString)
                    .font(.footnote)
                    .foregroundColor(.secondary)
            }
            .padding(.vertical, 4)
        }
        .navigationTitle("BLE 扫描")
        .overlay(alignment: .center) {
            if bleManager.peripherals.isEmpty {
                VStack {
                    ProgressView()
                    Text("正在扫描蓝牙设备…")
                        .foregroundColor(.gray)
                        .padding(.top, 8)
                }
            }
        }
    }
}

// MARK: - CoreBluetooth 蓝牙扫描页
final class BLEManager: NSObject, ObservableObject, CBCentralManagerDelegate {
    @Published var peripherals: [CBPeripheral] = []
    private var centralManager: CBCentralManager?

    override init() {
        super.init()
        centralManager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        switch central.state {
        case .poweredOn:
            central.scanForPeripherals(withServices: nil)
        default:
            peripherals.removeAll()
        }
    }

    func centralManager(_ central: CBCentralManager,
                        didDiscover peripheral: CBPeripheral,
                        advertisementData: [String: Any],
                        rssi RSSI: NSNumber) {
        if !peripherals.contains(where: { $0.identifier == peripheral.identifier }) {
            peripherals.append(peripheral)
        }
    }
}
