$apps = @(
  "https://<you>.github.io/installer-hub/installers/chrome/ChromeSetup.exe",
  "https://<you>.github.io/installer-hub/installers/vscode/VSCodeSetup-x64.exe"
)

foreach ($app in $apps) {
  $file = "$env:TEMP\" + ($app.Split('/')[-1])
  Invoke-WebRequest $app -OutFile $file
  Start-Process $file -Wait
}
