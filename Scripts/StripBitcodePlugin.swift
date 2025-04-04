import PackagePlugin

@main
struct StripBitcodePlugin: BuildToolPlugin {
    func createBuildCommands(context: PluginContext, target: Target) async throws -> [Command] {
        let scriptPath = context.package.directory.appending("Scripts/strip-bitcode.sh")
        
        return [
            .prebuildCommand(
                displayName: "Strip Bitcode from SecureLogAPI",
                executable: scriptPath,
                arguments: [],
                environment: [:]
            )
        ]
    }
} 