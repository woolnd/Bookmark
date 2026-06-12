import ProjectDescription

let project = Project(
    name: "Bookmark",
    packages: [
        .remote(url: "https://github.com/pointfreeco/swift-composable-architecture", requirement: .upToNextMajor(from: "1.23.1")),
        .remote(url: "https://github.com/firebase/firebase-ios-sdk", requirement: .upToNextMajor(from: "11.0.0")),
        .remote(url: "https://github.com/kakao/kakao-ios-sdk", requirement: .upToNextMajor(from: "2.23.0")),
    ],
    settings: .settings(
        base: [
            "SWIFT_VERSION": "6.0",
            "IPHONEOS_DEPLOYMENT_TARGET": "17.0"
        ]
    ),
    targets: [
        .target(
            name: "Bookmark-Dev",
            destinations: .iOS,
            product: .app,
            bundleId: "com.wodnd.bookmark",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                ]
            ),
            buildableFolders: [
                "Bookmark/Sources",
                "Bookmark/Resources",
            ],
            dependencies: [
                .package(product: "ComposableArchitecture"),
                .package(product: "FirebaseAuth"),
                .package(product: "FirebaseFirestore"),
                .package(product: "KakaoSDKUser"),
                .package(product: "KakaoSDKAuth"),
            ]
        ),
        .target(
            name: "Bookmark-Live",
            destinations: .iOS,
            product: .app,
            bundleId: "com.wodnd.bookmark",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .extendingDefault(
                with: [
                    "UILaunchScreen": [
                        "UIColorName": "",
                        "UIImageName": "",
                    ],
                    "UIAppFonts": [
                        "Gaegu-Light.ttf",
                        "Gaegu-Regular.ttf",
                        "Gaegu-Bold.ttf"
                    ]
                ]
            ),
            buildableFolders: [
                "Bookmark/Sources",
                "Bookmark/Resources",
            ],
            dependencies: [
                .package(product: "ComposableArchitecture"),
                .package(product: "FirebaseAuth"),
                .package(product: "FirebaseFirestore"),
                .package(product: "KakaoSDKUser"),
                .package(product: "KakaoSDKAuth"),
            ]
        ),
        .target(
            name: "BookmarkTests",
            destinations: .iOS,
            product: .unitTests,
            bundleId: "com.wodnd.bookmark.tests",
            deploymentTargets: .iOS("17.0"),
            infoPlist: .default,
            buildableFolders: [
                "Bookmark/Tests"
            ],
            dependencies: [.target(name: "Bookmark-Dev")]
        ),
    ],
    schemes: [
        .scheme(
            name: "Bookmark-Dev",
            buildAction: .buildAction(targets: ["Bookmark-Dev"]),
            runAction: .runAction(configuration: "Debug")
        ),
        .scheme(
            name: "Bookmark-Live",
            buildAction: .buildAction(targets: ["Bookmark-Live"]),
            runAction: .runAction(configuration: "Release")
        )
    ]
)
