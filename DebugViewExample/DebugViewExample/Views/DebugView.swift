//
//  DebugView.swift
//  DebugViewExample
//
//  Created by Emre on 24.02.2023.
//

import UIKit

final class DebugView: UIView {

    private var closeButton: UIButton!
    private var logTextView: UITextView!
    private var isContainerViewOpen = true
    private var debugViewFrame: CGRect!

    override init(frame: CGRect) {
        super.init(frame: frame)
        setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setupView()
    }

    override func awakeFromNib() {
        super.awakeFromNib()
        setupView()
    }

    override func prepareForInterfaceBuilder() {
        super.prepareForInterfaceBuilder()
        setupView()
    }

    private func setupView() {
        debugViewFrame = self.frame
        self.backgroundColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.8)
        self.layer.cornerRadius = 8
        self.clipsToBounds = true

        let panGestureRecognizer = UIPanGestureRecognizer(target: self, action: #selector(didViewDragged(_:)))
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(panGestureRecognizer)

        let blackView = UIView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: 40))
        blackView.backgroundColor = .black
        self.addSubview(blackView)

        let clearButton = UIButton(frame: CGRect(x: 5, y: 5, width: 60, height: 30))
        clearButton.layer.cornerRadius = 8
        clearButton.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
        clearButton.setTitle("Clear", for: .normal)
        clearButton.setTitleColor(.white, for: .normal)
        clearButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didClearButtonTapped)))
        blackView.addSubview(clearButton)

        let dragImageView = UIImageView(frame: CGRect(x: (self.frame.width-24)/2, y: 8, width: 24, height: 24))
        dragImageView.image = UIImage(named: "drag")
        blackView.addSubview(dragImageView)

        closeButton = UIButton(frame: CGRect(x: self.frame.width-65, y: 5, width: 60, height: 30))
        closeButton.layer.cornerRadius = 8
        closeButton.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0.2)
        closeButton.setTitle("Close", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(didCloseButtonTapped)))
        blackView.addSubview(closeButton)

        logTextView = UITextView(frame: CGRect(x: 0, y: 40, width: self.frame.width, height: self.frame.height-40))
        logTextView.isEditable = false
        logTextView.isSelectable = false
        logTextView.backgroundColor = .clear
        logTextView.textColor = .lightGray
        logTextView.font = UIFont.systemFont(ofSize: 14)
        self.addSubview(logTextView)

        let pipe = Pipe()
        dup2(pipe.fileHandleForWriting.fileDescriptor, FileHandle.standardOutput.fileDescriptor)
        pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()

        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: pipe.fileHandleForReading , queue: nil) {
            notification in

            let output = pipe.fileHandleForReading.availableData
            let outputString = String(data: output, encoding: String.Encoding.utf8) ?? ""

            DispatchQueue.main.async(execute: {
                let previousOutput = self.logTextView.text!
                let nextOutput = previousOutput + outputString
                self.logTextView.text = nextOutput

                let range = NSRange(location: nextOutput.count, length: 0)
                self.logTextView.scrollRangeToVisible(range)
            })

            pipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        }
    }

    @objc func didViewDragged(_ sender: UIPanGestureRecognizer){
        self.bringSubviewToFront(self)
        let translation = sender.translation(in: self)
        self.center = CGPoint(x: self.center.x + translation.x, y: self.center.y + translation.y)
        sender.setTranslation(CGPoint.zero, in: self)
    }

    @objc func didClearButtonTapped() {
        logTextView.text = nil
    }

    @objc func didCloseButtonTapped() {
        self.frame = CGRect(x: debugViewFrame.origin.x,
                            y: isContainerViewOpen ? UIScreen.main.bounds.height - 40 : debugViewFrame.origin.y,
                            width: debugViewFrame.width,
                            height: isContainerViewOpen ? 40 : debugViewFrame.height)
        closeButton.setTitle(isContainerViewOpen ? "Open" : "Close", for: .normal)
        isContainerViewOpen = !isContainerViewOpen
    }

}
