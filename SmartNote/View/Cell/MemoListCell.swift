//
//  MemoListCell.swift
//  SmartNote
//
//  Created by 행복한 개발자 on 26/06/2019.
//  Copyright © 2019 Alex Lee. All rights reserved.
//

import UIKit

class MemoListCell: UITableViewCell {
    
    let dateLabel = UILabel()
    let titleLabel = UILabel()
    let descriptionLabel = UILabel()
    let noteIcon = UIImageView()
    
    let pinImageView = UIImageView()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        configure()
        setAutolayout()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    private func configure() {
        
        dateLabel.textColor = .gray
        dateLabel.font = UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
        contentView.addSubview(dateLabel)
        
        titleLabel.font = UIFont.systemFont(ofSize: 17, weight: .medium)
        contentView.addSubview(titleLabel)
        
        descriptionLabel.textColor = .lightGray
        descriptionLabel.font = .systemFont(ofSize: 14)
        contentView.addSubview(descriptionLabel)
        
        noteIcon.contentMode = .scaleAspectFit
        contentView.addSubview(noteIcon)
    }
    
    private func setAutolayout() {
        
        noteIcon.translatesAutoresizingMaskIntoConstraints = false
        noteIcon.centerYAnchor.constraint(equalTo: contentView.centerYAnchor).isActive = true
        noteIcon.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10).isActive = true
        noteIcon.heightAnchor.constraint(equalToConstant: 50).isActive = true
        noteIcon.widthAnchor.constraint(equalToConstant: 50).isActive = true
        
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor, constant: -10).isActive = true
        titleLabel.leadingAnchor.constraint(equalTo: noteIcon.trailingAnchor, constant: 15).isActive = true
        titleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -30).isActive = true
    
        dateLabel.translatesAutoresizingMaskIntoConstraints = false
        dateLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -8).isActive = true
        dateLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10).isActive = true
        dateLabel.widthAnchor.constraint(equalToConstant: 70).isActive = true
        
        descriptionLabel.translatesAutoresizingMaskIntoConstraints = false
        descriptionLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor, constant: 5).isActive = true
        descriptionLabel.leadingAnchor.constraint(equalTo: titleLabel.leadingAnchor).isActive = true
        descriptionLabel.trailingAnchor.constraint(equalTo: dateLabel.leadingAnchor, constant: -30).isActive = true
        
        contentView.addSubview(pinImageView)
        pinImageView.translatesAutoresizingMaskIntoConstraints = false
        pinImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -5).isActive = true
        pinImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 3).isActive = true
        pinImageView.widthAnchor.constraint(equalToConstant: 20).isActive = true
        pinImageView.heightAnchor.constraint(equalTo: pinImageView.widthAnchor, constant: 0).isActive = true
    }
}
