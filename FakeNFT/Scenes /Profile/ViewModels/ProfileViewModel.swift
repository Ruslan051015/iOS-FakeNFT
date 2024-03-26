//
//  ProfileViewModel.swift
//  FakeNFT
//
//  Created by Eugene Dmitrichenko on 27.02.2024.
//

import Foundation
import Combine

final class ProfileViewModel {
    
    @Published var avatar: String?
    @Published var description: String?
    @Published var name: String?
    @Published var website: String?
    @Published var favoriteNFTs: [String]?
    @Published var myNFTs: [String]?
    
    @Published var profile = CurrentValueSubject<Profile?, Never>(nil)
    
    private let servicesAssembly: ServicesAssembly = ServicesAssembly(
        networkClient: DefaultNetworkClient(),
        nftStorage: NftStorageImpl()
    )
    private var subscriptions = Set<AnyCancellable>()
    
    var alertInfo: (( _ title: String, _ buttonTapped: String, _ message: String) -> Void)?
    
    init() {
        
        setupBindings()
        loadInitData()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func loadInitData() {
        
        servicesAssembly.profileService.loadProfile { [weak self] result in
            
            guard let self else { return }
            
            switch result {
            case .success(let profile):
                self.profile.send(profile)
            case .failure:
                self.alertInfo?(
                    NSLocalizedString(LocalizableKeys.profileMyNFTsLoadErrorTitle, comment: ""),
                    NSLocalizedString(LocalizableKeys.profileMyNFTsLoadErrorButton, comment: ""),
                    NSLocalizedString(LocalizableKeys.profileMyNFTloadErrorLoadProfile, comment: "")
                )
            }
        }
    }
    
    private func setupBindings() {
        
        profile.sink { [weak self] profile in
            guard let self else { return }
            self.avatar = profile?.avatar
            self.description = profile?.description
            self.name = profile?.name
            self.website = profile?.website
            self.favoriteNFTs = profile?.likes
            
            // FIXME: Используем мокковые данные пока в профиле отсутствуют реальные
            self.myNFTs = profile?.nfts
//            self.myNFTs = ProfileService.mockNFTsData
        }.store(in: &subscriptions)
    }
    
    func genEditViewModel() -> ProfileEditViewModel? {
        return ProfileEditViewModel(servicesAssembly: servicesAssembly, profile: profile)
    }
    
    func genMyNFTsViewModel() -> ProfileMyNFTsViewModel {
        return ProfileMyNFTsViewModel(servicesAssembly: servicesAssembly, profile: profile)
    }
    
    func getFavoriteNFTsViewModel() -> ProfileFavoriteNFTsViewModel {
        return ProfileFavoriteNFTsViewModel(servicesAssembly: servicesAssembly, profile: profile)
    }
}
