import UIKit
import SnapKit

class CatalogView: UIViewController {
  
  private var viewModel = CatalogViewModel()
  
  private let tableView: UITableView = {
    var table = UITableView()
    table.tableHeaderView = UIView()
    table.showsVerticalScrollIndicator = false
    table.rowHeight = 179
    return table
  }()
  
  private lazy var sortButton: UIButton = {
    var button = UIButton()
    button.setImage(Asset.CustomIcons.sortIcon.image, for: .normal)
    button.tintColor = Asset.CustomColors.ypBlack.color
    button.addTarget(self, action: #selector(filterButtonTapped), for: .touchUpInside)
    return button
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    bind()
    errorBind()
    UIBlockingProgressHUD.show()
    tableView.delegate = self
    tableView.dataSource = self
    tableView.register(CatalogCell.self, forCellReuseIdentifier: CatalogCell.cellId)
    view.backgroundColor = .systemBackground
    view.addSubview(tableView)
    setupScreen()
    loadNfts()
  }
  override func viewDidAppear(_ animated: Bool) {
    navigationController?.navigationBar.isTranslucent = false
  }
  
  @objc
  private func filterButtonTapped() {
    let filter = UIAlertController(title: NSLocalizedString("Sorting",
                                                            comment: ""),
                                   message: "",
                                   preferredStyle: .actionSheet)
    let filterByNftCount = UIAlertAction(title: NSLocalizedString("sorting.byCountOfNft",
                                                                  comment: ""),
                                         style: .default) { _ in
      self.viewModel.filterNfts(by: .byNftCount)
      self.tableView.reloadData()
    }
    let filterByNftName = UIAlertAction(title: NSLocalizedString("sorting.byName",
                                                                 comment: ""),
                                        style: .default) { _ in
      self.viewModel.filterNfts(by: .byNftName)
      self.tableView.reloadData()
    }
    let closeAction = UIAlertAction(title: NSLocalizedString("CloseAction",
                                                             comment: ""),
                                    style: .cancel,
                                    handler: nil)
    filter.addAction(filterByNftName)
    filter.addAction(filterByNftCount)
    filter.addAction(closeAction)
    present(filter, animated: true)
  }
  
  private func loadNfts() {
    viewModel.loadNft()
  }
  
  private func bind() {
    viewModel.change = {
      self.tableView.reloadData()
      UIBlockingProgressHUD.hide()
    }
  }
  
  private func errorBind() {
    viewModel.showError = {
      self.showError(ErrorModel(message: NSLocalizedString("Error.network", comment: ""),
                                actionText: NSLocalizedString("Error.repeat", comment: ""),
                                action: self.loadNfts))
    }
  }
  
  private func setupScreen() {
    tableView.backgroundColor = .systemBackground
    view.backgroundColor = .systemBackground
    navigationController?.navigationBar.setBackgroundImage(UIImage(), for: .default)
    navigationController?.navigationBar.shadowImage = UIImage()
    navigationItem.rightBarButtonItem = UIBarButtonItem(customView: sortButton)
    navigationController?.navigationBar.barTintColor = UIColor(named: "WhiteColor")
    navigationController?.navigationBar.tintColor = UIColor(named: "BlackColor")
    navigationItem.title = ""
    tableView.snp.makeConstraints {
      $0.left.top.right.bottom.equalToSuperview()
    }
  }
}

extension CatalogView: UITableViewDataSource {
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return viewModel.nfts.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    let cell = tableView.dequeueReusableCell(withIdentifier: CatalogCell.cellId,
                                             for: indexPath) as? CatalogCell
    cell?.config(nft: viewModel.nfts[indexPath.row])
    cell?.separatorInset = .init(top: 0, left: tableView.frame.width / 2,
                                 bottom: 0, right: tableView.frame.width / 2)
    return cell ?? UITableViewCell()
  }
  
}

extension CatalogView: UITableViewDelegate {
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let id = viewModel.collectionViewId(index: indexPath)
    let view = CatalogNftCollectionView(nibName: nil, bundle: nil, id: id)
    navigationController?.pushViewController(view, animated: true)
  }
}

extension CatalogView: ErrorView {}
