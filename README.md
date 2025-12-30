# PowerShell Profile

This repository contains my personal PowerShell profile configuration, designed to create a productive, aesthetically pleasing, and efficient command-line environment on Windows.

## Features

### 🛠 Core Configuration
- **Editor Auto-Detection**: Automatically selects the best available editor from a preferred list (Neovim, VS Code, Notepad++, etc.).
- **Safe Module Loading**: Helper functions to prevent errors when modules are missing.
- **Cross-Platform Utilities**: Implements Linux-style commands (`sudo`, `grep`, `touch`, `df`) for Windows.
- **Dependency Checks**: Smartly handles optional tools like `oh-my-posh`, `zoxide`, `eza`, and `fastfetch`.

### 🎨 Visuals & Theming
- **Oh My Posh**: Integrated shell theming (configured for `hotanphat2.omp.json`).
- **Terminal Icons**: Adds file type icons to directory listings.
- **Fastfetch**: Displays system information on startup.
- **PSReadLine Coloring**: Custom "Brand Golden" color scheme for syntax highlighting.

### 🚀 Productivity Tools
- **Zoxide**: Smarter `cd` alternative for jumping directories.
- **Eza**: Modern replacement for `ls`/`dir` with colors and icons (aliased to `ll`).
- **Git Aliases**: Extensive shortcuts for common Git workflows (`lazyg`, `gstatus`, `gbranch`, etc.).
- **WSL Helpers**: Shortcuts for managing WSL distributions (`wsll`, `wsllo`).

### ⌨️ Key Bindings & Shortcuts
- **Navigation**: `..`, `...` for directory traversal.
- **System**: `sysinfo`, `which`, `open`.
- **Management**:
    - `Edit-Profile`: Open this profile in your default editor.
    - `Reload-Profile`: Apply changes immediately.
    - `Show-Help`: Display a cheat sheet of available custom commands.

## Installation

### 1. Prerequisites
Ensure you have the following installed for the full experience:
- [PowerShell 7+](https://github.com/PowerShell/PowerShell)
- [Unnerdv/Nerd Fonts](https://www.nerdfonts.com/) (e.g., JetBrainsMono Nerd Font)
- [Oh My Posh](https://ohmyposh.dev/)
- [Zoxide](https://github.com/ajeetdsouza/zoxide)
- [Eza](https://github.com/eza-community/eza) (optional, requires specific installation on Windows)
- [Fastfetch](https://github.com/fastfetch-cli/fastfetch)
- Modules: `Terminal-Icons`, `PSReadLine`

### 2. Setup
Clone this repository or copy the content of `Microsoft.PowerShell_profile.ps1` to your PowerShell profile path.

```powershell
# Check your profile path
$PROFILE
```

You can symlink it for easy updates:

```powershell
# Example (adjust paths as needed)
New-Item -ItemType SymbolicLink -Path $PROFILE -Target "C:\path\to\cloned\repo\Microsoft.PowerShell_profile.ps1"
```

## Usage

Once installed, simply open a new PowerShell instance.

Type `Show-Help` to see a list of custom commands and aliases available to you.

## Customization

- **Editors**: Modify the `$Editors` array in the script to change priority.
- **Theme**: Update the oh-my-posh config path in the initialization section if your theme is located elsewhere.
- **Colors**: Adjust the `$BrandColors` hash table for different PSReadLine syntax highlighting preferences.
