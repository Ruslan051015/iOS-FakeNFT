//
//  ProfileFavoriteNFTsViewModel.swift
//  FakeNFT
//
//  Created by Eugene Dmitrichenko on 12.03.2024.
//

import Combine
import Foundation

final class ProfileFavoriteNFTsViewModel {
    
    @Published var favoriteNFTs: [NFTModel]?
    @Published var profile: CurrentValueSubject<Profile?, Never>
    
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
//        var nftList: [Nft] = [Nft]()
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
            self.favoriteNFTs = nftList
            
            if gotError > 0 {
                self.alertInfo?(
                    NSLocalizedString(LocalizableKeys.profileMyNFTsLoadErrorTitle, comment: ""),
                    NSLocalizedString(LocalizableKeys.profileMyNFTsLoadErrorButton, comment: ""),
                    NSLocalizedString(LocalizableKeys.profileMyNFTsLoadErrorSome, comment: "")
                )
            }
        }
    }
    
    func saveProfileLikes(with likes: [String]) {
        var newProfileData: [(String, String)] = [(String, String)]()
        
        if !likes.isEmpty {
            likes.forEach({
                newProfileData.append(("likes", $0))
            })
        } else {
            newProfileData.append(("likes", "null"))
        }
        
        let profileData = Urlencoding.urlEncoded(formDataSet: newProfileData)
        
        servicesAssembly.profileService.saveProfile(profileData) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let profile):
                getNFTs(by: profile.likes)
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
