//
//  FormViewModel.swift
//  FormWithCombine
//
//  Created by Anselm Jade Jamig on 6/16/21.
//

import SwiftUI
import Combine



class FormViewModel: ObservableObject {
    @Published var username = ""
    @Published var password = ""
    @Published var passwordAgain = ""
    
    @Published var inlineErrorForPassword = ""
    
    @Published var isValid = false
    
    private var cancellables = Set<AnyCancellable>()
    
    init() {
        isFormValidPublisher
            .receive(on: RunLoop.main)
            .assign(to: \.isValid, on: self)
            .store(in: &cancellables)
        
        isPasswordValidPublisher
            .dropFirst()
            .receive(on: RunLoop.main)
            .map { passwordStatus in
                switch passwordStatus {
                case .empty:
                    return "Password cannot be empty"
                case .notStrongEnough:
                    return "Password is too weak"
                case .repeatedPasswordWrong:
                    return "Passwords do not match"
                case .valid:
                return ""
                }
            }
            .assign(to: \.inlineErrorForPassword, on: self)
            .store(in: &cancellables)
    }
    
    // Create Publishers
    // Returns Boolean value and Never fails
    private var isUsernameValidPublisher: AnyPublisher <Bool, Never> {
        $username
            //.debounce(for: 0.8, scheduler: RunLoop.main) // Create delay for 0.8 seconds
            .removeDuplicates()
            .map { $0.count >= 3 } // Username should have at least 3 characters
            .eraseToAnyPublisher()
    }
    
    private var isPasswordEmptyPublisher: AnyPublisher <Bool, Never> {
        $password
           // .debounce(for: 0.8, scheduler: RunLoop.main) // Create delay for 0.8 seconds
            .removeDuplicates()
            .map { $0.isEmpty } // Username should have at least 3 characters
            .eraseToAnyPublisher()
    }
    
    private var arePasswordEqualPublisher: AnyPublisher <Bool, Never> {
        Publishers.CombineLatest($password, $passwordAgain)
            //.debounce(for: 0.2, scheduler: RunLoop.main)
            .map { $0 == $1 }
            .eraseToAnyPublisher()
    }
    
    private var isPasswordStrongPublisher: AnyPublisher <Bool, Never> {
        $password
            //.debounce(for: 0.8, scheduler: RunLoop.main) // Create delay for 0.8 seconds
            .removeDuplicates()
            .map { $0.count > 6 }
            .eraseToAnyPublisher()
    }
    
    private var isPasswordValidPublisher: AnyPublisher<PasswordStatus, Never> {
        Publishers.CombineLatest3(isPasswordEmptyPublisher, isPasswordStrongPublisher, arePasswordEqualPublisher )
            .map {
                if $0 {
                    return PasswordStatus.empty
                } else if !$1 {
                    return PasswordStatus.notStrongEnough
                } else if !$2 {
                    return PasswordStatus.repeatedPasswordWrong
                } else {
                    return PasswordStatus.valid
                }
            }
            .eraseToAnyPublisher()
    }
    
    private var isFormValidPublisher: AnyPublisher<Bool, Never> {
        Publishers.CombineLatest(isPasswordValidPublisher, isUsernameValidPublisher)
            .map { $0 == .valid && $1 }
            .eraseToAnyPublisher()
    }
    
}
