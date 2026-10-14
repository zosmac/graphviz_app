# Apple Silicon and macOS 11 compatibility for Graphviz app

Apple Silicon hardware requires macOS 11.0 (Big Sur, Darwin 20) or later. macOS 10.15 and
earlier versions do not execute on Apple Silicon processors. Supporting Apple Silicon back
to the earliest possible operating system version requires targeting `arm64` with a deployment
target of macOS 11.0 (`MACOSX_DEPLOYMENT_TARGET = 11.0`).

The `graphviz_app` repository (`https://github.com/zosmac/graphviz_app.git`) contains the
native macOS Document-based Cocoa application previously maintained in the Graphviz upstream
repository under `macosx/`. An earlier upgrade modernized the project for macOS 14 (Sonoma)
and Graphviz 12, but introduced build assumptions and interface elements incompatible with
macOS 11.0 on Apple Silicon.

## Concurrency matrix

| Phase | Concurrency mode | Target files | Verification target |
| :--- | :--- | :--- | :--- |
| **Phase 1** | Sequential | Git repository clone | Clean git tree on working branch |
| **Phase 2A** | Parallel | `project.pbxproj` | Target set to 11.0 |
| **Phase 2B** | Parallel | `Makefile`, `CMakeLists.txt` | Prefix resolution (`/opt/homebrew`) |
| **Phase 3A** | Parallel | `Document.xib` | SF Symbols compatibility under 11.0 |
| **Phase 3B** | Parallel | `Base.lproj/*.xib` | Nib compilation targeting macOS 11.0 |
| **Phase 4A** | Parallel | `GVExportViewController.m` | Nil check for `allowedContentTypes` |
| **Phase 4B** | Parallel | All `.m` compilation units | Build under `-target arm64-macos11` |
| **Phase 5** | Sequential | Application bundle | Mach-O `LC_BUILD_VERSION` and test |

## Phase 1: Repository initialization and branch setup [Sequential]

1. Clone `https://github.com/zosmac/graphviz_app.git` into the local repository root.
   - Target URI: `https://github.com/zosmac/graphviz_app.git`.
   - Branch: `main`.
2. Inspect the working tree and preserve commit history.
3. Create a dedicated feature branch `apple-silicon-macos11`.

Deliverables:
- Working git tree populated with all source files, project assets, and Makefiles.

## Phase 2: Build configuration and deployment targets [Sequential]

### Phase 2A: Xcode project build settings [Parallelizable]
1. Update `graphviz.xcodeproj/project.pbxproj`:
   - Set `MACOSX_DEPLOYMENT_TARGET = 11.0` across all configurations (`Debug` and `Release`)
     for both the project and `Graphviz` native target.
   - Configure `ARCHS = "arm64 x86_64"` (or `$(ARCHS_STANDARD)`) to generate Universal 2
     binaries with native Apple Silicon `arm64` slices.
   - Configure search paths to support standard Apple Silicon Homebrew paths alongside
     Intel paths:
     - `HEADER_SEARCH_PATHS = ("$(inherited)", "/opt/homebrew/include/graphviz",`
       `"/usr/local/include/graphviz", "/usr/local/graphviz/include/graphviz")`.
     - `LIBRARY_SEARCH_PATHS = ("$(inherited)", "/opt/homebrew/lib", "/usr/local/lib",`
       `"/usr/local/graphviz/lib")`.
     - `LD_RUNPATH_SEARCH_PATHS = ("$(inherited)", "@executable_path/../Frameworks",`
       `"/opt/homebrew/lib", "/usr/local/lib")`.
   - Ensure ad-hoc code signing (`CODE_SIGN_IDENTITY = "-"`) is enabled so the built binary
     satisfies Apple Silicon kernel code signature enforcement.

### Phase 2B: Makefile and CMake script updates [Parallelizable]
1. Update `Makefile`:
   - Replace hardcoded `PREFIX=/usr/local/graphviz` with dynamic prefix resolution:
     - If `/opt/homebrew/bin/dot` exists, set `PREFIX ?= /opt/homebrew`.
     - Else if `/usr/local/bin/dot` exists, set `PREFIX ?= /usr/local`.
     - Else fallback to `/usr/local/graphviz`.
   - Explicitly pass `MACOSX_DEPLOYMENT_TARGET=11.0` and `ARCHS="$(ARCH)"` to `xcodebuild`.
   - Add a fallback CLI compilation target using `clang` directly to build without Xcode GUI
     when only Command Line Tools are active.
2. Update `CMakeLists.txt`:
   - Update `PREFIX` detection for Apple Silicon Homebrew (`/opt/homebrew`).
   - Set `CMAKE_OSX_DEPLOYMENT_TARGET "11.0"`.
   - Ensure `CMAKE_OSX_ARCHITECTURES` defaults to `arm64` (or `arm64;x86_64`).

Deliverables:
- Updated `graphviz.xcodeproj/project.pbxproj` targeting macOS 11.0.
- Updated `Makefile` and `CMakeLists.txt` supporting `/opt/homebrew` and macOS 11.0.

## Phase 3: Interface and asset compatibility audit [Parallelizable]

### Phase 3A: Toolbar SF Symbols backward compatibility [Parallelizable]
1. In `Base.lproj/Document.xib`:
   - Item `100043` ("Zoom To Fit") currently references `square.arrowtriangle.4.outward`.
   - Apple introduced `square.arrowtriangle.4.outward` in SF Symbols 5 (macOS 14 Sonoma).
   - Under macOS 11 (SF Symbols 2), this symbol does not exist and fails to display.
   - Replace with `arrow.up.left.and.arrow.down.right`, which is supported on macOS 11.0.
2. Confirm the other toolbar symbols exist in SF Symbols 2 (macOS 11.0):
   - `info.circle` (Supported in macOS 11.0).
   - `minus.magnifyingglass` (Supported in macOS 11.0).
   - `1.magnifyingglass` (Supported in macOS 11.0).
   - `plus.magnifyingglass` (Supported in macOS 11.0).

### Phase 3B: XIB minimum tools and runtime configuration [Parallelizable]
1. Review all XIB files (`Document.xib`, `Attributes.xib`, `Export.xib`, `MainMenu.xib`):
   - Verify `targetRuntime="MacOSX.Cocoa"`.
   - Confirm compatibility attributes allow compilation against the macOS 11 SDK.

Deliverables:
- Updated `Base.lproj/Document.xib` compatible with macOS 11 SF Symbols.
- Verified XIB file suite compiling without deprecation errors.

## Phase 4: Code-level backward compatibility and safety audit [Parallelizable]

### Phase 4A: Export controller type safety [Parallelizable]
1. In `GVExportViewController.m`:
   - Inspect lines where `[UTType typeWithFilenameExtension:]` feeds `_panel.allowedContentTypes`.
   - `UTType` was introduced in macOS 11.0 (`@import UniformTypeIdentifiers;`).
   - If an unrecognized format extension produces `nil`, creating `@[type]` throws an
     `NSInvalidArgumentException`.
   - Add defensive guard:
     ```objc
     UTType *type = [UTType typeWithFilenameExtension:_formatRender[@"format"]];
     _panel.allowedContentTypes = type ? @[type] : @[];
     ```

### Phase 4B: Codebase API audit against macOS 11 SDK [Parallelizable]
1. Audit all Objective-C files against macOS 11.0 symbols:
   - `GVApplicationDelegate.m`
   - `GVAttributeInspectorController.m`
   - `GVAttributeSchema.m`
   - `GVDocument.m`
   - `GVFileNotificationCenter.m`
   - `GVGraphArguments.m`
   - `GVGraphDefaultAttributes.m`
   - `GVWindowController.m`
   - `GVZGraph.m`
   - `main.m`
2. Verify that no methods or classes requiring macOS 12, 13, 14, or later are called without
   `@available(macOS 12.0, *)` runtime guards.

Deliverables:
- Patched `GVExportViewController.m` with guarded array instantiation.
- Verified Objective-C source files clean of ungated post-macOS 11 APIs.

## Phase 5: Build verification and validation [Sequential]

1. Build the application for `arm64` with deployment target 11.0:
   - Run compilation via `xcodebuild` or `make`.
2. Inspect the resulting binary with Mach-O inspection tools:
   - Run `lipo -info /Applications/Graphviz.app/Contents/MacOS/Graphviz` to verify `arm64`.
   - Run `otool -l /Applications/Graphviz.app/Contents/MacOS/Graphviz | grep -A 4 LC_BUILD_VERSION`
     to verify:
     - `platform MACOS`
     - `minos 11.0`
3. Execute functional verification:
   - Launch `Graphviz.app` using `open /Applications/Graphviz.app`.
   - Open a sample `.gv` / `.dot` file.
   - Verify layout rendering with `pdf:quartz`.
   - Verify export dialog and toolbar buttons (including "Zoom To Fit").
