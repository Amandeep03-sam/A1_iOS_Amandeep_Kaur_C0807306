//
//  DistanceAnnotationView.swift
//  A1_iOS_Amandeep_Kaur_C0807306
//
//  Created by Amandeep Kaur on 17/05/21.
//
import Foundation
import MapKit
import UIKit
class DistanceAnnotationView: MKAnnotationView {
    private let annotationFrame = CGRect(x: 0, y: 0, width: 60, height: 40)
    private let label: UILabel
    override init(annotation: MKAnnotation?, reuseIdentifier: String?) {
        self.label = UILabel(frame: annotationFrame.offsetBy(dx: 0, dy: -6))
        super.init(annotation: annotation, reuseIdentifier: reuseIdentifier)
        self.frame = annotationFrame
        self.label.font = UIFont.systemFont(ofSize: 10, weight: .regular)
        self.label.textColor = .black
        self.label.textAlignment = .center
        self.backgroundColor = .clear
        self.addSubview(label)
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) not implemented!")
    }
    public var distance: Int = 0 {
        didSet {
            self.label.text = String(Double(distance)/1000) + " KM" } } }
