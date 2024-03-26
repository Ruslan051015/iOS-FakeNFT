import UIKit
import SnapKit

protocol CatalogCollectionCellDelegate: AnyObject {
  func tapOnLike(id: String)
  func tapOnCart(id: String)
}

final class CatalogNftCollectionView: UIViewController {
  
  var id: String?
  
  private var viewModel = CatalogCollectionViewModel()
  
  private var scrollView: UIScrollView = {
    var scroll = UIScrollView()
    scroll.showsVerticalScrollIndicator = false
    scroll.contentInsetAdjustmentBehavior = .never
    return scroll
  }()
  
  private var imageView: UIImageView = {
    var image = UIImageView()
    image.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMaxXMaxYCorner]
    image.contentMode = .scaleToFill
    image.clipsToBounds = true
    image.layer.cornerRadius = 12
    return image
  }()
  
  private var nameOfNFTCollectionLabel: UILabel = {
    var label = UILabel()
    label.font = .headline3
    label.textColor = UIColor(named: "BlackColor")
    return label
  }()
  
  private var nameOfAuthor: UILabel = {
    var label = UILabel()
    label.font = .caption2
    label.text = NSLocalizedString("nameOfAuthor.text", comment: "")
    label.isHidden = true
    label.textColor = UIColor(named: "BlackColor")
    return label
  }()
  
  private lazy var nameOfAuthorButton: UIButton = {
    var button = UIButton()
    button.titleLabel?.font = .caption2
    button.setTitleColor(.systemBlue, for: .normal)
    button.addTarget(self, action: #selector(tapOnAuthorButton), for: .touchUpInside)
    return button
  }()
  
  private var nftDescription: UILabel = {
    var label = UILabel()
    label.font = .caption2
    label.numberOfLines = 0
    label.textColor = UIColor(named: "BlackColor")
    return label
  }()
  
  private var collectionView: UICollectionView = {
    var collection = UICollectionView(frame: .zero, collectionViewLayout: UICollectionViewFlowLayout())
    collection.backgroundColor = .systemBackground
    collection.contentInset = UIEdgeInsets(top: 6, left: 0, bottom: 24, right: 0)
    return collection
  }()
  
  convenience init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?, id: String) {
    self.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    viewModel.id = id
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    collectionView.register(CatalogCollectionCell.self,
                            forCellWithReuseIdentifier: CatalogCollectionCell.catalofNftId)
    setupScreen()
    collectionView.dataSource = self
    collectionView.delegate = self
    bind()
    navigationController?.navigationBar.isTranslucent = true
    UIBlockingProgressHUD.show()
    viewModel.loadNft()
  }
  
  override func viewWillDisappear(_ animated: Bool) {
    super.viewWillDisappear(animated)
    UIBlockingProgressHUD.hide()
  }
  
  @objc
  private func tapOnAuthorButton() {
    let view = AboutAuthorView()
    view.url = viewModel.authorUrl
    navigationController?.pushViewController(view, animated: true)
  }
  
  private func bind() {
    viewModel.showError = {
      self.showError(ErrorModel(message: NSLocalizedString("Error.network", comment: ""),
                                actionText: NSLocalizedString("Error.repeat", comment: ""),
                                action: { self.viewModel.loadNft()})
      )
    }
    viewModel.collectionChange = {
      UIBlockingProgressHUD.hide()
      self.collectionView.reloadData()
    }
    viewModel.imageChange = {
      self.imageView.kf.setImage(with: self.viewModel.imageURL)
    }
    viewModel.descriptionChange = {
      self.nftDescription.text = self.viewModel.nftDescription
    }
    viewModel.nameOfAuthorChange = {
      self.nameOfAuthorButton.setTitle(self.viewModel.nameOfAuthor, for: .normal)
      self.nameOfAuthor.isHidden = false
    }
    viewModel.nameOfNFTCollectionChange = {
      self.nameOfNFTCollectionLabel.text = self.viewModel.nameOfNFTCollection
    }
  }
  
  private func setupScreen() {
    view.addSubview(scrollView)
    [imageView,
     nameOfNFTCollectionLabel,
     nameOfAuthor,
     nameOfAuthorButton,
     nftDescription,
     collectionView].forEach {
      self.scrollView.addSubview($0)
    }
    scrollView.snp.makeConstraints {
      $0.left.right.top.bottom.equalToSuperview()
    }
    imageView.snp.makeConstraints {
      $0.top.left.equalToSuperview()
      $0.height.equalTo(310)
      $0.width.equalToSuperview()
    }
    nameOfNFTCollectionLabel.snp.makeConstraints {
      $0.top.equalTo(imageView.snp_bottomMargin).offset(20)
      $0.left.equalToSuperview().offset(16)
      $0.right.equalToSuperview().offset(-16)
      $0.width.equalToSuperview().offset(-32)
    }
    nameOfAuthor.snp.makeConstraints {
      $0.top.equalTo(nameOfNFTCollectionLabel.snp_bottomMargin).offset(20)
      $0.height.equalTo(28)
      $0.left.equalToSuperview().offset(16)
    }
    nameOfAuthorButton.snp.makeConstraints {
      $0.top.equalTo(nameOfNFTCollectionLabel.snp_bottomMargin).offset(20)
      $0.height.equalTo(28)
      $0.left.equalTo(nameOfAuthor.snp_rightMargin).offset(10)
    }
    nftDescription.snp.makeConstraints {
      $0.top.equalTo(nameOfAuthor.snp_bottomMargin).offset(15)
      $0.left.equalToSuperview().offset(16)
      $0.right.equalToSuperview().offset(-16)
      $0.width.equalToSuperview().offset(-32)
    }
    collectionView.snp.makeConstraints {
      $0.top.equalTo(nftDescription.snp_bottomMargin).offset(15)
      $0.left.equalToSuperview().offset(16)
      $0.right.equalToSuperview().offset(-16)
      $0.height.equalTo(500)
      $0.bottom.equalToSuperview()
    }
    view.backgroundColor = .systemBackground
    navigationItem.title = ""
  }
}

extension CatalogNftCollectionView: ErrorView {}

extension CatalogNftCollectionView: UICollectionViewDataSource {
  
  func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
    viewModel.colletotionData.count
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
    let cell = collectionView.dequeueReusableCell(withReuseIdentifier: CatalogCollectionCell.catalofNftId,
                                                  for: indexPath) as? CatalogCollectionCell
    cell?.isOnCart = viewModel.cartCollection.contains(where: { id in
      id == viewModel.colletotionData[indexPath.row].id
    })
    cell?.isLike = viewModel.likesCollection.contains(where: { id in
      id == viewModel.colletotionData[indexPath.row].id
    })
    cell?.config(viewModel.colletotionData[indexPath.row])
    cell?.delegate = self
    return cell ?? UICollectionViewCell()
  }
  
}

extension CatalogNftCollectionView: UICollectionViewDelegateFlowLayout {
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      sizeForItemAt indexPath: IndexPath) -> CGSize {
    CGSize(width: 108, height: 192)
  }
  
  func collectionView(_ collectionView: UICollectionView,
                      layout collectionViewLayout: UICollectionViewLayout,
                      minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
    5
  }
  
  func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
    let view = NftView()
    navigationController?.pushViewController(view, animated: true)
  }
}

extension CatalogNftCollectionView: CatalogCollectionCellDelegate {
  func tapOnCart(id: String) {
    viewModel.putNft(id: id)
  }
  
  func tapOnLike(id: String) {
    viewModel.putLikes(id: id)
  }
}
