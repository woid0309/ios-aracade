# Repo Notes for OpenCode

- Single-target UIKit iOS app in `arcade.xcodeproj` with sources in `arcade/`.
- App launches from storyboard `Main` (`UISceneStoryboardFile` in `arcade/Info.plist`); initial controller is `ViewController` (`arcade/Base.lproj/Main.storyboard`).
- Uses `SceneDelegate` + `AppDelegate`; no SwiftUI entry point.
- No SwiftPM or CocoaPods configs found; add dependencies via the Xcode project if needed.
- Deployment target is iOS 26.2 in project settings (`arcade.xcodeproj/project.pbxproj`).
