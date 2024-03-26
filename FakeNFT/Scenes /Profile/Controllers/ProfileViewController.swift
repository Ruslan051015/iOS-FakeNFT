import UIKit
import Combine
import Kingfisher
import ProgressHUD

final class ProfileViewController: UIViewController {
  
  let profileViewModel: ProfileViewModel
  
  private var subscriptions = Set<AnyCancellable>()
  private var website: String?
  private var favoriteNFTs: [String]?
  private var myNFTIDs: [String]?
  
  private lazy var buttonUserPage: UIButton = {
    let button = UIButton()
    button.setTitleColor(UIColor(named: ColorNames.blue), for: .normal)
    button.contentHorizontalAlignment = .leading
    return button
  }()
  
  private lazy var imageViewUserPicture: UIImageView = {
    let imageView = UIImageView()
    imageView.contentMode = .scaleAspectFill
    imageView.layer.cornerRadius = 35
    imageView.clipsToBounds = true
    imageView.backgroundColor = UIColor(named: ColorNames.lightGray)
    return imageView
  }()
  
  private lazy var labelUserName: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 22, weight: .bold)
    label.numberOfLines = 1
    label.adjustsFontSizeToFitWidth = true
    return label
  }()
  
  private lazy var tableView: UITableView = {
    let table = UITableView()
    table.delegate = self
    table.dataSource = self
    table.register(ProfileTableViewCell.self, forCellReuseIdentifier: ProfileTableViewCell.reuseIdentifier)
    table.isScrollEnabled = false
    return table
  }()
  
  private lazy var textViewDescription: UITextView = {
    let textView = UITextView()
    textView.font = UIFont.systemFont(ofSize: 13, weight: .regular)
    textView.textContainer.maximumNumberOfLines = 3
    textView.isEditable = false
    textView.backgroundColor = UIColor(named: ColorNames.white)
    return textView
  }()
  
  init(profileViewModel: ProfileViewModel) {
    self.profileViewModel = profileViewModel
    super.init(nibName: nil, bundle: nil)
    
    setupBindings()
  }
  
  required init?(coder: NSCoder) {
    fatalError("init(coder:) has not been implemented")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    setupUIElements()
    setupUILayout()
    UIBlockingProgressHUD.show()
  }
  
  @objc
  private func buttonEditTapped() {
    if let profileEditViewModel = profileViewModel.genEditViewModel() {
      let editVC = ProfileEditViewController(profileEditViewModel: profileEditViewModel)
      present(editVC, animated: true)
    }
  }
  
  private func setupBindings() {
    profileViewModel.$avatar.sink(receiveValue: { [weak self] avatar in
      
      UIBlockingProgressHUD.hide()
      
      if let self, let url = avatar, let imageUrl = URL(string: url) {
        let roundCornerEffect = RoundCornerImageProcessor(cornerRadius: 8.0)
        self.imageViewUserPicture.kf.indicatorType = .activity
        self.imageViewUserPicture.kf.setImage(with: imageUrl, options: [.processor(roundCornerEffect)])
      }
    }).store(in: &subscriptions)
    
    profileViewModel.$description.sink(receiveValue: { [weak self] description in
      self?.textViewDescription.text = description
    }).store(in: &subscriptions)
    
    profileViewModel.$favoriteNFTs.sink(receiveValue: { [weak self] favoriteNFTs in
      self?.favoriteNFTs = favoriteNFTs
    }).store(in: &subscriptions)
    
    profileViewModel.$myNFTs.sink(receiveValue: { [weak self] myNFTs in
      self?.myNFTIDs = myNFTs
      self?.tableView.reloadData()
    }).store(in: &subscriptions)
    
    profileViewModel.$name.sink(receiveValue: { [weak self] name in
      self?.labelUserName.text = name
    }).store(in: &subscriptions)
    
    profileViewModel.$website.sink(receiveValue: { [weak self] website in
      self?.website = website
      self?.buttonUserPage.setTitle(website, for: .normal)
    }).store(in: &subscriptions)
    
    profileViewModel.alertInfo = {[weak self] (title, buttonTitle, message) in
      guard let self else { return }
      let action = UIAlertAction(title: buttonTitle, style: .cancel)
      AlertPresenterProfile.shared.presentAlert(title: title, message: message, actions: [action], target: self)
    }
  }
  
  private func setupUIElements() {
    view.backgroundColor = UIColor(named: ColorNames.white)
    
    let editButton = UIBarButtonItem(image: UIImage(named: ImageNames.buttonEdit), style: .plain, target: self, action: #selector(buttonEditTapped))
    editButton.tintColor = UIColor(named: ColorNames.black)
    
    let backButton = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    backButton.tintColor = UIColor(named: ColorNames.black)
    
    navigationItem.rightBarButtonItem = editButton
    navigationItem.backBarButtonItem = backButton
    
    [imageViewUserPicture, labelUserName, textViewDescription, buttonUserPage, tableView].forEach {
      $0.translatesAutoresizingMaskIntoConstraints = false
      view.addSubview($0)
    }
    buttonUserPage.addTarget(self, action: #selector(userPageTapped), for: .touchUpInside)
    tableView.separatorColor = .clear
  }
  
  private func setupUILayout() {
    NSLayoutConstraint.activate([
      imageViewUserPicture.heightAnchor.constraint(equalToConstant: 70),
      imageViewUserPicture.widthAnchor.constraint(equalToConstant: 70),
      imageViewUserPicture.topAnchor.constraint(equalTo: view.topAnchor, constant: 108),
      imageViewUserPicture.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      labelUserName.leadingAnchor.constraint(equalTo: imageViewUserPicture.trailingAnchor, constant: 16),
      labelUserName.centerYAnchor.constraint(equalTo: imageViewUserPicture.centerYAnchor),
      labelUserName.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      textViewDescription.heightAnchor.constraint(equalToConstant: 80),
      textViewDescription.topAnchor.constraint(equalTo: imageViewUserPicture.bottomAnchor, constant: 16),
      textViewDescription.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      textViewDescription.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      buttonUserPage.heightAnchor.constraint(equalToConstant: 40),
      buttonUserPage.topAnchor.constraint(equalTo: textViewDescription.bottomAnchor, constant: 16),
      buttonUserPage.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 16),
      buttonUserPage.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -16),
      tableView.heightAnchor.constraint(equalToConstant: 54 * 3),
      tableView.topAnchor.constraint(equalTo: buttonUserPage.bottomAnchor, constant: 50),
      tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 0),
      tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: 0)
    ])
  }
  
  @objc
  private func userPageTapped() {
    let webController = ProfileWebViewController()
    webController.hidesBottomBarWhenPushed = true
    if let website = self.website {
      webController.userSite = website
      self.navigationController?.pushViewController(webController, animated: true)
    }
  }
}

extension ProfileViewController: UITableViewDelegate {
  func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
    54
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    
    tableView.deselectRow(at: indexPath, animated: true)
    
    var viewController: UIViewController?
    
    switch indexPath.row {
    case 0:
      let myNFTsViewModel = profileViewModel.genMyNFTsViewModel()
      myNFTsViewModel.getNFTs(by: myNFTIDs)
      myNFTsViewModel.setFaviriteNFTS(with: favoriteNFTs)
      viewController = ProfileMyNFTsController(myNFTsViewModel: myNFTsViewModel)
    case 1:
      let favoriteNFTsViewModel = profileViewModel.getFavoriteNFTsViewModel()
      favoriteNFTsViewModel.getNFTs(by: favoriteNFTs)
      viewController = ProfileFavoriteNFTsController(favoriteNFTsViewModel: favoriteNFTsViewModel)
    default:
      userPageTapped()
      return
    }
    
    guard let viewController = viewController else { return }
    self.navigationController?.pushViewController(viewController, animated: true)
  }
}

extension ProfileViewController: UITableViewDataSource {
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    3
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    
    let cell = tableView.dequeueReusableCell(withIdentifier: ProfileTableViewCell.reuseIdentifier, for: indexPath)
    
    switch indexPath.row {
    case 0:
      let number = myNFTIDs?.count ?? 0
      cell.textLabel?.text =
      NSLocalizedString(LocalizableKeys.profileMyNFTs, comment: "") +
      " (\(number.description))"
    case 1:
      let number = favoriteNFTs?.count ?? 0
      cell.textLabel?.text =
      NSLocalizedString(LocalizableKeys.profileFavoriteNFTs, comment: "") +
      " (\(number.description))"
    default:
      cell.textLabel?.text =
      NSLocalizedString(LocalizableKeys.profileAbout, comment: "")
    }
    
    return cell
  }
}
