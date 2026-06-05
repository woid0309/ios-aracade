import Foundation //json 파일 불러올때 필요함
import CoreLocation //위치관련때 필요함

/// 아케이드 위치 정보를 담는 모델.
struct ArcadeLocation: Codable {
    /// 고유 식별자.
    let id: String
    /// 매장 이름.
    let name: String
    /// 위도.
    let latitude: CLLocationDegrees
    /// 경도.
    let longitude: CLLocationDegrees
    /// 주소.
    let address: String
    /// 비고/메모.
    let notes: String
}

/// 번들에서 아케이드 데이터를 로딩한다.
struct ArcadeStore {
    /// JSON 파일을 읽어 모델 배열로 반환한다.
    static func loadArcades() -> [ArcadeLocation] {
        // 번들에 포함된 JSON에서 초기 데이터를 읽는다.
        guard let url = Bundle.main.url(forResource: "arcade", withExtension: "json") else {
            print("arcade.json not found in app bundle")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let payload = try JSONDecoder().decode(ArcadePayload.self, from: data)
            return payload.arcades
        } catch {
            // 디코딩 오류를 확인하기 위해 로그를 남긴다.
            print("Failed to decode arcade.json: \(error)")
            return []
        }
    }
}

/// 최상위 JSON 페이로드.
private struct ArcadePayload: Codable {
    /// 아케이드 배열.
    let arcades: [ArcadeLocation]
}
