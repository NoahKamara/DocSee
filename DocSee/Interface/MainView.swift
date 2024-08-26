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
        let baseURI = URL(filePath: "/Users/noahkamara/Developer/DocSee/")

        do {
            let doccProvider = try LocalFileSystemDataProvider(
                rootURL: baseURI.appending(component: "docc.doccarchive")
            )


            let slothcreatorProvider = try LocalFileSystemDataProvider(
                rootURL: baseURI.appending(component: "SlothCreator.doccarchive")
            )

//            try await workspace.registerProvider(doccProvider)
            try await workspace.registerProvider(slothcreatorProvider)
        } catch let desribedError as DescribedError {
            print(desribedError.errorDescription)
        } catch {
            print(error)
        }
    }

    @Bindable
    var navigator = Navigator()

    var body: some View {
        NavigationSplitView {
            NavigatorView(navigator: navigator)
                .navigationDestination(item: $navigator.selection) { reference in
                    ContentView(reference: reference)
                }
        } detail: {
            Text("Content")
        }
        .toolbar(content: {
            ToolbarItemGroup(placement: .navigation) {
                NavigationButtons(navigator: navigator)
            }
        })
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
