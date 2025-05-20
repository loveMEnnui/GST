#!/usr/bin/env bash

print_usage() {
    local script_name
    script_name=$(basename "$0")
    echo "Usage: $script_name [-t | --temp] <alias_name> <command_word1> [command_word2 ...]"
    echo "Options:"
    echo "  -t, --temp, --temporary   Create a temporary alias for the current session only."
    echo ""
    echo "Examples (Permanent + Current Session Activation):"
    echo "  Bash/Zsh: eval \"\$($script_name ll ls -alhF)\""
    echo "  Fish:     $script_name ll ls -alhF | source"
    echo ""
    echo "Examples (Temporary Alias Activation):"
    echo "  Bash/Zsh: eval \"\$($script_name -t srv 'python3 -m http.server')\""
    echo "  Fish:     $script_name -t srv 'python3 -m http.server' | source"
}

temporary_alias=0
alias_name=""
command_parts=()

while [[ "$#" -gt 0 ]]; do
    case "$1" in
        -t|--temp|--temporary)
            temporary_alias=1
            shift
            ;;
        -h|--help)
            print_usage
            exit 0
            ;;
        *)
            if [ -z "$alias_name" ]; then
                alias_name="$1"
            else
                command_parts+=("$1")
            fi
            shift
            ;;
    esac
done

if [ -z "$alias_name" ] || [ ${#command_parts[@]} -eq 0 ]; then
    print_usage
    exit 1
fi

command_to_run="${command_parts[*]}"
escaped_command_for_definition="${command_to_run//\'/\'\\\'\'}"

target_config_file=""
target_shell_type=""
alias_definition_for_file=""
alias_definition_for_current_shell_activation=""

detected_target_shell=""
if [ -n "$SHELL" ]; then
    detected_target_shell=$(basename "$SHELL")
else
    if [ -n "$BASH_VERSION" ]; then
        detected_target_shell="bash"
    elif [ -n "$ZSH_VERSION" ]; then
        detected_target_shell="zsh"
    else
        detected_target_shell="bash"
        echo "Warning: \$SHELL not set. Assuming target shell is Bash." >&2
    fi
fi

case "$detected_target_shell" in
    bash)
        target_shell_type="bash"
        target_config_file="$HOME/.bashrc"
        alias_definition_for_file="alias ${alias_name}='${escaped_command_for_definition}'"
        alias_definition_for_current_shell_activation="alias ${alias_name}='${escaped_command_for_definition}'"
        ;;
    zsh)
        target_shell_type="zsh"
        target_config_file="$HOME/.zshrc"
        alias_definition_for_file="alias ${alias_name}='${escaped_command_for_definition}'"
        alias_definition_for_current_shell_activation="alias ${alias_name}='${escaped_command_for_definition}'"
        ;;
    fish)
        target_shell_type="fish"
        target_config_file="$HOME/.config/fish/config.fish"
        if [ "$temporary_alias" -eq 0 ]; then
            mkdir -p "$(dirname "$target_config_file")"
        fi
        alias_definition_for_file="alias ${alias_name} '${escaped_command_for_definition}'"
        alias_definition_for_current_shell_activation="alias ${alias_name} '${escaped_command_for_definition}'"
        ;;
    *)
        echo "Error: Unsupported target shell '$detected_target_shell'." >&2
        exit 1
        ;;
esac

if [ "$temporary_alias" -eq 1 ]; then
    echo "Info: Creating temporary alias for '$target_shell_type' shell syntax." >&2
else
    echo "Info: Target shell for permanent config: '$target_shell_type'. Config file: '$target_config_file'." >&2
    operation="added"
    config_changed=0

    if [ ! -f "$target_config_file" ] && [ "$target_shell_type" = "fish" ]; then
        touch "$target_config_file"
        echo "Info: Created empty $target_config_file" >&2
    fi

    if [ -f "$target_config_file" ]; then
        if grep -Fxq -- "$alias_definition_for_file" "$target_config_file"; then
            echo "Info: Alias '$alias_name' already exists and is identical in $target_config_file." >&2
        elif ( ([ "$target_shell_type" = "bash" ] || [ "$target_shell_type" = "zsh" ]) && grep -qE "^alias ${alias_name}=" "$target_config_file" ) || \
             ( [ "$target_shell_type" = "fish" ] && grep -qE "^alias ${alias_name} " "$target_config_file" ); then
            echo "Warning: Alias '$alias_name' already exists with a DIFFERENT definition in $target_config_file." >&2
            confirm="n"
            if [ -t 0 ]; then
                read -r -p "Overwrite existing alias for '$alias_name' in $target_config_file? (y/N) " confirm_input < /dev/tty
                confirm="$confirm_input"
            else
                echo "Info: Non-interactive session. Assuming 'No' for overwrite." >&2
            fi

            if [[ "$confirm" =~ ^[Yy]$ ]]; then
                temp_file=$(mktemp)
                if [ "$target_shell_type" = "fish" ]; then
                    grep -vE "^alias ${alias_name} " "$target_config_file" > "$temp_file" && mv "$temp_file" "$target_config_file"
                else
                    grep -vE "^alias ${alias_name}=" "$target_config_file" > "$temp_file" && mv "$temp_file" "$target_config_file"
                fi
                rm -f "$temp_file"
                echo "" >> "$target_config_file"
                echo "# Alias for '$alias_name' updated by $(basename "$0") on $(date)" >> "$target_config_file"
                echo "$alias_definition_for_file" >> "$target_config_file"
                echo "Info: Alias '$alias_name' updated in $target_config_file." >&2
                operation="updated"
                config_changed=1
            else
                echo "Info: Alias '$alias_name' not overwritten." >&2
            fi
        else
            echo "" >> "$target_config_file"
            echo "# Alias for '$alias_name' added by $(basename "$0") on $(date)" >> "$target_config_file"
            echo "$alias_definition_for_file" >> "$target_config_file"
            echo "Info: Alias '$alias_name' added to $target_config_file." >&2
            operation="added"
            config_changed=1
        fi
    else
        echo "# Alias for '$alias_name' added by $(basename "$0") on $(date)" >> "$target_config_file"
        echo "$alias_definition_for_file" >> "$target_config_file"
        echo "Info: Alias '$alias_name' added to new file $target_config_file." >&2
        operation="added"
        config_changed=1
    fi

    if [ "$config_changed" -eq 1 ]; then
        echo "Info: Source $target_config_file or open new terminal for permanent changes." >&2
    fi
fi

echo "${alias_definition_for_current_shell_activation}"

echo "" >&2
echo "---" >&2
if [ "$temporary_alias" -eq 1 ]; then
    echo "To activate TEMPORARY alias '$alias_name' in your CURRENT terminal:" >&2
else
    echo "To activate PERMANENT alias '$alias_name' in CURRENT terminal (also saved to config):" >&2
fi

current_interactive_shell="$detected_target_shell"
if [ -n "$BASH_VERSION" ]; then
    current_interactive_shell="bash"
elif [ -n "$ZSH_VERSION" ]; then
    current_interactive_shell="zsh"
fi

if [[ "$current_interactive_shell" == "bash" || "$current_interactive_shell" == "zsh" ]]; then
    echo "Run: eval \"\$($(basename "$0") $(if [ $temporary_alias -eq 1 ]; then echo -n "-t "; fi)${alias_name} ${command_to_run})\"" >&2
elif [[ "$target_shell_type" == "fish" ]]; then
    echo "In Fish, run: $(basename "$0") $(if [ $temporary_alias -eq 1 ]; then echo -n "-t "; fi)${alias_name} ${command_to_run} | source" >&2
else
    echo "Copy-paste the alias command printed above this '---' line into a $target_shell_type terminal." >&2
fi
