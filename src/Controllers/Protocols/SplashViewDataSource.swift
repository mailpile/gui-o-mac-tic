import AppKit

@objc protocol SplashScreenDataSource {
    var splashScreenConfig: SplashScreenConfig? { get }
}
