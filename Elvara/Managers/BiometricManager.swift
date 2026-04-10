//
//  BiometricManager.swift
//  Elvara
//
//  Created by Quang Phat on 8/4/26.
//

import LocalAuthentication

class BiometricManager {
    func authenticate() async -> Bool {
        let context = LAContext()
        var error: NSError?
        
        if context.canEvaluatePolicy(.deviceOwnerAuthenticationWithBiometrics, error: &error) {
            do {
                return try await context.evaluatePolicy(
                    .deviceOwnerAuthenticationWithBiometrics,
                    localizedReason: "Unlock app"
                )
            } catch {
                return false
            }
        }
        return false
    }
}
