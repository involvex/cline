const fs = require("fs")
const path = require("path")

function updateProtoFiles(dir) {
	const files = fs.readdirSync(dir, { withFileTypes: true })

	for (const file of files) {
		const fullPath = path.join(dir, file.name)

		if (file.isDirectory()) {
			updateProtoFiles(fullPath)
		} else if (file.name.endsWith(".proto")) {
			console.log(`Updating ${fullPath}`)
			let content = fs.readFileSync(fullPath, "utf8")

			// Update go_package declarations
			content = content.replace(
				/option go_package = "github\.com\/cline\/grpc-go\/cline";/g,
				'option go_package = "github.com/cline/cli/pkg/generated/cline";',
			)
			content = content.replace(
				/option go_package = "github\.com\/cline\/grpc-go\/host";/g,
				'option go_package = "github.com/cline/cli/pkg/generated/host";',
			)

			fs.writeFileSync(fullPath, content)
		}
	}
}

updateProtoFiles("./proto")
console.log("All proto files updated!")
