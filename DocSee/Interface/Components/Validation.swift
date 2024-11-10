//
//  Validation.swift
//  DocSee
//
//  Created by Noah Kamara on 10.11.24.
//

import Foundation
import Combine

// MARK: Validation
enum ValidatationResult: ExpressibleByBooleanLiteral, Equatable {
    case failed(String?)
    case success
    
    init(booleanLiteral value: Bool) {
        self = value ? .success : .failed(nil)
    }
}

@Observable
class Validated<Value: Equatable> {
    private let validationSubject = PassthroughSubject<Value,Never>()
    
    private(set) var isFailed: Bool = false
    private(set) var failureReason: String? = nil
    
    private var validationType: ValidationType
    private let validation: (Value) -> ValidatationResult
    private var cancellable: Cancellable!
    
    public var value: Value {
        willSet {
            if case .immediate = validationType {
                validationSubject.send(newValue)
            }
        }
    }
    
    required init(
        initialValue value: Value,
        type: ValidationType = .immediate,
        validation: @escaping (Value) -> ValidatationResult
    ) {
        self.value = value
        self.validationType = type
        self.validation = validation
        self.cancellable = validationSubject
            .removeDuplicates(by: { $0 == $1 })
            .eraseToAnyPublisher()
            .map(validation)
            .sink(receiveValue: { self.didValidate($0) })
    }
    
    convenience init(
        initialValue value: Value,
        type: ValidationType = .immediate,
        validation: @escaping (Value) -> Bool
    ) {
        self.init(
            initialValue: value,
            type: type,
            validation: {
                validation($0) ? .success : .failed("Invalid")
            })
    }
    
    private func didValidate(_ result: ValidatationResult) {
        withMutation(keyPath: \.isFailed) {
            withMutation(keyPath: \.failureReason) {
                switch result {
                case .success:
                    self.isFailed = false
                    self.failureReason = nil
                case .failed(let reason):
                    self.isFailed = true
                    self.failureReason = reason
                }
            }
        }
    }
    
    func triggerValidatation() {
        self.validationType = .immediate
        validationSubject.send(value)
    }
    
    enum ValidationType {
        case immediate
        case deferred
    }
}

import SwiftUI

fileprivate struct FieldValidation<Value: Equatable>: ViewModifier {
    let field: Validated<Value>
    
    func body(content: Content) -> some View {
        HStack {
            content
            if field.isFailed {
                Text(field.failureReason ?? "invalid")
                    .font(.caption)
                    .fontWeight(.medium)
                    .foregroundStyle(.red)
            }
        }
    }
}

extension View {
    func validation<T: Equatable>(_ field: Validated<T>) -> some View {
        self.modifier(FieldValidation(field: field))
    }
}

extension Validated where Value == String {
    static func validURL(initialValue: String = "", type: ValidationType = .immediate) -> Self {
        return Self(
            initialValue: initialValue,
            type: type,
            validation: { URL(string: $0) != nil ? .success : .failed("must be url") }
        )
    }
    
    static func nonEmpty(initialValue: String = "", type: ValidationType = .immediate) -> Self {
        return Self(
            initialValue: initialValue,
            type: type,
            validation: { !$0.isEmpty ? .success : .failed("required") }
        )
    }
}

struct UserError: Error {
    let localizedDescription: String
    
    init(_ localizedDescription: String) {
        self.localizedDescription = localizedDescription
    }
}

