//
//  ViewController.swift
//  arcade
//
//  Created by 김태준 on 5/27/26.
//

import UIKit
import MapKit
import CoreLocation

/// 지도와 목록을 함께 보여주는 메인 화면 컨트롤러.
final class ViewController: UIViewController, CLLocationManagerDelegate, MKMapViewDelegate, UITableViewDataSource, UITableViewDelegate {
    /// 번들에 포함된 아케이드 목록.
    private let arcades = ArcadeStore.loadArcades()

    /// 지도 뷰 아웃렛.
    @IBOutlet private var mapView: MKMapView!
    /// 목록 테이블 아웃렛.
    @IBOutlet private var tableView: UITableView!
    /// 위치 권한/업데이트를 관리하는 매니저.
    private let locationManager = CLLocationManager()
    /// 최초 한 번만 사용자 위치로 센터링했는지 여부.
    private var didCenterOnUser = false
    /// 최신 사용자 위치.
    private var currentLocation: CLLocation?
    /// 거리 기준으로 정렬된 아케이드 목록.
    private var orderedArcades: [ArcadeLocation] = []
    /// 아케이드 id별 거리 캐시.
    private var distances: [String: CLLocationDistance] = [:]
    /// 위치를 못 얻을 때 사용할 기본 좌표.
    private let fallbackCoordinate = CLLocationCoordinate2D(latitude: 37.5665, longitude: 126.9780)
    /// 이미 표시 중인 상세 화면의 아케이드 id.
    private var presentedArcadeId: String?

    /// 초기 UI와 위치/데이터 상태를 구성한다.
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Arcade"
        configureMapView()
        configureTableView()
        configureLocation()
        addArcadePins()
        updateOrdering()
    }

    // MARK: - Setup

    /// 지도 뷰 기본 설정을 적용한다.
    private func configureMapView() {
        mapView.delegate = self
        mapView.showsUserLocation = true
        centerMap(on: fallbackCoordinate, animated: false)
    }

    /// 테이블 데이터 소스/델리게이트를 연결한다.
    private func configureTableView() {
        tableView.dataSource = self
        tableView.delegate = self
    }

    /// 위치 권한 요청과 업데이트를 시작한다.
    private func configureLocation() {
        locationManager.delegate = self
        locationManager.desiredAccuracy = kCLLocationAccuracyHundredMeters
        locationManager.requestWhenInUseAuthorization()
        locationManager.startUpdatingLocation()
    }

    /// 지도에 아케이드 마커를 추가한다.
    private func addArcadePins() {
        for arcade in arcades {
            let annotation = ArcadeAnnotation(arcade: arcade)
            mapView.addAnnotation(annotation)
        }
    }

    /// 현재 위치를 기준으로 정렬 순서와 거리 표시를 갱신한다.
    private func updateOrdering() {
        guard let currentLocation else {
            orderedArcades = arcades
            tableView.reloadData()
            return
        }

        // 테이블 표시와 정렬에 재사용할 거리 캐시를 만든다.
        distances = Dictionary(uniqueKeysWithValues: arcades.map { arcade in
            let arcadeLocation = CLLocation(latitude: arcade.latitude, longitude: arcade.longitude)
            let distance = currentLocation.distance(from: arcadeLocation)
            return (arcade.id, distance)
        })

        orderedArcades = arcades.sorted { first, second in
            let firstDistance = distances[first.id] ?? .greatestFiniteMagnitude
            let secondDistance = distances[second.id] ?? .greatestFiniteMagnitude
            return firstDistance < secondDistance
        }

        tableView.reloadData()
    }

    /// 거리 표시용 문자열을 만든다.
    private func distanceText(for arcade: ArcadeLocation) -> String {
        guard let distance = distances[arcade.id] else { return "-" }
        if distance >= 1000 {
            return String(format: "%.1f km", distance / 1000)
        }
        return String(format: "%.0f m", distance)
    }

    /// 지정 좌표로 지도를 이동한다.
    private func centerMap(on coordinate: CLLocationCoordinate2D, animated: Bool) {
        let region = MKCoordinateRegion(
            center: coordinate,
            latitudinalMeters: 4000,
            longitudinalMeters: 4000
        )
        mapView.setRegion(region, animated: animated)
    }

    /// 권한 상태에 따라 위치 업데이트/대체 좌표를 처리한다.
    private func handleAuthorization(status: CLAuthorizationStatus) {
        switch status {
        case .authorizedAlways, .authorizedWhenInUse:
            locationManager.startUpdatingLocation()
        case .denied, .restricted:
            centerMap(on: fallbackCoordinate, animated: true)
        case .notDetermined:
            break
        @unknown default:
            break
        }
    }

    /// 선택한 아케이드의 상세 화면을 표시한다.
    private func presentDetail(for arcade: ArcadeLocation) {
        // 동일한 상세 시트를 중복 표시하지 않는다.
        if presentedArcadeId == arcade.id {
            return
        }

        presentedArcadeId = arcade.id
        let detailViewController = ArcadeDetailViewController(arcade: arcade)
        detailViewController.onDismiss = { [weak self] in
            self?.presentedArcadeId = nil
        }
        let navigationController = UINavigationController(rootViewController: detailViewController)
        navigationController.modalPresentationStyle = .pageSheet
        if let sheet = navigationController.sheetPresentationController {
            sheet.detents = [.medium(), .large()]
            sheet.prefersGrabberVisible = true
        }
        present(navigationController, animated: true)
    }

    /// 목록 선택에 대응하여 지도 핀을 선택한다.
    private func selectAnnotation(for arcade: ArcadeLocation) {
        let annotations = mapView.annotations.compactMap { $0 as? ArcadeAnnotation }
        guard let target = annotations.first(where: { $0.arcade.id == arcade.id }) else { return }
        mapView.setCenter(target.coordinate, animated: true)
        mapView.selectAnnotation(target, animated: true)
    }

    // MARK: - UITableViewDataSource

    /// 정렬된 목록 개수를 반환한다.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        orderedArcades.count
    }

    /// 아케이드 셀을 구성한다.
    func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let reuseIdentifier = "ArcadeCell"
        let cell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier)
            ?? UITableViewCell(style: .subtitle, reuseIdentifier: reuseIdentifier)

        let arcade = orderedArcades[indexPath.row]
        let distance = distanceText(for: arcade)
        cell.textLabel?.text = arcade.name
        cell.detailTextLabel?.text = "\(distance) · \(arcade.address)"
        cell.backgroundColor = .systemBackground
        cell.textLabel?.textColor = .label
        cell.detailTextLabel?.textColor = .secondaryLabel
        cell.accessoryType = .disclosureIndicator
        return cell
    }

    // MARK: - UITableViewDelegate

    /// 셀 선택 시 지도 이동 및 상세 화면을 표시한다.
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let arcade = orderedArcades[indexPath.row]
        selectAnnotation(for: arcade)
        presentDetail(for: arcade)
    }

    // MARK: - CLLocationManagerDelegate

    /// iOS 14+ 권한 변경 콜백.
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        handleAuthorization(status: manager.authorizationStatus)
    }

    /// iOS 13 이하 권한 변경 콜백.
    func locationManager(_ manager: CLLocationManager, didChangeAuthorization status: CLAuthorizationStatus) {
        handleAuthorization(status: status)
    }

    /// 위치 업데이트를 받아 거리/정렬을 갱신한다.
    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let location = locations.last else { return }
        currentLocation = location
        // 사용자 조작과 충돌하지 않도록 최초 한 번만 센터링한다.
        if !didCenterOnUser {
            didCenterOnUser = true
            centerMap(on: location.coordinate, animated: true)
        }
        updateOrdering()
        // 거리 정렬에는 한 번의 업데이트로 충분하다.
        locationManager.stopUpdatingLocation()
    }

    /// 위치 실패 시 대체 좌표로 유지한다.
    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // 위치 실패 시 기본 좌표를 보여준다.
        centerMap(on: fallbackCoordinate, animated: true)
        updateOrdering()
    }

    // MARK: - MKMapViewDelegate

    /// 사용자 위치를 제외한 마커 뷰를 구성한다.
    func mapView(_ mapView: MKMapView, viewFor annotation: MKAnnotation) -> MKAnnotationView? {
        if annotation is MKUserLocation {
            return nil
        }

        let reuseIdentifier = "ArcadePin"
        let view = mapView.dequeueReusableAnnotationView(
            withIdentifier: reuseIdentifier
        ) as? MKMarkerAnnotationView ?? MKMarkerAnnotationView(
            annotation: annotation,
            reuseIdentifier: reuseIdentifier
        )

        view.annotation = annotation
        // 선택 시 상세를 표시하므로 기본 콜아웃은 비활성화한다.
        view.canShowCallout = false
        return view
    }

    /// 마커 선택 시 상세 화면을 표시한다.
    func mapView(_ mapView: MKMapView, didSelect view: MKAnnotationView) {
        guard let arcadeAnnotation = view.annotation as? ArcadeAnnotation else { return }
        presentDetail(for: arcadeAnnotation.arcade)
    }
}

/// 아케이드 정보를 지도에 표시하기 위한 어노테이션.
final class ArcadeAnnotation: NSObject, MKAnnotation {
    /// 원본 아케이드 데이터.
    let arcade: ArcadeLocation
    /// 지도에 표시할 좌표.
    let coordinate: CLLocationCoordinate2D
    /// 마커 타이틀.
    let title: String?
    /// 마커 서브타이틀.
    let subtitle: String?

    /// 아케이드 정보를 기반으로 어노테이션을 생성한다.
    init(arcade: ArcadeLocation) {
        self.arcade = arcade
        self.coordinate = CLLocationCoordinate2D(
            latitude: arcade.latitude,
            longitude: arcade.longitude
        )
        self.title = arcade.name
        self.subtitle = arcade.address
        super.init()
    }
}
