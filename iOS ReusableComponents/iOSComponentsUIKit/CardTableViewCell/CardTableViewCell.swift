//
//  CardTableViewCell.swift
//  iOSComponentsUIKitTests
//
//  Created by David Castro Cisneros on 13/03/22.
//

import UIKit

public final class CardTableViewCell: UITableViewCell {
    public private(set) lazy var titleLabel: UILabel = .makeBold(size: 24)
    public private(set) lazy var descriptionLabel: UILabel = .makeWithUnlimitedLines(size: 10)
    public private(set) lazy var footerLabel: UILabel = .makeBold(size: 12)
    public private(set) lazy var cardImageView: UIImageView = .makeRounded()
    public private(set) lazy var content: UIView = .make(corners: [.layerMaxXMaxYCorner, .layerMaxXMinYCorner])
    public private(set) lazy var retryButton: UIButton = makeRetryButton()

    public var onRetry: (() -> Void)?

    public override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addViews()
        addConstraints()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    public func configure(viewModel: CardViewModel) {
        titleLabel.text = viewModel.description
        descriptionLabel.text = viewModel.title
        footerLabel.text = viewModel.footer
    }

    public func setImage(_ image: UIImage) {
        cardImageView.image = image
    }

    public func setStyle(_ style: CardStyle) {
        titleLabel.textColor = style.titleColor
        descriptionLabel.textColor = style.descriptionColor
        footerLabel.textColor = style.footerColor
        contentView.backgroundColor = style.contentBackgroundColor
        content.backgroundColor = style.backgroundColor
    }

    @objc private func didTapRetryButton() {
        onRetry?()
    }
}

// MARK: - Helpers

private extension CardTableViewCell {
    private func addViews() {
        content.addSubview(titleLabel)
        content.addSubview(descriptionLabel)
        content.addSubview(footerLabel)

        let verticalStack = UIStackView(arrangedSubviews: [UIView(), content])
        verticalStack.axis = .vertical

        let stack = UIStackView(arrangedSubviews: [cardImageView, verticalStack])
        stack.spacing = CGFloat.mediumSpace.negativeValue
        stack.bringSubviewToFront(cardImageView)

        contentView.addSubview(stack)
        verticalStack.anchor(top:  cardImageView.topAnchor, bottom: cardImageView.bottomAnchor)
        stack.anchor(top: contentView.topAnchor,
                     leading: contentView.leadingAnchor,
                     bottom: contentView.bottomAnchor,
                     trailling: contentView.trailingAnchor,
                     paddingTop: 0,
                     paddingLeft: .defaultSpace,
                     paddingBottom: .defaultSpace,
                     paddingRight: .defaultSpace)

        contentView.addSubview(retryButton)
    }

    private func makeRetryButton() -> UIButton {
        let button: UIButton = .makeRefreshButton()
        button.isHidden = true

        button.addTarget(self, action: #selector(didTapRetryButton), for: .touchUpInside)
        return button
    }
}

private extension CardTableViewCell {
    private func addConstraints() {
        addResistanceCompression()
        addProportionToCardImage()
        layoutCardContent()
        layoutRetryButton()
    }

    private func layoutRetryButton() {
        retryButton.addConstraintsToFillView(cardImageView)
    }

    private func addResistanceCompression() {
//        cardImageView.setContentHuggingPriority(.defaultHigh, for: .vertical)
//        content.setContentCompressionResistancePriority(.defaultLow/, for: .vertical)
    }

    private func addProportionToCardImage() {
        let proportionRelativeToParent: CGFloat = 0.35
        let aspectRatio: CGFloat = 1.5

        NSLayoutConstraint.activate([
            cardImageView.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: proportionRelativeToParent),
            cardImageView.heightAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: proportionRelativeToParent*aspectRatio),
            content.heightAnchor.constraint(equalTo: cardImageView.heightAnchor, multiplier: 0.9)
        ])

    }

    private func layoutCardImage() {
        cardImageView.anchor(top: contentView.topAnchor,
                             leading: contentView.leadingAnchor,
                             bottom: contentView.bottomAnchor,
                             paddingLeft: .defaultSpace)
    }

    private func layoutCardContent() {
        titleLabel.anchor(top: content.topAnchor,
                          leading: content.leadingAnchor,
                          trailling: content.trailingAnchor,
                          paddingTop: .mediumSpace,
                          paddingLeft: .extraLargeSpace,
                          paddingRight: .smallSpace)

        descriptionLabel.anchor(top: titleLabel.bottomAnchor,
                                leading: content.leadingAnchor,
                                trailling: content.trailingAnchor,
                                paddingTop: .smallSpace,
                                paddingLeft: .extraLargeSpace,
                                paddingRight: .smallSpace)

        footerLabel.anchor(leading: content.leadingAnchor,
                           bottom: cardImageView.bottomAnchor,
                           trailling: content.trailingAnchor,
                           paddingLeft: .extraLargeSpace,
                           paddingBottom: .mediumSpace,
                           paddingRight: .smallSpace)
    }
}

extension UIView {
    func aspectRation(_ ratio: CGFloat) -> NSLayoutConstraint {

        return NSLayoutConstraint(item: self, attribute: .height, relatedBy: .equal, toItem: self, attribute: .width, multiplier: ratio, constant: 0)
    }
}
