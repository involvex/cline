@echo off
setlocal enabledelayedexpansion

echo Fixing import statements in Go files...

for /r cli %%f in (*.go) do (
    echo Processing %%f
    powershell -Command "(Get-Content '%%f') -replace 'github\.com/cline/grpc-go/client', 'github.com/cline/cli/pkg/generated/client' | Set-Content '%%f'"
    powershell -Command "(Get-Content '%%f') -replace 'github\.com/cline/grpc-go/cline', 'github.com/cline/cli/pkg/generated/cline' | Set-Content '%%f'"
    powershell -Command "(Get-Content '%%f') -replace 'github\.com/cline/grpc-go/host', 'github.com/cline/cli/pkg/generated/host' | Set-Content '%%f'"
)

echo Import fixes complete!
