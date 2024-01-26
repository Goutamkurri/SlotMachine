//
//  ViewController.swift
//  SlotMachine
//
//  Created by Goutam Kurri on 1/4/24.
//

import UIKit
import AudioToolbox


class ViewController: UIViewController, UIPickerViewDataSource, UIPickerViewDelegate {
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return symbols.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return symbols[row]
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 80
    }
    
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title = symbols[row]
        let fontSize: CGFloat = 120.0
        let attributes: [NSAttributedString.Key: Any] = [
            NSAttributedString.Key.font: UIFont.systemFont(ofSize: fontSize),
            NSAttributedString.Key.foregroundColor: UIColor.black
        ]
        return NSAttributedString(string: title, attributes: attributes)
    }
    
    @IBOutlet weak var betStepper: UIStepper!
    @IBOutlet weak var slotsLBL: UILabel!
    @IBOutlet weak var slotsPV: UIPickerView!
    @IBOutlet weak var spinBTN: UIButton!
    @IBOutlet weak var betLabel: UILabel!
    @IBOutlet weak var creditsLabel: UILabel!
    
    let symbols = ["🍒","🍋","🍒","💎","🍋","🍒","💎","🍒","🍋","🍒","🍋","💎","🍒","🍋","🍒","💎","🍒","🍋","🍒","💎","🍋","🍒","💎","🍋","🍒", "💎","🍒","🍋"]
    
    var playerCredits = 1000
    var currentBet = 100
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        slotsPV.dataSource = self
        slotsPV.delegate = self
        updateUI()
        
        let doubleTapGesture = UITapGestureRecognizer(target: self, action: #selector(handleDoubleTap))
        doubleTapGesture.numberOfTapsRequired = 2
        slotsLBL.addGestureRecognizer(doubleTapGesture)
    }
    
    @IBAction func onClickSpinBTN(_ sender: UIButton) {
        if playerCredits >= currentBet {
            playerCredits -= currentBet
            creditsLabel.text = "Credits: \(playerCredits)"
            spinBTN.isEnabled = false
            
            //AudioServicesPlaySystemSound(1104)

            
            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseOut], animations: {
                let randomIndex1 = Int.random(in: 0..<self.symbols.count)
                self.slotsPV.selectRow(randomIndex1, inComponent: 0, animated: true)
                AudioServicesPlaySystemSound(1104)
            }) { (completed) in
                DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                    UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseOut], animations: {
                        let randomIndex2 = Int.random(in: 0..<self.symbols.count)
                        self.slotsPV.selectRow(randomIndex2, inComponent: 1, animated: true)
                        AudioServicesPlaySystemSound(1104)
                    }) { (completed) in
                        DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                            UIView.animate(withDuration: 0.5, delay: 0.0, options: [.curveEaseOut], animations: {
                                let randomIndex3 = Int.random(in: 0..<self.symbols.count)
                                self.slotsPV.selectRow(randomIndex3, inComponent: 2, animated: true)
                                AudioServicesPlaySystemSound(1104)
                            }) { (completed) in
                                self.spinBTN.isEnabled = true
                                self.checkWin()
                                self.updateUI()
                            }
                        }
                    }
                }
            }
        } else {
            print("Insufficient credits.")
        }
    }
    
    func checkWin() {
        let selectedRow1 = slotsPV.selectedRow(inComponent: 0)
        let selectedRow2 = slotsPV.selectedRow(inComponent: 1)
        let selectedRow3 = slotsPV.selectedRow(inComponent: 2)
        
        let symbol1 = symbols[selectedRow1]
        let symbol2 = symbols[selectedRow2]
        let symbol3 = symbols[selectedRow3]
        
        var multiplier = 1
        
        if symbol1 == symbol2 && symbol2 == symbol3 {
            switch symbol1 {
            case "🍒":
                multiplier = 2
            case "🍋":
                multiplier = 3
            case "💎":
                multiplier = 5
            default:
                break
            }
            let winnings = currentBet * multiplier
            playerCredits += winnings
            showAlert(title: "🎉Congratulations🎉", message: "You won \(winnings) credits!")
            print("Congratulations! You won \(winnings) credits!")
        } else {
            print("Try again! You lost \(currentBet) credits.")
        }
    }
    
    func updateUI() {
        creditsLabel.text = "Credits: \(playerCredits)"
        betLabel.text = "Bet: \(currentBet)"
        betStepper.value = Double(currentBet / 100)
        spinBTN.isEnabled = currentBet <= playerCredits && playerCredits > 0
    }
    
    @IBAction func betStepperValueChanged(_ sender: UIStepper) {
        let newBet = Int(sender.value) * 100
        currentBet = max(newBet, 100)
        spinBTN.isEnabled = currentBet <= playerCredits
        updateUI()
    }
    
    func showAlert(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
    
    @objc func handleDoubleTap() {
        playerCredits = 1000
        currentBet = 100
        slotsPV.selectRow(0, inComponent: 0, animated: true)
        slotsPV.selectRow(0, inComponent: 1, animated: true)
        slotsPV.selectRow(0, inComponent: 2, animated: true)
        updateUI()
        spinBTN.isEnabled = true
    }
}
