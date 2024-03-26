//
//  ProfileMyNFTsController.swift
//  FakeNFT
//
//  Created by Eugene Dmitrichenko on 24.02.2024.
//

import Combine
import ProgressHUD
import UIKit

protocol LikerProtocol: AnyObject {
  func changeFavoriteState(of nftId: String)
}

final class ProfileMyNFTsController: UIViewController {
  
  enum OrderProperty: String {
    case name = "name"
    case prise = "price"
    case rating = "rating"
  }
  
  private var gotNFTsData: Bool = false {
    didSet {
      UIBlockingProgressHUD.hide()
    }
  }
  private var myNFTs: [NFTModel] = [NFTModel]()
  private var myNFTsSortedBy: OrderProperty = .name
  private let myNFTsViewModel: ProfileMyNFTsViewModel
  private var subscriptions = Set<AnyCancellable>()
  
  private lazy var tableView: UITableView = {
    let table = UITableView()
    table.backgroundView = ProfileNFTsTableBackgroundView(frame: .zero, nftsType: .myNFTs)
    table.backgroundColor = UIColor(named: ColorNames.white)
    table.translatesAutoresizingMaskIntoConstraints = false
    table.delegate = self
    table.dataSource = self
    table.register(ProfileMyNFTsTableViewCell.self, forCellReuseIdentifier: ProfileMyNFTsTableViewCell.reuseIdentifier)
    table.separatorStyle = .none
    return table
  }()
  
  init(myNFTsViewModel: ProfileMyNFTsViewModel) {
    self.myNFTsViewModel = myNFTsViewModel
    super.init(nibName: nil, bundle: nil)
    
    setupBindings()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUI()
    setupUILayout()
  }
  
  @objc
  private func sortNFTsButtonTapped() {
    guard myNFTs.count > 0 else { return }
    
    let actionSortByPrice = UIAlertAction(
      title: NSLocalizedString(LocalizableKeys.profileMyNFTsSortByPrice, comment: ""),
      style: .default
    ) { [weak self] _ in
      self?.myNFTsSortedBy = .prise
      self?.sortNFTList(by: .prise)
    }
    let actionSortByRating = UIAlertAction(
      title: NSLocalizedString(LocalizableKeys.profileMyNFTsSortByRating, comment: ""),
      style: .default
    ) { [weak self] _ in
      self?.myNFTsSortedBy = .rating
      self?.sortNFTList(by: .rating)
    }
    let actionSortByName = UIAlertAction(
      title: NSLocalizedString(LocalizableKeys.profileMyNFTsSortByName, comment: ""),
      style: .default
    ) { [weak self] _ in
      self?.myNFTsSortedBy = .name
      self?.sortNFTList(by: .name)
    }
    let actionClose = UIAlertAction(
      title: NSLocalizedString(LocalizableKeys.profileMyNFTsSortByClose, comment: ""),
      style: .cancel
    )
    AlertPresenterProfile.shared.presentAlert(
      title: "",
      message: NSLocalizedString(LocalizableKeys.profileMyNFTsSortTitle, comment: ""),
      actions: [actionSortByPrice, actionSortByRating, actionSortByName, actionClose],
      target: self,
      preferredStyle: .actionSheet
    )
  }
  
  private func setupBindings() {
    myNFTsViewModel.$myNFTs.sink(receiveValue: { [weak self] list in
      guard let self else { return }
      if let nftList = list {
        self.myNFTs = nftList
        self.sortNFTList(by: myNFTsSortedBy)
        self.tableView.reloadData()
        self.gotNFTsData = true
      }
    }).store(in: &subscriptions)
    
    myNFTsViewModel.alertInfo = { [weak self] (title, buttonTitle, message) in
      guard let self else { return }
      let action = UIAlertAction(title: buttonTitle, style: .cancel)
      AlertPresenterProfile.shared.presentAlert(title: title, message: message, actions: [action], target: self)
    }
  }
  
  private func setupUI() {
    title = NSLocalizedString(LocalizableKeys.profileMyNFTs, comment: "")
    
    let editButton = UIBarButtonItem(image: UIImage(named: ImageNames.buttonSort),
                                     style: .plain,
                                     target: self,
                                     action: #selector(sortNFTsButtonTapped))
    editButton.tintColor = UIColor(named: ColorNames.black)
    
    navigationItem.rightBarButtonItem = editButton
    
    view.backgroundColor = UIColor(named: ColorNames.white)
    view.addSubview(tableView)
    if gotNFTsData == false {
      UIBlockingProgressHUD.show()
    }
  }
  
  private func setupUILayout() {
    NSLayoutConstraint.activate([
      tableView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 0),
      tableView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 0),
      tableView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: 0),
      tableView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: 0)
    ])
  }
  
  private func sortNFTList(by property: OrderProperty) {
    switch property {
    case .name:
      myNFTs = myNFTs.sorted { $0.name < $1.name }
    case .prise:
      myNFTs = myNFTs.sorted { $0.price < $1.price }
    case .rating:
      myNFTs = myNFTs.sorted { $0.rating < $1.rating }
    }
    tableView.reloadData()
  }
}

extension ProfileMyNFTsController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    140
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    tableView.deselectRow(at: indexPath, animated: true)
  }
}

extension ProfileMyNFTsController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    
    let number = myNFTs.count
    tableView.backgroundView?.isHidden = number > 0
    
    return number
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: ProfileMyNFTsTableViewCell.reuseIdentifier) as? ProfileMyNFTsTableViewCell ?? ProfileMyNFTsTableViewCell()
    let nft = myNFTs[indexPath.row]
    cell.setup(with: nft, isFavofite: myNFTsViewModel.isFavorite(nftId: nft.id), delegateTo: self)
    return cell
  }
}

extension ProfileMyNFTsController: LikerProtocol {
  func changeFavoriteState(of nftId: String) {
    UIBlockingProgressHUD.show()
    myNFTsViewModel.changeFaforiteState(of: nftId)
  }
}
