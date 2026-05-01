import Foundation
import ServiceManagement

enum LaunchAtLogin {
    static var isEnabled: Bool {
        SMAppService.mainApp.status == .enabled
    }

    static func setEnabled(_ enabled: Bool) throws {
        let service = SMAppService.mainApp
        if enabled {
            if service.status == .enabled { return }
            try service.register()
        } else {
            if service.status == .notRegistered { return }
            try service.unregister()
        }
    }
}
