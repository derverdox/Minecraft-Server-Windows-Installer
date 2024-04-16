# Initialize config
$ConfigDatei = "config.json"
$StandardValues = @{
    "minecraftVersion" = "1.20.4"
    "javaArgs" = "-Dfile.encoding=UTF8 -Xmx4G"
    "mcArgs" = "--nogui"
}

# Überprüfen, ob die Konfigurationsdatei existiert
if (Test-Path $ConfigDatei -PathType Leaf) {
    # Lese den Inhalt der Konfigurationsdatei ein
    $config = Get-Content -Path $ConfigDatei | ConvertFrom-Json
} else {
    # Verwende Standardwerte, wenn die Konfigurationsdatei nicht existiert
    $StandardValues | ConvertTo-Json -Depth 1 | Out-File -FilePath $ConfigDatei
    $config = Get-Content -Path $ConfigDatei | ConvertFrom-Json
}



# Definieren der Variablen
$VERSION = $config.minecraftVersion
$JAVA_ARGS = $config.javaArgs
$MC_ARGS = $config.mcArgs
$SERVER_JAR_PATH = "server.jar"


# Interne Variablen -> NICHT ABÃ„NDERN
$JDK_FOLDER = "jdk"
$JDK_JAR_PATH = "$JDK_FOLDER\jdk-22\bin\java.exe"
$JDK_DOWNLOAD_URL = "https://download.java.net/java/GA/jdk22/830ec9fcccef480bb3e73fb7ecafe059/36/GPL/openjdk-22_windows-x64_bin.zip"



# ÃœberprÃ¼fen, ob Java installiert ist
if (-Not (Test-Path $JDK_JAR_PATH)) {
    Write-Host "No Java Version found"

    Write-Host "Downloading file..."
	Write-Host "`n"
    & curl.exe -o "temp.zip" $JDK_DOWNLOAD_URL
    Write-Host "Download complete."

    Write-Host "Extracting file..."
    Expand-Archive -Path "temp.zip" -DestinationPath $JDK_FOLDER
    Write-Host "Extraction complete."
	cls

    Write-Host "Java Version installed successfully"
    Remove-Item "temp.zip"
	Write-Host "`n"
}

# ÃœberprÃ¼fen, ob der Server-JAR-Pfad existiert
if (-Not (Test-Path $SERVER_JAR_PATH)) {
    Write-Host "Installing the latest build for Minecraft Paper Version $VERSION"
    Write-Host "Fetching version from https://api.papermc.io/v2/projects/paper/versions/$VERSION"
	Write-Host "`n"

    try {
        $url = "https://api.papermc.io/v2/projects/paper/versions/$VERSION"
        $response = Invoke-RestMethod -Uri $url
        if ($response.builds -and $response.builds.Count -gt 0) {
            $latestBuild = $response.builds[-1]
            $downloadUrl = "https://api.papermc.io/v2/projects/paper/versions/$VERSION/builds/$latestBuild/downloads/paper-$VERSION-$latestBuild.jar"
            Write-Host "Download URL: $downloadUrl"

            Write-Host "Downloading the latest PaperMC build for Version $VERSION..."
			Write-Host "`n"
            & curl.exe -o $SERVER_JAR_PATH $downloadUrl
            cls
			
            Write-Host "Download complete."
        } else {
            Write-Host "No builds found for version $VERSION"
        }
    } catch {
        Write-Host "Error fetching build: $($_.Exception.Message)"
    }
}

& $JDK_JAR_PATH $JAVA_ARGS -jar $SERVER_JAR_PATH $MC_ARGS

# Pause in PowerShell
Write-Host "Press any key to continue ..."
$x = $host.UI.RawUI.ReadKey("NoEcho,IncludeKeyDown")
