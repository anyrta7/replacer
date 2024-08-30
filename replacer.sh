#!/bin/bash
cat << "EOF"
                                                         
,------.               ,--.                             
|  .--. ' ,---.  ,---. |  | ,--,--. ,---. ,---. ,--.--. 
|  '--'.'| .-. :| .-. ||  |' ,-.  || .--'| .-. :|  .--' 
|  |\  \ \   --.| '-' '|  |\ '-'  |\ `--.\   --.|  |    
`--' '--' `----'|  |-' `--' `--`--' `---' `----'`--'    
                `--'                                    
EOF

# Global variables
LOG_FILE="replacer.log"
BACKUP_SUFFIX=".bak"

# Display usage and help information
show_help() {
    echo "Usage: ./replacer.sh <input_file(s)> [options]"
    echo "Options:"
    echo "  -h,  --help                    Display this help message."
    echo "  --update                       Update the script to the latest version from GitHub."
    echo "  --version                      Display script version."
    echo "  -af, --add-first   <text>      Add text at the beginning of each line."
    echo "  -ae, --add-end     <text>      Add text at the end of each line."
    echo "  -s,  --select      <text>      Select text to search in each line."
    echo "  -r,  --replace     <text>      Replace selected text. If empty, remove selected text."
    echo "  -o,  --output      <file>      Specify output file."
    echo "  --regex                        Use regex for text selection and replacement."
    echo "  --ignore-case                  Case-insensitive search and replace."
    echo "  --multiline                    Enable multiline regex processing."
    echo "  --backup                       Create a backup of the original file."
    echo "  --log                          Enable logging to replacer.log."
    echo "  --interactive                  Enable interactive mode."
    echo "  --dry-run                      Show what would be done without making changes."
    echo
    echo "Examples:"
    echo "  ./replacer.sh input.txt -af 'https://' -ae '/path' --output output.txt"
    echo "  ./replacer.sh input1.txt input2.txt -s 'old_text' -r 'new_text' --backup --log"
    echo "  cat input.txt | ./replacer.sh -s 'foo' -r ''"
}

# Display version information
show_version() {
    echo "Replacer version 1.0.0"
}

# Update the script from GitHub
update_script() {
    echo "Updating script from GitHub..."
    if command -v git &> /dev/null && [ -d .git ]; then
        git pull origin master
    elif command -v curl &> /dev/null; then
        curl -O https://github.com/anyrta7/replacer/raw/main/replacer.sh
        chmod +x replacer.sh
        echo "Script updated successfully."
    elif command -v wget &> /dev/null; then
        wget https://github.com/anyrta7/replacer/raw/main/replacer.sh
        chmod +x replacer.sh
        echo "Script updated successfully."
    else
        echo "Error: git, curl, or wget is required to update the script."
        exit 1
    fi
    exit 0
}

# Log messages to a file
log_message() {
    if [[ "$logging_enabled" == true ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $1" >> "$LOG_FILE"
    fi
}

# Perform a dry run to show changes without applying them
perform_dry_run() {
    echo "Dry Run Mode: Previewing changes..."
    echo "$output"
}

# Handle interactive mode for user confirmation
confirm_action() {
    if [[ "$interactive_mode" == true ]]; then
        read -p "Proceed with this action? (y/n): " choice
        case "$choice" in
            y|Y ) return 0 ;;
            * ) echo "Action cancelled by user." ; exit 1 ;;
        esac
    fi
    return 0
}

# Backup the original file
create_backup() {
    if [[ "$create_backup" == true ]]; then
        cp "$1" "$1$BACKUP_SUFFIX"
        log_message "Backup created for $1 as $1$BACKUP_SUFFIX"
    fi
}

# Validate and process input files
process_files() {
    for input_file in "${input_files[@]}"; do
        if [[ ! -f "$input_file" ]]; then
            echo "Error: File $input_file does not exist."
            exit 1
        fi

        local input=$(cat "$input_file")
        local output="$input"

        # Create a backup if needed
        create_backup "$input_file"

        # Add first text if provided
        if [[ -n "$add_first" ]]; then
            output=$(echo "$output" | sed "s/^/$add_first/")
            log_message "Added '$add_first' to the beginning of each line in $input_file"
        fi

        # Add end text if provided
        if [[ -n "$add_end" ]]; then
            output=$(echo "$output" | sed "s/$/$add_end/")
            log_message "Added '$add_end' to the end of each line in $input_file"
        fi

        # Replace or remove text
        if [[ -n "$select_text" ]]; then
            replace_text="${replace_text:-}"  # Default to empty if not provided
            sed_options="s/$select_text/$replace_text/g"

            # Configure sed options based on regex, ignore case, and multiline
            [[ "$use_regex" == true ]] && sed_options="-E $sed_options"
            [[ "$ignore_case" == true ]] && sed_options="I $sed_options"
            [[ "$multiline" == true ]] && sed_options="M $sed_options"

            output=$(echo "$output" | sed $sed_options)
            log_message "Replaced '$select_text' with '$replace_text' in $input_file"
        fi

        # Confirm action in interactive mode
        confirm_action

        # Perform dry run or apply changes
        if [[ "$dry_run" == true ]]; then
            perform_dry_run
        else
            # Output to the specified file or overwrite the original
            if [[ -n "$output_file" ]]; then
                echo "$output" > "$output_file"
                echo "Output written to $output_file."
                log_message "Output written to $output_file for $input_file"
            else
                echo "$output" > "$input_file"
                echo "Modified $input_file."
                log_message "Modified $input_file"
            fi
        fi
    done
}

# Validate if the input file(s) are provided
if [[ $# -eq 0 ]]; then
    echo "Error: No input files provided."
    show_help
    exit 1
fi

# Parse options and files
input_files=()
while [[ $# -gt 0 ]]; do
    case "$1" in
        -af|--add-first)
            add_first="$2"
            shift 2
            ;;
        -ae|--add-end)
            add_end="$2"
            shift 2
            ;;
        -s|--select)
            select_text="$2"
            shift 2
            ;;
        -r|--replace)
            replace_text="$2"
            shift 2
            ;;
        -o|--output)
            output_file="$2"
            shift 2
            ;;
        --regex)
            use_regex=true
            shift
            ;;
        --ignore-case)
            ignore_case=true
            shift
            ;;
        --multiline)
            multiline=true
            shift
            ;;
        --backup)
            create_backup=true
            shift
            ;;
        --log)
            logging_enabled=true
            shift
            ;;
        --interactive)
            interactive_mode=true
            shift
            ;;
        --dry-run)
            dry_run=true
            shift
            ;;
        -h|--help)
            show_help
            exit 0
            ;;
        --version)
            show_version
            exit 0
            ;;
        --update)
            update_script
            ;;
        -*)
            echo "Error: Unknown option: $1"
            show_help
            exit 1
            ;;
        *)
            input_files+=("$1")
            shift
            ;;
    esac
done

# Process the input files
process_files
