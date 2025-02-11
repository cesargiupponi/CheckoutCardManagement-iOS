# Adding CocoaPods Support to CheckoutCardManagement SPM Library

## Table of Contents
- [Overview](#overview)
- [Repository Setup](#repository-setup)
  - [Fork Management](#fork-management)
  - [Synchronizing with Upstream](#synchronizing-with-upstream)
  - [Fetching tags from Upstream](#fetching-tags-from-upstream)
  - [Using GitHub Interface](#using-github-interface)
  - [Handling Conflicts](#handling-conflicts)
  - [Best Practices for Fork Maintenance](#best-practices-for-fork-maintenance)
- [Existing SPM Structure](#existing-spm-structure)
  - [Understanding Package.swift](#understanding-packageswift)
  - [Dynamic Library Configuration](#dynamic-library-configuration)
- [Adding CocoaPods Support](#adding-cocoapods-support)
  - [Understanding the .podspec File](#understanding-the-podspec-file)
  - [Framework Bundles Management](#framework-bundles-management)
    - [Directory Structure](#directory-structure)
    - [Handling Framework Dependencies](#handling-framework-dependencies)
  - [XCFramework Generation](#xcframework-generation)
  - [Dependencies Management](#dependencies-management)
- [Testing and Validation](#testing-and-validation)
- [Maintenance Guide](#maintenance-guide)
  - [Version Management](#version-management)
- [Troubleshooting Guide](#troubleshooting-guide)

## Overview

This guide provides comprehensive documentation for adding CocoaPods support to the CheckoutCardManagement iOS library, which currently uses Swift Package Manager (SPM). By implementing this dual-support system, we enable broader compatibility with iOS projects using either dependency management solution.

## Repository Setup

### Fork Management

The solution begins with creating a fork of the original repository:
- Original: https://github.com/checkout/CheckoutCardManagement-iOS
- Fork: https://github.com/cesargiupponi/CheckoutCardManagement-iOS

### Synchronizing with Upstream

Keeping your fork synchronized with the upstream repository is crucial for maintaining compatibility and incorporating new features. Here's a detailed synchronization process:

1. Configure the upstream remote (only needed once):
```bash
# Add the upstream repository
git remote add upstream https://github.com/checkout/CheckoutCardManagement-iOS.git

# Verify the new remote
git remote -v
```

2. Fetch the latest changes from upstream:
```bash
# Fetch all branches and their respective commits
git fetch upstream
```

3. Check out your fork's local main branch:
```bash
git checkout main
```

4. Merge upstream changes:
```bash
# Merge changes from upstream/main into your local main branch
git merge upstream/main
```

5. Push the updated code to your fork:
```bash
git push origin main
```

### Fetching tags from Upstream

Keeping your tags synchronized with the upstream repository is crucial for maintaining compatibility and incorporating new features. Here's a detailed synchronization process:

1. Configure the upstream remote (only needed once):
```bash
# Add the upstream repository
git remote add upstream https://github.com/checkout/CheckoutCardManagement-iOS.git

# Verify the new remote
git remote -v
```

2. Fetch the latest tags from upstream:
```bash
# Fetch all tags
git fetch --tags upstream
```

3. Push the updated code to your fork:
```bash
git push --tags
```

#### Using GitHub Interface

1. Navigate to your fork on GitHub
2. Click the "Sync fork" dropdown
3. Review the status of your branch
4. Click "Update branch" if behind the upstream repository

### Handling Conflicts

When synchronizing with upstream, you might encounter merge conflicts. Here's how to handle them:

1. If conflicts occur during merge:
```bash
# Check which files have conflicts
git status

# Resolve conflicts in each file
# Look for markers like <<<<<<< HEAD, =======, and >>>>>>>

# After resolving, stage the files
git add .

# Complete the merge
git commit -m "Resolve merge conflicts with upstream"
```

2. If you need to abort the merge:
```bash
git merge --abort
```

### Best Practices for Fork Maintenance

To ensure smooth synchronization and maintenance:

1. Sync regularly with upstream
2. Create feature branches for CocoaPods-specific changes
3. Keep commit messages clear and descriptive
4. Document any divergences from upstream
5. Test thoroughly after each sync

## Existing SPM Structure

### Understanding Package.swift

The Package.swift file serves as the foundation for SPM implementation. Dyna

```swift
// Package.swift
import PackageDescription

let package = Package(
    name: "CheckoutCardManagement-iOS",
    platforms: [
        .iOS(.v13),
    ],
    products: [
        .library(
            name: "CheckoutCardManagement",
            type: .dynamic,
            targets: ["CheckoutCardManagement"]),
        .library(
            name: "CheckoutCardManagementStub",
            targets: ["CheckoutCardManagementStub"]),
        .library(
            name: "CheckoutOOBSDK",
            targets: ["CheckoutOOBSDK"]),
    ],
    dependencies: [
        .package(
            url: "https://github.com/checkout/checkout-event-logger-ios-framework",
            from: "1.2.1"),
    ],
    targets: [
        .target(
            name: "CheckoutCardManagement",
            dependencies: [
                .product(
                    name: "CheckoutEventLoggerKit",
                    package: "checkout-event-logger-ios-framework"),
                "CheckoutCardNetwork",
            ]),
        .target(
            name: "CheckoutCardManagementStub",
            dependencies: [
                .product(
                    name: "CheckoutEventLoggerKit",
                    package: "checkout-event-logger-ios-framework"),
                "CheckoutCardNetworkStub",
            ]),
        .binaryTarget(
            name: "CheckoutCardNetwork",
            path: "SupportFrameworks/CheckoutCardNetwork.xcframework"),
        .binaryTarget(
            name: "CheckoutCardNetworkStub",
            path: "SupportFrameworks/CheckoutCardNetworkStub.xcframework"),
        .binaryTarget(
            name: "CheckoutOOBSDK",
            path: "SupportFrameworks/CheckoutOOBSDK.xcframework"),
    ]
)
```

### Dynamic Library Configuration

The `.dynamic` type specification in Package.swift that has added is crucial for several reasons:

1. Runtime Loading: Enables dynamic loading of the framework at runtime
2. Resource Bundling: Facilitates proper bundling of resources
3. Dependency Compatibility: Provides better interoperability with dynamic dependencies
4. CocoaPods Integration: Aligns with CocoaPods' framework distribution model

## Adding CocoaPods Support

### Understanding the .podspec File

The `.podspec` file is crucial for CocoaPods integration, defining the library's specifications, dependencies, and managing framework bundles. The `vendored_frameworks` directive specifies which framework bundles should be distributed with your pod:
 
 Here's a breakdown of the key components:

```ruby
Pod::Spec.new do |s|
  s.name = "CheckoutCardManagement"
  s.version = "1.1.4"
  s.summary = "Checkout Card Management"
  s.description = <<-DESC
    Checkout Card Management
    This library contains cards management for Checkout iOS SDKs
  DESC
  s.homepage = "https://github.com/checkout/CheckoutCardManagement-iOS"
  s.swift_version = "5.7"
  s.license = "MIT"
  s.author = { "Checkout.com Integration" => "integration@checkout.com" }
  s.platform = :ios, "11.0"
  s.source = { 
    :git => "https://github.com/checkout/CheckoutCardManagement-iOS.git",
    :tag => "#{s.version}"
  }
  
  # Framework bundles specification
  s.vendored_frameworks = [
    # Main framework
    "CheckoutCardManagement.xcframework",
    
    # Support frameworks in their dedicated folder
    "SupportFrameworks/CheckoutCardNetwork.xcframework",
    "SupportFrameworks/SecureLogAPI.xcframework"
  ]
  
  # External dependencies
  s.dependency "CheckoutEventLoggerKit"
end
```

This podspec is essential because it:
1. Defines the package metadata that matches the SPM configuration
2. Specifies the same platform requirements as the SPM package
3. References the XCFramework that will be generated from the SPM library
4. Maintains consistency with existing dependencies

### Framework Bundles Management

#### Directory Structure
Your repository should maintain the following structure for framework management:

```
Repository Root/
├── CheckoutCardManagement.xcframework/    # Main framework
│   ├── ios-arm64/
│   │   └── CheckoutCardManagement.framework/
│   └── ios-x86_64-simulator/
│       └── CheckoutCardManagement.framework/
├── SupportFrameworks/                     # Support frameworks folder
│   ├── CheckoutCardNetwork.xcframework/
│   │   ├── ios-arm64/
│   │   └── ios-x86_64-simulator/
│   └── SecureLogAPI.xcframework/
│       ├── ios-arm64/
│       └── ios-x86_64-simulator/
├── Package.swift
├── CheckoutCardManagement.podspec
└── README.md
```

#### Handling Framework Dependencies

When your vendored frameworks have their own dependencies:

1. External dependencies should be declared:
```ruby
s.dependency "CheckoutEventLoggerKit"
```

2. Internal dependencies between vendored frameworks are handled automatically if they're in the correct paths

### XCFramework Generation

To support CocoaPods distribution, we need to generate an XCFramework. It has created a build script named `generate-xcframework.sh`:

```bash
#!/bin/bash

set -x
set -e

# Pass scheme name as the first argument to the script
NAME=$1

# Build the scheme for all platforms that we plan to support
for PLATFORM in "iOS" "iOS Simulator"; do

    case $PLATFORM in
    "iOS")
    RELEASE_FOLDER="Release-iphoneos"
    ;;
    "iOS Simulator")
    RELEASE_FOLDER="Release-iphonesimulator"
    ;;
    esac

    ARCHIVE_PATH=$RELEASE_FOLDER

    xcodebuild archive -scheme $NAME \
            -destination "generic/platform=$PLATFORM" \
            -archivePath $ARCHIVE_PATH \
            -derivedDataPath ".build" \
            SKIP_INSTALL=NO BUILD_LIBRARY_FOR_DISTRIBUTION=YES

    FRAMEWORK_PATH="$ARCHIVE_PATH.xcarchive/Products/usr/local/lib/$NAME.framework"
    MODULES_PATH="$FRAMEWORK_PATH/Modules"
    mkdir -p $MODULES_PATH

    BUILD_PRODUCTS_PATH=".build/Build/Intermediates.noindex/ArchiveIntermediates/$NAME/BuildProductsPath"
    RELEASE_PATH="$BUILD_PRODUCTS_PATH/$RELEASE_FOLDER"
    SWIFT_MODULE_PATH="$RELEASE_PATH/$NAME.swiftmodule"
    RESOURCES_BUNDLE_PATH="$RELEASE_PATH/${NAME}_${NAME}.bundle"

    # Copy Swift modules
    if [ -d $SWIFT_MODULE_PATH ]
    then
        cp -r $SWIFT_MODULE_PATH $MODULES_PATH
    else
        # In case there are no modules, assume C/ObjC library and create module map
        echo "module $NAME { export * }" > $MODULES_PATH/module.modulemap
    fi

    # Copy resources bundle, if exists
    if [ -e $RESOURCES_BUNDLE_PATH ]
    then
        cp -r $RESOURCES_BUNDLE_PATH $FRAMEWORK_PATH
    fi

done

xcodebuild -create-xcframework \
-framework Release-iphoneos.xcarchive/Products/usr/local/lib/$NAME.framework \
-framework Release-iphonesimulator.xcarchive/Products/usr/local/lib/$NAME.framework \
-output $NAME.xcframework
```

Executing the script:
```bash
sh generate-xcframework.sh
```

### Dependencies Management

Managing dependencies:

1. Directory Structure:
```
Repository Root/
├── Package.swift
├── Sources/
├── Tests/
├── CheckoutCardManagement.podspec
├── CheckoutCardManagement.xcframework/
└── SupportFrameworks/
    └── SecureLogAPI.xcframework/
    └── CheckoutOOBSDK.xcframework/
    └── CheckoutCardNetworkStub.xcframework/
    └── CheckoutCardNetwork.xcframework/
```

2. Dependency Specifications:
   - In Package.swift: Referenced as a binary target
   - In podspec: Listed under vendored_frameworks

## Testing and Validation

1. CocoaPods Integration Test:
```ruby
# Podfile in test project
...

target 'Runner' do
  use_frameworks!
  use_modular_headers!

  pod 'PhoneNumberKit', '~> 3.7.6'
  pod 'CheckoutCardManagement', :git => 'https://github.com/cesargiupponi/CheckoutCardManagement-iOS.git', :branch => 'feat/add-cocoapods-support'

  flutter_install_all_ios_pods File.dirname(File.realpath(__FILE__))
end
```

3. Validate podspec:
```bash
pod spec lint CheckoutCardManagement.podspec
```

## Maintenance Guide

### Version Management

1. Update both specifications when releasing:
   - Package.swift version
   - Podspec version
   - Git tag

2. Maintain changelog entries

## Troubleshooting Guide

Common issues and their solutions:

1. Framework Not Found
   - Verify XCFramework generation completed successfully
   - Check all paths in podspec
   - Ensure frameworks are added to source control

2. Dependency Conflicts
   - Compare version requirements between SPM and CocoaPods
   - Update dependency versions as needed
   - Clear CocoaPods cache: `pod cache clean --all`

3. Build Errors
   - Verify minimum deployment target consistency
   - Check architecture compatibility
   - Validate Swift version settings

For additional support or questions, please open an issue in the repository or consult the following resources:
- [CocoaPods Guides](https://guides.cocoapods.org)
- [Swift Package Manager Documentation](https://www.swift.org/package-manager/)
- [GitHub Fork Synchronization Guide](https://docs.github.com/en/pull-requests/collaborating-with-pull-requests/working-with-forks/syncing-a-fork)