//
//  ProfileNFTsTableBackgroundView.swift
//  FakeNFT
//
//  Created by Eugene Dmitrichenko on 05.03.2024.
//

import UIKit

final class ProfileNFTsTableBackgroundView: UIView {
    
    enum NFTsType {
        case myNFTs
        case favoriteNFTs
    }
    
    private var nftsType: NFTsType
    
    private let label: UILabel = {
        let label: UILabel = UILabel()
        label.font = UIFont.systemFont(ofSize: 17, weight: .bold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    init(frame: CGRect, nftsType: NFTsType) {
        self.nftsType = nftsType
        super.init(frame: frame)
        setupUI()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setupUI() {
        self.backgroundColor = UIColor(named: ColorNames.white)
        
        label.text = nftsType == .myNFTs ? 
        NSLocalizedString(LocalizableKeys.profileMyNFTsyouDontHave, comment: "")
        :
        NSLocalizedString(LocalizableKeys.profileMyNFTsyouDontHaveFavorite, comment: "")
        
        self.addSubview(label)
        
        NSLayoutConstraint.activate([
            label.centerXAnchor.constraint(equalTo: self.centerXAnchor),
            label.centerYAnchor.constraint(equalTo: self.centerYAnchor)
        ])
    }
}
