import SwiftUI
import Docsy

extension EnvironmentValues {
    @Entry public var documentationWorkspace = DocumentationWorkspace()
}
@propertyWrapper
struct Workspace: DynamicProperty {
    @Environment(\.documentationWorkspace)
    public var wrappedValue

    public init() {}
}

#if canImport(AppKit)
import AppKit
#endif

struct Pasteboard {
    #if os(macOS)
    typealias OSPasteboard = NSPasteboard

    static let pasteboard: NSPasteboard = .general

    static func setString(_ value: String) {
        pasteboard.clearContents()
        pasteboard.setString(value, forType: .string)
    }

    static func setURL(_ value: URL) {
        pasteboard.clearContents()
        pasteboard.setString(value.absoluteString, forType: .string)
    }

    #else
    typealias OSPasteboard = UIPasteboard
    #error("UIPasteboard not implemeneted")
    #endif
}

struct MainView: View, DropDelegate {
    func performDrop(info: DropInfo) -> Bool {
        let urlProviders = info.itemProviders(for: [.url])
        print(urlProviders)
        return true
    }

    @Environment(\.documentationWorkspace)
    private var workspace

    let context: DocumentationContext

    @MainActor
    func load() async {
        do {
            let provider = try LocalFileSystemDataProvider(bundle: .main)
            try await workspace.registerProvider(provider)
        } catch {
            print("Error registering Bundle Provider")
        }
    }

    @Bindable
    var navigator = Navigator()

    @Environment(\.debugMode)
    var debugMode

    var body: some View {
        NavigationSplitView {
            NavigatorView(navigator: navigator)
                .navigationDestination(item: $navigator.selection) { reference in
                    ContentView(reference: reference)
                        .toolbar {
                            ToolbarItem(placement: .accessoryBar(id: "debug")) {
                                Menu("Reference") {
                                    Text("Bundle: \(reference.bundleIdentifier)")
                                    Text("Path: \(reference.path)")
                                    if let fragment = reference.fragment {
                                        Text("Fragment \(fragment)")
                                    }

                                    Button(action: { Pasteboard.setURL(reference.url) }) {
                                        Label("Copy URL", systemImage: "link")
                                    }

                                    Button(action: {
                                        Pasteboard.setString(reference.url.path())
                                    }) {
                                        Label("Copy as Path", systemImage: "questionmark.folder")
                                    }

                                    Button(action: { Pasteboard.setString(reference.description) }) {
                                        Label("Copy Topic Reference", systemImage: "chevron.left.forwardslash.chevron.right")
                                    }
                                }
                            }
                        }
                }
        } detail: {
            Text("Content")
        }
        .toolbar(content: {
            ToolbarItem(placement: .accessoryBar(id: "debug")) {
                DebugModeButton()
            }
            ToolbarItemGroup(placement: .navigation) {
                NavigationButtons(navigator: navigator)
            }
        })
        .environment(\.openURL, .init(handler: { url in
            switch url.scheme {
            case "doc":
                self.navigator.goto(.init(
                    bundleIdentifier: url.host() ?? "",
                    path: url.path(),
                    sourceLanguage: .swift
                ))
                return .discarded
            default: return .systemAction
            }
        }))
//        .toolbarVisibility(debugMode.isDebugging ? .hidden : .automatic, for: .accessoryBar(id: "debug"))
        .environment(context)
        .task {
            await load()
        }
//        .task {
//            let baseURI = URL(filePath: "/Users/noahkamara/Developer/DocSee/")
//
//            do {
//                let doccProvider = try LocalFileSystemDataProvider(
//                    rootURL: baseURI.appending(component: "docc.doccarchive")
//                )
//
//
//                let slothcreatorProvider = try LocalFileSystemDataProvider(
//                    rootURL: baseURI.appending(component: "SlothCreator.doccarchive")
//                )
//
////                try await workspace.registerProvider(doccProvider)
//                try await workspace.registerProvider(slothcreatorProvider)
//            } catch let desribedError as DescribedError {
//                print(desribedError.errorDescription)
//            } catch {
//                print(error)
//            }
//        }
    }
}

//#Preview(traits: .workspace) {
//    MainView()
//}

//#Preview {
//    ContentView2()
//}

extension ToolbarItemPlacement {
    static let debugBar = accessoryBar(id: "debugBar")
}
