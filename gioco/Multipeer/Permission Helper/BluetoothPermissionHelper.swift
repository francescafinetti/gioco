import Foundation
import CoreBluetooth

class BluetoothPermissionHelper: NSObject, CBCentralManagerDelegate {
    private var manager: CBCentralManager!

    override init() {
        super.init()
        manager = CBCentralManager(delegate: self, queue: nil)
    }

    func centralManagerDidUpdateState(_ central: CBCentralManager) {
        // Serve solo per innescare la richiesta dei permessi
        print("🔄 Bluetooth status: \(central.state.rawValue)")
    }
}
