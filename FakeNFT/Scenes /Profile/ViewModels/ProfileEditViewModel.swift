//
//  ProfileEditViewModel.swift
//  FakeNFT
//
//  Created by Eugene Dmitrichenko on 01.03.2024.
//

import Foundation
import Combine

final class ProfileEditViewModel {
    
    @Published var avatar: String?
    @Published var description: String?
    @Published var favoriteNFTs: [String]?
    @Published var name: String?
    @Published var website: String?
    
    @Published var profile: CurrentValueSubject<Profile?, Never>
    
    private let servicesAssembly: ServicesAssembly
    
    private var editableProfile: Profile? {
        didSet {
            avatar = editableProfile?.avatar
            description = editableProfile?.description
            favoriteNFTs = editableProfile?.likes
            name = editableProfile?.name
            website = editableProfile?.website
            
            newAvatar = avatar
            newDescription = description
            newFavoriteNFTs = favoriteNFTs
            newName = name
            newWebsite = website
        }
    }
    
    var newAvatar: String?
    var newDescription: String?
    var newFavoriteNFTs: [String]?
    var newName: String?
    var newWebsite: String?
    
    var alertInfo: (
        (
            _ title: String,
            _ buttonTitle: String,
            _ message: String,
            _ shouldDismiss: Bool
        ) -> Void
    )?
    
    init(servicesAssembly: ServicesAssembly, profile: CurrentValueSubject<Profile?, Never>) {
        self.servicesAssembly = servicesAssembly
        self.profile = profile
        
        self.setProfile(with: profile.value)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setProfile(with originProfile: Profile?) {
        self.editableProfile = originProfile
    }
    
    func saveProfile() {
        var newProfileData: [(String, String)] = [(String, String)]()
        
        newProfileData.append(("avatar", newAvatar ?? ""))
        newProfileData.append(("description", newDescription ?? ""))
        newProfileData.append(("name", newName ?? ""))
        newProfileData.append(("website", newWebsite ?? ""))
        if let favorites = newFavoriteNFTs, favorites.count  > 0 {
            favorites.forEach({
                newProfileData.append(("likes", $0))
            })
        }
        
        let profileData = Urlencoding.urlEncoded(formDataSet: newProfileData)
        
        servicesAssembly.profileService.saveProfile(profileData) { [weak self] result in
            guard let self else { return }
            
            switch result {
            case .success(let profile):
                self.profile.send(profile)
                
                self.alertInfo?(
                    NSLocalizedString(LocalizableKeys.profileEditUpdateDone, comment: ""),
                    NSLocalizedString(LocalizableKeys.profileEditUpdateGreat, comment: ""),
                    NSLocalizedString(LocalizableKeys.profileEditUpdateChangesAreMade, comment: ""),
                    true
                )
                
            case .failure:
                self.alertInfo?(
                    NSLocalizedString(LocalizableKeys.profileMyNFTsLoadErrorTitle, comment: ""),
                    NSLocalizedString(LocalizableKeys.profileMyNFTsLoadErrorButton, comment: ""),
                    NSLocalizedString(LocalizableKeys.profileMyNFTloadErrorUpdateProfile, comment: ""),
                    false
                    )
            }
        }
    }
}
