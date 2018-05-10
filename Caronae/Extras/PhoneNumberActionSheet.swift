import Foundation
import ContactsUI

class PhoneNumberAlert {
    func actionSheet(view: UIViewController, buttonText: String, user: User) -> UIAlertController? {
        guard let phoneNumber = user.phoneNumber else {
            return nil
        }
        
        let alert = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alert.addAction(UIAlertAction(title: "Ligar para \(buttonText)", style: .default) { action in
            if let url = URL(string:"tel://\(phoneNumber)"), UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.openURL(url)
            }
        })
        alert.addAction(UIAlertAction(title: "Adicionar aos Contatos", style: .default) { action in
            let contact = CNMutableContact()
            
            contact.givenName = user.firstName
            contact.familyName = user.lastName
            contact.phoneNumbers = [CNLabeledValue(
                label:CNLabelPhoneNumberMobile,
                value:CNPhoneNumber(stringValue: phoneNumber))]
            
            let store = CNContactStore()
            let contactController = CNContactViewController.init(forUnknownContact: contact)
            contactController.contactStore = store
            view.self.navigationController?.show(contactController, sender: nil)
        })
        alert.addAction(UIAlertAction(title: "Copiar", style: .default) { action in
            UIPasteboard.general.string = phoneNumber
        })
        alert.addAction(UIAlertAction(title: "Cancelar", style: .cancel))
        return alert
    }
}
