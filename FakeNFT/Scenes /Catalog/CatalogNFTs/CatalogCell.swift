import UIKit
import SnapKit
import Kingfisher

final class CatalogCell: UITableViewCell {

    static let cellId = "CatalogCell"

    private let nftImageView: UIImageView = {
        var image = UIImageView()
        image.clipsToBounds = true
        image.contentMode = .scaleAspectFill
        image.layer.cornerRadius = 12
        return image
    }()

    private let nftLable: UILabel = {
        var label = UILabel()
        label.textColor = UIColor(named: "BlackColor")
        label.font = .bodyBold
        return label
    }()

    func config(nft: CatalogCollection) {
        setupScreen()
        nftLable.text = "\(nft.name.first!.uppercased())" +
        nft.name.suffix(nft.name.count - 1) +
        " (\(nft.nfts.count))"
        nftImageView.kf.setImage(with: URL(string: nft.cover))
    }

    private func setupScreen() {
        contentView.addSubview(nftImageView)
        contentView.addSubview(nftLable)
        selectionStyle = .none
        backgroundColor = .systemBackground

        nftImageView.snp.makeConstraints {
            $0.height.equalTo(140)
            $0.top.equalToSuperview()
            $0.left.equalToSuperview().offset(16)
            $0.right.equalToSuperview().offset(-16)
        }

        nftLable.snp.makeConstraints {
            $0.left.right.equalTo(nftImageView)
            $0.top.equalTo(nftImageView.snp_bottomMargin).offset(10)
        }
    }
}
