//
//  HeaderCollectionReusableView.swift
//  Assignment 3
//
//  Created by Jyoti Talukdar on 25/05/21.
//

import UIKit

class HeaderCollectionReusableView: UICollectionReusableView {
        static let identifier = "HeaderCollectionReusableView"
    private let label: UILabel = {
        let label = UILabel()
        label.text = "Books by the Author"
        label.textAlignment = .left
        return label
    }()
    public func configure(){
        addSubview(label)
    }
}
