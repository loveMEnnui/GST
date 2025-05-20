# GST - Go Set Alias (Quick Shell Alias Manager)

`gst` is a command-line utility to quickly add, update, or temporarily set shell aliases without manually editing your shell configuration files. It supports Bash, Zsh, and Fish shells.

## The Problem

Remembering to open `~/.bashrc`, `~/.zshrc`, or `~/.config/fish/config.fish`, find the right spot, type `alias mycmd='some long command'`, save, and then `source` the file can be a hassle for quick, everyday aliases.

## The Solution

`gst` streamlines this process:

```bash

# simplest way to make a wrapper

# .bashrc or zshrc

gsta() {
    if [ "$#" -eq 0 ]; then gst; return; fi
    local output; output=$(gst "$@");
    if [ -n "$output" ]; then eval "$output"; fi
}

# for fish

function gsta
    if count $argv > /dev/null; gst $argv | source
    else; gst; end
end

```

How to Use gst

## Setup:

* Save the code above as gst.sh.
 
* Make it executable: chmod +x gst.sh
 
* Move it to a directory in your PATH, e.g., ~/.local/bin/gst:*
  
* mkdir -p ~/.local/bin
  
* mv gst.sh ~/.local/bin/gst
 
* Ensure ~/.local/bin is in your PATH (add to .bashrc, .zshrc, or config.fish if not already).

  
