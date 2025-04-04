#!/bin/bash

# Script to strip bitcode from SecureLogAPI framework
FRAMEWORK_PATH="SupportFrameworks/SecureLogAPI.xcframework"

# Function to strip bitcode from a binary
strip_bitcode() {
    local binary_path=$1
    echo "Stripping bitcode from: $binary_path"
    
    # Remove bitcode section
    xcrun bitcode_strip -r "$binary_path" -o "$binary_path"
    
    # Verify bitcode was removed
    if xcrun otool -l "$binary_path" | grep -q "LLVM"; then
        echo "Warning: Bitcode section still present in $binary_path"
    else
        echo "Successfully stripped bitcode from $binary_path"
    fi
}

# Process each architecture in the xcframework
for platform in "ios-arm64" "ios-arm64_x86_64-simulator"; do
    framework_path="$FRAMEWORK_PATH/$platform/SecureLogAPI.framework"
    binary_path="$framework_path/SecureLogAPI"
    
    if [ -f "$binary_path" ]; then
        strip_bitcode "$binary_path"
    else
        echo "Warning: Binary not found at $binary_path"
    fi
done

echo "Bitcode stripping complete" 