# Setup notes: Mac (Apple Silicon)

Here's what I installed, and the snags I hit along the way.

## Install

```bash
# Homebrew (then run the two "eval" lines it prints)
/bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"

brew install python git openjdk@17 android-commandlinetools
curl -fsSL https://claude.ai/install.sh | bash    # Claude Code
```

## Snags and fixes

| Problem | Cause | Fix |
|---|---|---|
| `brew install --cask android-platform-tools` → 404 | Homebrew pointed to a platform-tools version Google no longer hosts | Install adb with the SDK manager instead (below) |
| `sdkmanager` → "Unable to locate a Java Runtime" | Homebrew's `openjdk@17` is keg-only, so it isn't on the PATH | Set `JAVA_HOME` (below) |
| `claude: command not found` after install | `~/.local/bin` isn't on the PATH | `echo 'export PATH="$HOME/.local/bin:$PATH"' >> ~/.zshrc && source ~/.zshrc` |
| Terminal missing from Privacy → Local Network | macOS only lists an app after it tries the local network | Run `adb connect <tv-ip>:5555` once, then click **Allow** |
| Claude Code login opened the wrong browser | It uses the default browser | Copy the login URL from Terminal into the browser you want |

```bash
echo 'export JAVA_HOME="/opt/homebrew/opt/openjdk@17"' >> ~/.zprofile
echo 'export PATH="$JAVA_HOME/bin:$PATH"' >> ~/.zprofile
echo 'export PATH="/opt/homebrew/share/android-commandlinetools/platform-tools:$PATH"' >> ~/.zprofile
source ~/.zprofile
sdkmanager "platform-tools" "platforms;android-34" "build-tools;34.0.0"
```

Don't use JDK 23 or newer: Gradle 8.9 in the launcher build stops with it.

## On the TV

Settings → Device Preferences → About → press OK on **Build** 7 times → Developer options → **USB debugging** on.
No cable needed; everything runs over Wi-Fi. Accept "Allow USB debugging?" on the TV when it appears.
