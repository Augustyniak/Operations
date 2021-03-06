//
//  ContactsUIOperations.swift
//  Operations
//
//  Created by Daniel Thorpe on 24/09/2015.
//  Copyright © 2015 Dan Thorpe. All rights reserved.
//

import Contacts
import ContactsUI

@available(iOS 9.0, *)
public typealias ContactViewControllerConfigurationBlock = CNContactViewController -> Void

@available(iOS 9.0, *)
final public class DisplayContactViewController<F: PresentingViewController>: GroupOperation {

    let from: ViewControllerDisplayStyle<F>
    let sender: AnyObject?
    let get: GetContacts
    let configuration: ContactViewControllerConfigurationBlock?

    var ui: UIOperation<CNContactViewController, F>? = .None

    public var contactViewController: CNContactViewController? {
        return ui?.controller
    }

    public init(identifier: String, displayControllerFrom from: ViewControllerDisplayStyle<F>, delegate: CNContactViewControllerDelegate, sender: AnyObject? = .None, configuration: ContactViewControllerConfigurationBlock? = .None) {
        self.from = from
        self.sender = sender
        self.get = GetContacts(identifier: identifier, keysToFetch: [CNContactViewController.descriptorForRequiredKeys()])
        self.configuration = configuration
        super.init(operations: [ get ])
        name = "Display Contact View Controller"
    }

    public func createViewControllerForContact(contact: CNContact) -> CNContactViewController {
        let vc = CNContactViewController(forContact: contact)
        configuration?(vc)
        return vc
    }

    public override func willFinishOperation(operation: NSOperation, withErrors errors: [ErrorType]) {
        if errors.isEmpty && operation == get, let contact = get.contact {
            ui = UIOperation(controller: createViewControllerForContact(contact), displayControllerFrom: from, sender: sender)
            addOperation(ui!)
        }
    }
}

@available(iOS 9.0, *)
final public class DisplayCreateContactViewController<F: PresentingViewController>: Operation {

    let configuration: ContactViewControllerConfigurationBlock?
    let ui: UIOperation<CNContactViewController, F>

    public var contactViewController: CNContactViewController {
        return ui.controller
    }

    public init(displayControllerFrom from: ViewControllerDisplayStyle<F>, delegate: CNContactViewControllerDelegate, sender: AnyObject? = .None, configuration: ContactViewControllerConfigurationBlock? = .None) {

        let controller = CNContactViewController(forNewContact: .None)
        controller.contactStore = CNContactStore()
        controller.delegate = delegate
        self.ui = UIOperation(controller: controller, displayControllerFrom: from, sender: sender)
        self.configuration = configuration
        super.init()
        name = "Display Create Contact View Controller"
    }

    public override func execute() {
        configuration?(contactViewController)
        produceOperation(ui)
    }
}

