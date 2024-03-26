//
//  File.swift
//  FakeNFT
//
//  Created by Eugene Dmitrichenko on 05.03.2024.
//

import Combine
import Foundation
import UIKit

final class ProfileMyNFTsViewModel {
    
    @Published var myNFTs: [NFTModel]?
    @Published var profile: CurrentValueSubject<Profile?, Never>
    private var favoriteNFTs: [String]?
    
    private let servicesAssembly: ServicesAssembly
    
    var alertInfo: (
        (
            _ title: String,
            _ buttonTitle: String,
            _ message: String
        ) -> Void
    )?
    
    init(servicesAssembly: ServicesAssembly, profile: CurrentValueSubject<Profile?, Never>) {
        self.servicesAssembly = servicesAssembly
        self.profile = profile
    }
    
    func getNFTs(by idList: [String]?) {
        var nftList: [NFTModel] = [NFTModel]()
        var gotError: Int = 0
        
        let gettingNFTs: DispatchGroup = DispatchGroup()
        
        idList?.forEach({ id in
            gettingNFTs.enter()
            
            servicesAssembly.nftService.loadNft(id: id) { result in
                switch result {
                case .success(let nft):
                    nftList.append(nft)
                    gettingNFTs.leave()
                    
                case .failure:
                    gotError += 1
                    gettingNFTs.leave()
                }
            }
        })
        
        gettingNFTs.notify(queue: .main) {
            self.myNFTs = nftList
            
            if gotError == idList?.count {
                self.alertInfo?(
                    NSLocalizedString(LocalizableKeys.profileMyNFTsLoadErrorTitle, comment: ""),
                    NSLocalizedString(LocalizableKeys.profileMyNFTsLoadErrorButton, comment: ""),
                    NSLocalizedString(LocalizableKeys.profileMyNFTsLoadErrorAll, comment: "")
                )
            } else if gotError > 0 {
                
                self.alertInfo?(
                    NSLocalizedString(LocalizableKeys.profileMyNFTsLoadErrorTitle, comment: ""),
                    NSLocalizedString(LocalizableKeys.profileMyNFTsLoadErrorButton, comment: ""),
                    NSLocalizedString(LocalizableKeys.profileMyNFTsLoadErrorSome, comment: "")
                )
            }
        }
    }
    
    func isFavorite(nftId: String) -> Bool {
        favoriteNFTs?.contains(nftId) ?? false
    }
    
    func setFaviriteNFTS(with list: [String]?) {
        self.favoriteNFTs = list
    }
    
    func changeFaforiteState(of nftId: String) {
        guard let favoriteNFTs else { return }
        var newProfileData: [(String, String)] = [(String, String)]()
        var newFavoriteList: [String] = [String]()
        
        if isFavorite(nftId: nftId) {
            newFavoriteList = favoriteNFTs.filter {
                $0 != nftId
            }
        } else {
            newFavoriteList = favoriteNFTs
            newFavoriteList.append(nftId)
        }
        
        if newFavoriteList.isEmpty {
            newProfileData.append(("likes", "null"))
        } else {
            newFavoriteList.forEach({
                newProfileData.append(("likes", $0))
            })
        }
        
        let profileData = Urlencoding.urlEncoded(formDataSet: newProfileData)
        
        servicesAssembly.profileService.saveProfile(profileData) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let profile):
                // TODO: Заменить использование моковых данных об NFT когда станут доступны реальные
//                getNFTs(by: ProfileService.mockNFTsData)
                getNFTs(by: profile.nfts)
                self.favoriteNFTs = profile.likes
                self.profile.send(profile)
            case .failure:
                self.alertInfo?(
                    NSLocalizedString(LocalizableKeys.profileMyNFTsLoadErrorTitle, comment: ""),
                    NSLocalizedString(LocalizableKeys.profileMyNFTsLoadErrorButton, comment: ""),
                    NSLocalizedString(LocalizableKeys.profileMyNFTloadErrorUpdateProfile, comment: "")
                )
            }
        }
    }
}
