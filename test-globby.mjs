import { globby } from "globby"

try {
	const files = await globby("**/*.proto", { cwd: "proto" })
	console.log("Found proto files:", files)
} catch (error) {
	console.error("Error with globby:", error.message)
}
