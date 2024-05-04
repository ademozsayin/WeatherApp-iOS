import UIKit

// Imported from WordPress iOS - https://github.com/wordpress-mobile/WordPress-iOS/blob/trunk/WordPress/Classes/ViewRelated/Feature%20Highlight/Tooltip.swift

import FiableFoundation

final class Tooltip: UIView {
    private static let arrowWidth: CGFloat = 17

    private enum Constants {
        static let leadingIconUnicode = "✨"
        static let cornerRadius: CGFloat = 4
        static let arrowTipYLength: CGFloat = 8
        static let arrowTipYControlLength: CGFloat = 9

        enum Spacing {
            static let contentStackViewInterItemSpacing: CGFloat = 4
            static let buttonsStackViewInterItemSpacing: CGFloat = 16
            static let contentStackViewTop: CGFloat = 12
            static let contentStackViewBottom: CGFloat = 4
            static let contentStackViewHorizontal: CGFloat = 16
            static let superHorizontalMargin: CGFloat = 32
            static let buttonStackViewHeight: CGFloat = 40
        }
    }

    enum ButtonAlignment {
        case left
        case right
    }

    enum ArrowPosition {
        case top
        case bottom
    }

    /// Determines whether a leading icon for the title, should be placed or not.
    var shouldPrefixLeadingIcon: Bool = true {
        didSet {
            guard let title = title else { return }

            Self.updateTitleLabel(
                titleLabel,
                with: title,
                shouldPrefixLeadingIcon: shouldPrefixLeadingIcon
            )
        }
    }

    /// String for primary label. To be used as the title.
    /// If `shouldPrefixLeadingIcon` is `true`, a leading icon will be prefixed.
    var title: String? {
        didSet {
            guard let title = title else {
                titleLabel.text = nil
                return
            }

            Self.updateTitleLabel(
                titleLabel,
                with: title,
                shouldPrefixLeadingIcon: shouldPrefixLeadingIcon
            )
            accessibilityLabel = title
        }
    }

    /// String for secondary label. To be used as description
    var message: String? {
        didSet {
            messageLabel.text = message
            accessibilityValue = message
        }
    }

    /// Determines the alignment for the action buttons.
    var buttonAlignment: ButtonAlignment = .left {
        didSet {
            buttonsStackView.removeAllSubviews()
            switch buttonAlignment {
            case .left:
                buttonsStackView.spacing = Constants.Spacing.buttonsStackViewInterItemSpacing
                buttonsStackView.addArrangedSubviews([primaryButton, secondaryButton, UIView()])
                buttonsStackView.setCustomSpacing(0, after: secondaryButton)
            case .right:
                buttonsStackView.spacing = 0
                buttonsStackView.addArrangedSubviews([UIView(), primaryButton, secondaryButton])
                buttonsStackView.setCustomSpacing(Constants.Spacing.buttonsStackViewInterItemSpacing, after: primaryButton)
            }
        }
    }

    var primaryButtonTitle: String? {
        didSet {
            primaryButton.setTitle(primaryButtonTitle, for: .normal)
        }
    }

    var secondaryButtonTitle: String? {
        didSet {
            secondaryButton.setTitle(secondaryButtonTitle, for: .normal)
        }
    }

    var dismissalAction: (() -> Void)?
    var secondaryButtonAction: (() -> Void)?

    private let availableWidth: CGFloat

    private lazy var titleLabel: UILabel = {
        $0.font = UIFont.body
        $0.textColor = .invertedLabel
        $0.adjustsFontForContentSizeCategory = true
        $0.numberOfLines = 0
        return $0
    }(UILabel())

    private lazy var messageLabel: UILabel = {
        $0.font = UIFont.body
        $0.textColor = .invertedSecondaryLabel
        $0.adjustsFontForContentSizeCategory = true
        $0.numberOfLines = 0
        return $0
    }(UILabel())

    private lazy var primaryButton: UIButton = {
        $0.titleLabel?.font = UIFont.subheadline
        $0.setTitleColor(.invertedLink, for: .normal)
        $0.addTarget(self, action: #selector(didTapPrimaryButton), for: .touchUpInside)
        $0.titleLabel?.adjustsFontForContentSizeCategory = true
        return $0
    }(UIButton())

    private lazy var secondaryButton: UIButton = {
        $0.titleLabel?.font = UIFont.subheadline
        $0.setTitleColor(.invertedLink, for: .normal)
        $0.addTarget(self, action: #selector(didTapSecondaryButton), for: .touchUpInside)
        $0.titleLabel?.adjustsFontForContentSizeCategory = true
        return $0
    }(UIButton())

    private lazy var contentStackView: UIStackView = {
        $0.addArrangedSubviews([titleLabel, messageLabel, buttonsStackView])
        $0.spacing = Constants.Spacing.contentStackViewInterItemSpacing
        $0.axis = .vertical
        return $0
    }(UIStackView())

    private lazy var buttonsStackView: UIStackView = {
        $0.addArrangedSubviews([primaryButton, secondaryButton, UIView()])
        $0.spacing = Constants.Spacing.buttonsStackViewInterItemSpacing
        $0.setCustomSpacing(0, after: secondaryButton)
        return $0
    }(UIStackView())

    private static func updateTitleLabel(
        _ titleLabel: UILabel,
        with text: String,
        shouldPrefixLeadingIcon: Bool) {

        if shouldPrefixLeadingIcon {
            titleLabel.text = Constants.leadingIconUnicode + " " + text
        } else {
            titleLabel.text = text
        }
    }

    private let containerView = UIView()
    private var containerTopConstraint: NSLayoutConstraint?
    private var containerBottomConstraint: NSLayoutConstraint?
    private var arrowShapeLayer: CAShapeLayer?

    init(containerWidth: CGFloat = UIScreen.main.bounds.width) {
        self.availableWidth = containerWidth - Constants.Spacing.superHorizontalMargin
        super.init(frame: .zero)
        commonInit()
    }

    required init?(coder: NSCoder) {
        self.availableWidth = UIScreen.main.bounds.width - Constants.Spacing.superHorizontalMargin
        super.init(coder: coder)
        commonInit()
    }

    override func layoutSubviews() {
        arrowShapeLayer?.strokeColor = UIColor.invertedTooltipBackgroundColor.cgColor
        arrowShapeLayer?.fillColor = UIColor.invertedTooltipBackgroundColor.cgColor
        containerView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .light ? 0.5 : 0
    }

    /// Adds a tooltip  Arrow Head at the given X Offset and either to the top or the bottom.
    /// - Parameters:
    ///   - offsetX: The offset on which the arrow will be placed. The value must be above 0 and below maxX of the view.
    ///   - arrowPosition: Arrow will be placed either on `.top`, pointed up, or `.bottom`, pointed down.
    func addArrowHead(toXPosition offsetX: CGFloat, arrowPosition: ArrowPosition) {
        arrowShapeLayer?.removeFromSuperlayer()

        let arrowTipY: CGFloat
        let arrowTipYControl: CGFloat
        let offsetY: CGFloat

        switch arrowPosition {
        case .top:
            offsetY = 0
            arrowTipY = Constants.arrowTipYLength * -1
            arrowTipYControl = Constants.arrowTipYControlLength * -1
            containerTopConstraint?.constant = Constants.arrowTipYControlLength
            containerBottomConstraint?.constant = 0
        case .bottom:
            offsetY = height(withTitle: titleLabel.text, message: message)
            arrowTipY = Constants.arrowTipYLength
            arrowTipYControl = Constants.arrowTipYControlLength
            containerTopConstraint?.constant = 0
            containerBottomConstraint?.constant = Constants.arrowTipYControlLength
        }

        let arrowPath = UIBezierPath()
        arrowPath.move(to: CGPoint(x: 0, y: 0))
        let arrowOriginX = (Self.arrowWidth/2 - 1)
        // In order to have a full width of `arrowWidth`, first draw the left side of the triangle until arrowOriginX.
        arrowPath.addLine(to: CGPoint(x: arrowOriginX, y: arrowTipY))
        // Add curve until `arrowWidth/2 + 1` (2 points of curve for a rounded arrow tip).
        arrowPath.addQuadCurve(
            to: CGPoint(x: arrowOriginX + 2, y: arrowTipY),
            controlPoint: CGPoint(x: Self.arrowWidth/2, y: arrowTipYControl)
        )
        // Draw down to 20.
        arrowPath.addLine(to: CGPoint(x: Self.arrowWidth, y: 0))
        arrowPath.close()

        arrowShapeLayer = CAShapeLayer()
        guard let arrowShapeLayer = arrowShapeLayer else {
            return
        }

        arrowShapeLayer.path = arrowPath.cgPath

        arrowShapeLayer.strokeColor = UIColor.invertedTooltipBackgroundColor.cgColor
        arrowShapeLayer.fillColor = UIColor.invertedTooltipBackgroundColor.cgColor
        arrowShapeLayer.lineWidth = 4.0

        arrowShapeLayer.position = CGPoint(x: offsetX - Self.arrowWidth/2, y: offsetY)

        containerView.layer.addSublayer(arrowShapeLayer)
    }

    func size() -> CGSize {
        CGSize(
            width: width(
                title: titleLabel.text,
                message: message,
                primaryButtonTitle: primaryButton.titleLabel?.text,
                secondaryButtonTitle: secondaryButton.titleLabel?.text
            ),
            height: height(
                withTitle: title,
                message: message
            )
        )
    }

    func copy(containerWidth: CGFloat) -> Tooltip {
        let copyTooltip = Tooltip(containerWidth: containerWidth)
        copyTooltip.title = title
        copyTooltip.message = message
        copyTooltip.primaryButtonTitle = primaryButtonTitle
        copyTooltip.secondaryButtonTitle = secondaryButtonTitle
        copyTooltip.dismissalAction = dismissalAction
        copyTooltip.secondaryButtonAction = secondaryButtonAction
        copyTooltip.shouldPrefixLeadingIcon = shouldPrefixLeadingIcon
        copyTooltip.buttonAlignment = buttonAlignment
        return copyTooltip
    }

    private func commonInit() {
        backgroundColor = .clear

        setUpContainerView()
        setUpConstraints()
        addShadow()
        isAccessibilityElement = true
    }

    private func setUpContainerView() {
        containerView.backgroundColor = UIColor.invertedTooltipBackgroundColor
        containerView.layer.cornerRadius = Constants.cornerRadius
        containerView.translatesAutoresizingMaskIntoConstraints = false
        addSubview(containerView)

        containerTopConstraint = containerView.topAnchor.constraint(equalTo: topAnchor)
        containerBottomConstraint = bottomAnchor.constraint(equalTo: containerView.bottomAnchor)

        NSLayoutConstraint.activate([
            containerTopConstraint,
            containerView.leadingAnchor.constraint(equalTo: leadingAnchor),
            trailingAnchor.constraint(equalTo: containerView.trailingAnchor),
            containerBottomConstraint
        ].compactMap { $0 })
    }

    private func setUpConstraints() {
        contentStackView.translatesAutoresizingMaskIntoConstraints = false
        buttonsStackView.translatesAutoresizingMaskIntoConstraints = false
        containerView.addSubview(contentStackView)

        NSLayoutConstraint.activate([
            contentStackView.topAnchor.constraint(
                equalTo: containerView.topAnchor,
                constant: Constants.Spacing.contentStackViewTop
            ),
            contentStackView.leadingAnchor.constraint(
                equalTo: containerView.leadingAnchor,
                constant: Constants.Spacing.contentStackViewHorizontal
            ),
            containerView.trailingAnchor.constraint(
                equalTo: contentStackView.trailingAnchor,
                constant: Constants.Spacing.contentStackViewHorizontal
            ),
            containerView.bottomAnchor.constraint(
                equalTo: contentStackView.bottomAnchor,
                constant: Constants.Spacing.contentStackViewBottom
            ),
            containerView.widthAnchor.constraint(
                lessThanOrEqualToConstant: availableWidth
            ),
            buttonsStackView.heightAnchor.constraint(equalToConstant: Constants.Spacing.buttonStackViewHeight)
        ])
    }

    private func addShadow() {
        containerView.layer.shadowColor = UIColor.black.cgColor
        containerView.layer.shadowOffset = CGSize(width: 0, height: 2)
        containerView.layer.shadowOpacity = traitCollection.userInterfaceStyle == .light ? 0.5 : 0
    }

    @objc private func didTapPrimaryButton() {
        dismissalAction?()
    }

    @objc private func didTapSecondaryButton() {
        secondaryButtonAction?()
    }

    private func height(
        withTitle title: String?,
        message: String?
    ) -> CGFloat {
        var totalHeight: CGFloat = 0

        totalHeight += Constants.Spacing.contentStackViewTop

        if let title = title {
            totalHeight += title.height(withMaxWidth: maxContentWidth(), font: UIFont.body)
        }

        totalHeight += Constants.Spacing.contentStackViewInterItemSpacing * 2

        if let message = message {
            totalHeight += message.height(withMaxWidth: maxContentWidth(), font: UIFont.body)
        }

        totalHeight += Constants.Spacing.buttonStackViewHeight
        totalHeight += Constants.Spacing.contentStackViewBottom

        return totalHeight
    }

    private func width(
        title: String?,
        message: String?,
        primaryButtonTitle: String?,
        secondaryButtonTitle: String?
    ) -> CGFloat {
        let titleWidth = title?.width(withMaxWidth: maxContentWidth(), font: UIFont.body) ?? 0
        let messageWidth = message?.width(withMaxWidth: maxContentWidth(), font: UIFont.body) ?? 0

        var buttonsWidth: CGFloat = 0
        if let primaryButtonTitle = primaryButtonTitle {
            buttonsWidth += primaryButtonTitle.width(withMaxWidth: maxContentWidth(), font: UIFont.subheadline)
        }

        if let secondaryButtonTitle = secondaryButtonTitle {
            buttonsWidth += secondaryButtonTitle.width(
                withMaxWidth: maxContentWidth(),
                font: UIFont.subheadline
            ) + Constants.Spacing.buttonsStackViewInterItemSpacing
        }

        return max(max(titleWidth, messageWidth), buttonsWidth) + Constants.Spacing.contentStackViewHorizontal * 2
    }

    private func maxContentWidth() -> CGFloat {
        availableWidth
        - (Constants.Spacing.contentStackViewHorizontal * 2)
    }
}

private extension String {
    func size(withMaxWidth maxWidth: CGFloat, font: UIFont) -> CGRect {
        let constraintRect = CGSize(width: maxWidth, height: .greatestFiniteMagnitude)
        let boundingBox = self.boundingRect(
            with: constraintRect,
            options: .usesLineFragmentOrigin,
            attributes: [.font: font],
            context: nil
        )

        return boundingBox
    }

    func height(withMaxWidth maxWidth: CGFloat, font: UIFont) -> CGFloat {
        ceil(size(withMaxWidth: maxWidth, font: font).height)
    }

    func width(withMaxWidth maxWidth: CGFloat, font: UIFont) -> CGFloat {
        ceil(size(withMaxWidth: maxWidth, font: font).width)
    }
}

extension UIColor {
    static var invertedSystem5: UIColor {
        UIColor(light: UIColor.systemGray5.color(for: UITraitCollection(userInterfaceStyle: .dark)),
                dark: UIColor.systemGray5.color(for: UITraitCollection(userInterfaceStyle: .light)))
    }

    static var invertedLabel: UIColor {
        UIColor(light: UIColor.label.color(for: UITraitCollection(userInterfaceStyle: .dark)),
                dark: UIColor.label.color(for: UITraitCollection(userInterfaceStyle: .light)))
    }

    static var invertedSecondaryLabel: UIColor {
        UIColor(light: UIColor.secondaryLabel.color(for: UITraitCollection(userInterfaceStyle: .dark)),
                dark: UIColor.secondaryLabel.color(for: UITraitCollection(userInterfaceStyle: .light)))
    }

    static var invertedLink: UIColor {
        UIColor(light: .wooCommercePurple(.shade30), dark: .wooCommercePurple(.shade50))
    }

    static var invertedSeparator: UIColor {
        UIColor(light: UIColor.separator.color(for: UITraitCollection(userInterfaceStyle: .dark)),
                dark: UIColor.separator.color(for: UITraitCollection(userInterfaceStyle: .light)))
    }

    static var invertedTooltipBackgroundColor: UIColor {
        UIColor(light: UIColor.systemGray5.color(for: UITraitCollection(userInterfaceStyle: .dark)),
                dark: .white)
    }
}