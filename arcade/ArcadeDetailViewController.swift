import UIKit
import MapKit

/// 아케이드 상세 정보를 표시하는 화면.
final class ArcadeDetailViewController: UIViewController {
    /// 표시할 아케이드 데이터.
    private let arcade: ArcadeLocation
    /// 닫힘 시 호출되는 콜백.
    var onDismiss: (() -> Void)?

    /// 아케이드 데이터를 주입받아 생성한다.
    init(arcade: ArcadeLocation) {
        self.arcade = arcade
        super.init(nibName: nil, bundle: nil)
    }

    /// 스토리보드 초기화는 지원하지 않는다.
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    /// UI 구성을 초기화한다.
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Arcade Info"
        view.backgroundColor = .systemBackground
        // 시트 닫기 버튼을 제공한다.
        navigationItem.rightBarButtonItem = UIBarButtonItem(
            barButtonSystemItem: .close,
            target: self,
            action: #selector(closeTapped)
        )
        configureLayout()
    }

    /// 상세 화면 레이아웃을 구성한다.
    private func configureLayout() {
        // 아케이드 메타데이터를 수직 스택으로 구성한다.
        let nameLabel = makeLabel(text: arcade.name, style: .title2, isBold: true, color: .label)
        let addressLabel = makeLabel(text: arcade.address, style: .body, isBold: false, color: .label)
        let coordinateLabel = makeLabel(
            text: "Lat: \(arcade.latitude)  Lon: \(arcade.longitude)",
            style: .subheadline,
            isBold: false,
            color: .secondaryLabel
        )
        let notesLabel = makeLabel(
            text: arcade.notes.isEmpty ? "Notes: -" : "Notes: \(arcade.notes)",
            style: .body,
            isBold: false,
            color: .label
        )
        let directionsButton = UIButton(type: .system)
        directionsButton.setTitle("Directions", for: .normal)
        directionsButton.addTarget(self, action: #selector(openDirections), for: .touchUpInside)

        let stackView = UIStackView(arrangedSubviews: [
            nameLabel,
            addressLabel,
            coordinateLabel,
            notesLabel,
            directionsButton
        ])
        stackView.axis = .vertical
        stackView.spacing = 12
        stackView.translatesAutoresizingMaskIntoConstraints = false

        view.addSubview(stackView)
        NSLayoutConstraint.activate([
            stackView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 24),
            stackView.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20),
            stackView.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20)
        ])
    }

    /// 텍스트 스타일에 맞는 라벨을 생성한다.
    private func makeLabel(
        text: String,
        style: UIFont.TextStyle,
        isBold: Bool,
        color: UIColor
    ) -> UILabel {
        let label = UILabel()
        label.text = text
        label.numberOfLines = 0
        let baseFont = UIFont.preferredFont(forTextStyle: style)
        label.font = isBold ? UIFont.boldSystemFont(ofSize: baseFont.pointSize) : baseFont
        label.textColor = color
        return label
    }

    /// 닫기 버튼 액션.
    @objc private func closeTapped() {
        onDismiss?()
        dismiss(animated: true)
    }

    /// 애플 지도에 길찾기를 요청한다.
    @objc private func openDirections() {
        // 애플 지도에 운전 경로로 연결한다.
        let coordinate = CLLocationCoordinate2D(latitude: arcade.latitude, longitude: arcade.longitude)
        let placemark = MKPlacemark(coordinate: coordinate)
        let mapItem = MKMapItem(placemark: placemark)
        mapItem.name = arcade.name
        mapItem.openInMaps(launchOptions: [
            MKLaunchOptionsDirectionsModeKey: MKLaunchOptionsDirectionsModeDriving
        ])
    }

    /// 스와이프 닫힘을 감지해 콜백을 호출한다.
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        // 스와이프 닫힘을 감지해 상위 상태를 리셋한다.
        if isBeingDismissed {
            onDismiss?()
        }
    }
}
