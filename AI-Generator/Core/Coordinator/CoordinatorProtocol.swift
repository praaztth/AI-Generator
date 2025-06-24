//
//  CoordinatorProtocol.swift
//  AI-Generator
//
//  Created by катенька on 24.06.2025.
//

import Foundation
import RxSwift

// change to class BaseCoordinator
protocol CoordinatorProtocol: AnyObject {
    var childCoordinators: [CoordinatorProtocol] { get set }
    var didFinish: PublishSubject<Void> { get }
    
    func childDidFinished(child: CoordinatorProtocol)
    
    func start()
    func finish()
}

extension CoordinatorProtocol {
    func childDidFinished(child: CoordinatorProtocol) {
        if let index = childCoordinators.firstIndex(where: { $0 === child }) {
            childCoordinators.remove(at: index)
        }
    }
}
