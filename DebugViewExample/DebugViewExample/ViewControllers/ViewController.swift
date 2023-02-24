//
//  ViewController.swift
//  DebugViewExample
//
//  Created by Emre on 24.02.2023.
//

import UIKit

class ViewController: UIViewController {

    private lazy var debugView = DebugView(frame:  CGRect(x: 0, y: UIScreen.main.bounds.height - 300, width: UIScreen.main.bounds.width, height: 300))

    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        addLogView()
    }

    @IBAction func printLogButton(_ sender: UIButton) {
        print("===>>>>> The Random Number: \(Int.random(in: 1...100)) <<<<<===")
    }

    private func addLogView() {
        view.addSubview(debugView)
    }

}

