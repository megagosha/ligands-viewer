//
//  ShareViewController.swift
//  swifty-protein
//
//  Created by George Tevosov on 31.10.2022.
//

import UIKit
import SwiftUI

struct ActivityViewController: UIViewControllerRepresentable {

    var img: ImageToShare?
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<ActivityViewController>) -> UIActivityViewController {
        let controller = UIActivityViewController(activityItems: [img?.img], applicationActivities: nil)
        controller.excludedActivityTypes = [.assignToContact, .addToReadingList]
        return controller
    }

    func updateUIViewController(_ uiViewController: UIActivityViewController, context: UIViewControllerRepresentableContext<ActivityViewController>) {}
}
