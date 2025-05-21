# GST - Go Set Alias (Quick Shell Alias Manager)

![Shell Support](https://img.shields.io/badge/Shell-Bash%20%7C%20Zsh%20%7C%20Fish-blue) <!-- Replace with actual badge if available -->
![License](https://img.shields.io/badge/License-MIT-green) <!-- Replace with actual badge and ensure LICENSE.md exists -->
<!-- [![Version](https://img.shields.io/badge/Version-v1.0.0-orange)](link-to-releases) -->

## 1. Introduction

Tired of manually wrestling with shell configuration files every time you need a quick alias? `gst` is your **speedy shortcut to shell efficiency!** This handy command-line utility lets you swiftly add, update, or temporarily set shell aliases for Bash, Zsh, and Fish, all without the usual hassle of editing config files. Say goodbye to friction and hello to fluent alias management!

## 2. Demo

![Demo GIF](gst.gif)

## 3. Why GST?

### The Problem

We've all been there: you want to create a simple shortcut for a long command. This usually means opening `~/.bashrc`, `~/.zshrc`, or `~/.config/fish/config.fish`, carefully finding the right spot, typing `alias mycmd='some long command'`, saving, and then *remembering* to `source` the file. It's a cumbersome process for what should be a quick task, especially for those everyday, throwaway aliases.

### The Solution

`gst` **slashes through that tedious workflow!** It removes the friction from alias management by offering a streamlined, command-line-driven approach. Whether you need an alias for the next five minutes or the next five years, `gst` makes it fast and effortless.

## 4. Key Features

`gst` empowers you with a range of features designed to simplify your shell experience:

*   **Rapid Alias Management:** Quickly add, update, or temporarily set shell aliases directly from your terminal.
*   **Broad Shell Compatibility:** Works seamlessly with Bash, Zsh, and Fish shells.
*   **Effortless Temporary Aliases:** Create aliases for your current session without touching any configuration files.
*   **Simplified Permanent Aliases:** Streamlines the process of making your favorite shortcuts permanent.
*   **Intuitive Syntax:** Designed for ease of use and quick adoption.

## 5. Installation

1.  **Get the script:**
    *   The `gst` script is named `gst.sh` and is located in this repository. You will need to copy its content or download it.
2.  **Make it executable:**
    ```bash
    chmod +x gst.sh
    ```
3.  **Move it to a directory in your PATH:**
    *   A common location is `~/.local/bin`. If this directory doesn't exist, create it first:
        ```bash
        mkdir -p ~/.local/bin
        ```
    *   Then, move the script:
        ```bash
        mv gst.sh ~/.local/bin/gst
        ```
4.  **Verify PATH:**
    *   Ensure `~/.local/bin` is included in your shell's `PATH`. You can check this by running:
        ```bash
        echo $PATH
        ```
    *   If it's not there, add it to your shell's configuration file (e.g., `~/.bashrc`, `~/.zshrc`, or `~/.config/fish/config.fish`). For example, you could add the following line (for Bash/Zsh):
        ```bash
        export PATH="$HOME/.local/bin:$PATH"
        ```
        For Fish shell, the syntax is different:
        ```fish
        set -gx PATH "$HOME/.local/bin" $PATH
        ```
    *   Remember to source your configuration file (e.g., `source ~/.bashrc`) or open a new terminal session for the changes to take effect.

## 6. Setup

To make `gst` even easier to use, set up the `gsta` wrapper function in your shell's configuration file. This function allows `gst` to directly modify your current shell session's aliases, making the experience even smoother.

### Bash

Add the following function to your `~/.bashrc` file:

```bash
gsta() {
    if [ "$#" -eq 0 ]; then gst; return; fi
    local output; output=$(gst "$@")
    if [ -n "$output" ]; then eval "$output"; fi
}
```
After adding, reload your configuration by running:
```bash
source ~/.bashrc
```
Or, open a new terminal session.

### Zsh

Add the following function to your `~/.zshrc` file:

```bash
gsta() {
    if [ "$#" -eq 0 ]; then gst; return; fi
    local output; output=$(gst "$@")
    if [ -n "$output" ]; then eval "$output"; fi
}
```
After adding, reload your configuration by running:
```bash
source ~/.zshrc
```
Or, open a new terminal session.

### Fish

Add the following function to your `~/.config/fish/config.fish` file:

```fish
function gsta
    if count $argv > /dev/null
        gst $argv | source
    else
        gst
    end
end
```
After adding, reload your configuration by running:
```fish
source ~/.config/fish/config.fish
```
Or, open a new terminal session.

## 7. Usage

Once `gst` is installed and the `gsta` wrapper function (from the Setup section) is configured in your shell, you can manage aliases as follows.

> **Note:** Behavior for updating and removing aliases should be verified with the `gst.sh` script's functionality, as the script's exact mechanisms for these actions are not detailed here. It's assumed that `gst` will overwrite an existing alias if you define it again.

### Creating Permanent Aliases

Permanent aliases are saved to your shell's configuration file and will be available in future sessions.

*   **Simple alias:** Create an alias `lsl` for the command `ls -la`.
    ```bash
    gsta lsl "ls -la"
    ```

*   **Alias with multiple options and arguments:** Create `mygit` for a complex Git log command.
    ```bash
    gsta mygit "git log --oneline --decorate --all --graph"
    ```

*   **Alias for a sequence of commands:** Create `godeploy` to change directory and run a script. (Ensure the path `/my/project` is correct for your use case).
    ```bash
    gsta godeploy "cd /my/project && ./deploy.sh"
    ```

### Creating Temporary Aliases

Temporary aliases are set only for the current shell session and will be gone when the session ends. Use the `-t` flag.

*   **Simple temporary alias:** Create a temporary alias `ll`.
    ```bash
    gsta -t ll "ls -lh"
    ```

*   **Temporary alias for a sequence of commands:** Create `proddb` for an SSH tunnel, only for the current session.
    ```bash
    gsta -t proddb "ssh user@prod-server -p 2222 -L 5432:localhost:5432"
    ```

### Viewing Aliases

To view aliases:

*   **Using `gst` directly (if it supports listing):**
    ```bash
    gst
    ```
*   **Using the `gsta` wrapper (if configured to call `gst` with no arguments):**
    ```bash
    gsta
    ```
*   **Using your shell's built-in command (shows all aliases):**
    For Bash/Zsh:
    ```bash
    alias
    ```
    For Fish:
    ```fish
    functions -t # or simply `functions` to see all functions including aliases
    ```
    > **Note:** `gst` might only list aliases it directly manages. Using your shell's built-in command provides a comprehensive list.

### Updating Aliases

To update an existing alias, it's generally assumed you can run the `gsta` command again with the same alias name and the new command string.

*   **Updating an existing permanent alias:** If `lsl` was `ls -la`, to change it to `ls -alh`:
    ```bash
    gsta lsl "ls -alh"
    ```

> **Note:** This assumes `gst` overwrites the existing alias. Please verify this behavior with the `gst.sh` script. If it doesn't overwrite, you might need to remove the old alias manually first from your shell configuration file.

### Removing Aliases

*   **Temporary Aliases:**
    Temporary aliases are automatically removed when your current shell session ends. No command is needed.

*   **Permanent Aliases:**
    The `gst` script's specific mechanism for removing permanent aliases is not detailed in this README.
    *   **Check the script:** Look for a removal option in the script's help output (e.g., `gst --help`) or its source code (e.g., `gsta -r alias_name` or `gst --remove alias_name`).
    *   **Manual Removal:** If `gst` does not provide a direct removal command, you will need to manually edit your shell's configuration file (`~/.bashrc`, `~/.zshrc`, or `~/.config/fish/config.fish`). Delete the line defining the alias (e.g., `alias lsl="ls -alh"`), and then source the file or open a new terminal.

> **Note:** The exact method for removing permanent aliases managed by `gst` should be verified by checking the `gst.sh` script's functionality.

## 8. Contributing

Contributions are welcome! Please feel free to submit pull requests or open issues. We're excited to see how the community can help make `gst` even better!
```
