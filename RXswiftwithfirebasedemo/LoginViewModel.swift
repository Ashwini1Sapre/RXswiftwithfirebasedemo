//
//  LoginViewModel.swift
//  RXswiftwithfirebasedemo
//
//  Created by Knoxpo MacBook Pro on 15/01/21.
//

import Foundation
import FirebaseAuth
import RxSwift
import FirebaseCore
class LoginViewModel
{
    let validatedEmail: Observable<Bool>
    let validatedPassword: Observable<Bool>
    let loginEnabled: Observable<Bool>
    let loginObservable: Observable<(User?, Error?)>

    init(input: (username: Observable<String>,
        password: Observable<String>,
        loginTap: Observable<Void>)) {
        
        self.validatedEmail = input.username
            .map { $0.characters.count >= 5 }
           // .shareReplay(1)
        
        self.validatedPassword = input.password
            .map { $0.characters.count >= 4 }
          //  .shareReplay(1)
        
        self.loginEnabled = Observable.combineLatest(validatedEmail, validatedPassword ) { $0 && $1 }
        let userAndPassword = Observable.combineLatest(input.username, input.password) {($0,$1)}
        
        self.loginObservable = input.loginTap.withLatestFrom(userAndPassword).flatMapLatest{ (username, password) in
            return LoginViewModel.login(username: username, password: password).observeOn(MainScheduler.instance)
        }
    }

    private class func login(username: String?, password: String?) -> Observable<(User?, Error?)> {
        return  Observable.create { observer in
            if let username = username, let password = password {
                Auth.auth().signIn(withEmail: username, password: password) { user, error in
                    observer.onNext((user, error))
                }
            } else {
                // TODO: - add error
               // observer.onNext((nil, AError.General("ok")))
            }
            return Disposables.create()
        }
    }
    
    
    
}
