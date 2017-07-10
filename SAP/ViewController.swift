//
//  ViewController.swift
//  SAP
//
//  Created by ray on 10/07/2017.
//  Copyright © 2017 rayps. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    @IBOutlet weak var rectangle: UIView!
    @IBOutlet weak var emojiLabel: UILabel!
    @IBOutlet weak var codeLabel: UILabel!
    @IBOutlet weak var copyButton: UIButton!
    @IBOutlet weak var moreButton: UIButton!

    @IBOutlet weak var durationSlider: UISlider!
    @IBOutlet weak var dampingSlider: UISlider!
    @IBOutlet weak var velocitySlider: UISlider!

    @IBOutlet weak var durationValueLabel: UILabel!
    @IBOutlet weak var dampingValueLabel: UILabel!
    @IBOutlet weak var velocityValueLabel: UILabel!

    @IBOutlet var sliders: [UISlider]!
    @IBOutlet var valueLabels: [UILabel]!

    let blue = #colorLiteral(red: 0, green: 0.4387717247, blue: 1, alpha: 1)
    var code: String = ""
    var lastValueString: String = "0.0"
    var emojiModeEnabled: Bool = false



    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.

        rectangle.layer.cornerRadius = 4
        emojiLabel.layer.opacity = 0
        code = codeLabel.text!
        updateValueLabels()
        updateCodeLabel()
    }

    func updateValueLabels() {
        for (index, label) in valueLabels.enumerated() {
            label.text = sliders[index].value.string1f
        }
    }

    func updateCodeLabel() {
        codeLabel.text = String(format: code, durationSlider.value, dampingSlider.value, velocitySlider.value)
        copyButton.isEnabled = true
    }

    func performAnimation() {
        let destination = rectangle.superview!.frame.size.width - rectangle.frame.size.width
        let rectTX = rectangle.transform.tx

        UIView.animate(
            withDuration: Double(durationSlider.value),
            delay: 0,
            usingSpringWithDamping: CGFloat(dampingSlider.value),
            initialSpringVelocity: CGFloat(velocitySlider.value),
            options: [],
            animations: {
                if rectTX < destination / 2 {
                    self.rectangle.transform = CGAffineTransform(translationX: destination, y: 0)
                    self.emojiLabel.text = String.randomEmoji()
                } else {
                    self.rectangle.transform = CGAffineTransform.identity
                }
            },
            completion: nil
        )
    }

    @IBAction func copyButtonDidTouch(_ sender: UIButton) {
        UIPasteboard.general.string = codeLabel.text
        copyButton.isEnabled = false
        Haptic.notification(.success).generate()
    }




    @IBAction func sliderDidSlide(_ sender: UISlider) {
        if sender.value.string1f != lastValueString {
            Haptic.impact(.light).generate()
            lastValueString = sender.value.string1f
            updateValueLabels()
            updateCodeLabel()
        }
    }

    @IBAction func sliderDidTouch(_ sender: Any) {
        performAnimation()
    }




    @IBAction func moreButtonDidTouch(_ sender: UIButton) {
        let menu = UIAlertController(title: nil, message: "Pro Tip:\nThe best animation duration is less than 1s.\nThe Velocity is always better to be zero.\nCopy code with Universal Clipboard enabled.", preferredStyle: .actionSheet)
        let aboutAction = UIAlertAction(title: "About", style: .default) { (action) in
            UIApplication.shared.open(URL(string: "http://rayps.com")!, options: [:], completionHandler: nil)
        }
        let emojiAction = UIAlertAction(title: (emojiModeEnabled ? "Disable" : "Enable") + " Emoji Mode", style: .default) { (action) in
            self.emojiModeEnabled = !self.emojiModeEnabled
            self.emojiLabel.layer.opacity = self.emojiModeEnabled ? 1 : 0
            self.rectangle.backgroundColor = self.emojiModeEnabled ? UIColor.clear : self.blue
        }

        let durationAction = UIAlertAction(title: (durationSlider.maximumValue ==  1 ? "Extend" : "Shorten") + " Max Duration", style: .default) { (action) in
            self.durationSlider.maximumValue = (self.durationSlider.maximumValue == 1 ? 10 : 1)
            self.updateValueLabels()
        }

        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)

        menu.addAction(aboutAction)
        menu.addAction(emojiAction)
        menu.addAction(durationAction)
        menu.addAction(cancelAction)

        menu.modalPresentationStyle = .popover

        if let presenter = menu.popoverPresentationController {
            presenter.sourceView = moreButton
            presenter.sourceRect = moreButton.bounds
        }

        present(menu, animated: true)
    }
}

extension Float {
    var string1f: String {
        return String(format: "%.1f", self)
    }
}

extension String{
    static func randomEmoji()->String{
        let range = [UInt32](0x1F601...0x1F64F)
        let ascii = range[Int(drand48() * (Double(range.count)))]
        let emoji = UnicodeScalar(ascii)?.description
        return emoji!
    }
}
