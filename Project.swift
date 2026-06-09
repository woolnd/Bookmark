import ProjectDescription

let project = Project(
    name: "Bookmark",
    targets: [
        .target(
            name: "Bookmark",
            destinations: .iOS,
            product: .app,
            bundleId: "dev.tuist.Bookmark",
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
            bundleId: "dev.tuist.BookmarkTests",
            infoPlist: .default,
            buildableFolders: [
                "Bookmark/Tests"
            ],
            dependencies: [.target(name: "Bookmark")]
        ),
    ]
)
