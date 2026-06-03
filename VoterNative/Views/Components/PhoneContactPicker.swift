import Contacts
import ContactsUI
import SwiftUI

struct PhoneContactPicker: UIViewControllerRepresentable {
    @Binding var isPresented: Bool
    var onSelect: (PickedPhoneContact) -> Void

    func makeCoordinator() -> Coordinator {
        Coordinator(parent: self)
    }

    func makeUIViewController(context: Context) -> CNContactPickerViewController {
        let picker = CNContactPickerViewController()
        picker.delegate = context.coordinator
        return picker
    }

    func updateUIViewController(_ uiViewController: CNContactPickerViewController, context: Context) {}

    final class Coordinator: NSObject, CNContactPickerDelegate {
        let parent: PhoneContactPicker

        init(parent: PhoneContactPicker) {
            self.parent = parent
        }

        func contactPicker(_ picker: CNContactPickerViewController, didSelect contact: CNContact) {
            parent.isPresented = false
            parent.onSelect(PickedPhoneContact(from: contact))
        }

        func contactPickerDidCancel(_ picker: CNContactPickerViewController) {
            parent.isPresented = false
        }
    }
}
