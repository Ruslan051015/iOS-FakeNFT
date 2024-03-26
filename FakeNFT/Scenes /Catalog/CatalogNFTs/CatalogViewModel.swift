//
//  CatalogViewModel.swift
//  FakeNFT
//
//  Created by Георгий Ксенодохов on 15.02.2024.
//

import Foundation

class CatalogViewModel {

    var change: (() -> Void)?

    var showError: (() -> Void)?

    private var catalogService = CatalogService()

    private(set) var nfts: [CatalogCollection] = [] {
        didSet {
            change?()
        }
    }

    private var isLoading = false

    func loadNft() {
        guard isLoading != true else {
            return
        }
        catalogService.loadNftColletion { [weak self] result in
            self?.isLoading = true
            switch result {
            case .success(let nfts):
                self?.nfts = nfts
            case .failure:
                self?.showError?()
            }
            self?.isLoading = false
        }
    }

    func filterNfts(by filter: NFTFilter) {
        switch filter {
        case .byNftCount:
            nfts = nfts.sorted { $0.nfts.count > $1.nfts.count }
        case .byNftName:
            nfts = nfts.sorted { $0.name > $1.name }
        }
    }

    func collectionViewId(index: IndexPath) -> String {
        nfts[index.row].id
    }

}

enum NFTFilter {
    case byNftCount
    case byNftName
}
