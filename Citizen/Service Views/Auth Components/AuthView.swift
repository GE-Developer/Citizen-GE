//
//  AuthView.swift
//  Citizen
//
//  Created by GE-Developer
//

import SwiftUI

struct AuthView: View {
    @State private var route: AuthRoute = .welcome
    @State private var isMovingForward = true
    
    private var routeBinding: Binding<AuthRoute> {
        Binding(get: { route }, set: { changeRoute(to: $0) })
    }
    
    private var transition: AnyTransition {
        .asymmetric(
            insertion: .offset(x: isMovingForward ? screenWidth : -screenWidth),
            removal: .offset(x: isMovingForward ? -screenWidth : screenWidth)
        )
    }
    
    var body: some View {
        authView
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(Color.citizen.background.ignoresSafeArea())
    }
}

// MARK: - Builder
extension AuthView {
    private var authView: some View {
        ZStack {
            screen
                .id(route)
                .transition(transition)
        }
        .animation(.smooth, value: route)
    }
    
    @ViewBuilder
    private var screen: some View {
        switch route {
        case .welcome:
            WelcomeView(route: routeBinding)
        case .signIn:
            SignInView(route: routeBinding)
        case .signUp:
            SignUpView(route: routeBinding)
        case .verifyEmail(let email, let name, let origin):
            VerifyEmailView(
                email: email,
                name: name,
                origin: origin,
                route: routeBinding
            )
        case .resetPassword(let email):
            ResetPasswordView(email: email, route: routeBinding)
        }
    }
}

// MARK: - Logic
extension AuthView {
    private func changeRoute(to newRoute: AuthRoute) {
        dismissKeyboard()
        isMovingForward = newRoute.depth >= route.depth
        
        Task {
            route = newRoute
        }
    }
}
