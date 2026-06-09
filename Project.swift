import ProjectDescription

let project = Project(
    name: "Bookmark",
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
            dependencies: []
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
                ]
            ),
            buildableFolders: [
                "Bookmark/Sources",
                "Bookmark/Resources",
            ],
            dependencies: []
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
