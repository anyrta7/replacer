#!/bin/bash
cat << "EOF"
                                                         
,------.               ,--.                             
|  .--. ' ,---.  ,---. |  | ,--,--. ,---. ,---. ,--.--. 
|  '--'.'| .-. :| .-. ||  |' ,-.  || .--'| .-. :|  .--' 
|  |\  \ \   --.| '-' '|  |\ '-'  |\ `--.\   --.|  |    
`--' '--' `----'|  |-' `--' `--`--' `---' `----'`--'    
                `--'                                    
EOF

# Global Variables
VERSION="1.1.0"
BACKUP_SUFFIX=".bak"
LOG_FILE="replacer.log"
add_first=""
add_end=""
select_text=""
replace_text=""
output_file=""
use_regex=false
create_backup=false
logging_enabled=false
interactive_mode=false
dry_run=false
verbose=false

# Display help message
show_help() {
    cat << EOF
Usage: ./replacer.sh <input_file(s)> [options]
Options:
  -af, --add-first   <text>          Add text at the beginning of each line.
  -ae, --add-end     <text>          Add text at the end of each line.
  -s,  --select      <text>          Select text to search in each line.
  -r,  --replace     <text>          Replace selected text. If empty, remove selected text.
  -o,  --output      <file>          Specify output file. If not specified, overwrite input file.
  -g,  --regex       Use regex for text selection and replacement.
  -b,  --backup      Create a backup of the original file.
  -l,  --log         Enable logging to $LOG_FILE.
  -x,  --interactive Enable interactive mode.
  -n,  --dry-run     Show what would be done without making changes.
  -v,  --verbose     Enable verbose output.
  -V,  --version     Display script version.
  -u,  --update      Update the script to the latest version from GitHub.
  -h,  --help        Display this help message.
Examples:
  ./replacer.sh input.txt -af 'https://' -ae '/path' -o output.txt
  ./replacer.sh input1.txt input2.txt -s 'old_text' -r 'new_text'
  cat input.txt | ./replacer.sh -s 'foo' -r ''
  ./replacer.sh -u
EOF
}

# Display script version
show_version() {
    echo "Replacer version $VERSION"
}

# Update the script from GitHub
update_script() {
    echo "Updating script from GitHub..."
    if command -v git &> /dev/null && [ -d .git ]; then
        echo "Updating script via git..."
        git pull origin master
    elif command -v curl &> /dev/null; then
        echo "Updating script via curl..."
        curl -O https://github.com/anyrta7/replacer/raw/main/replacer.sh
        chmod +x replacer.sh
        echo "Script updated successfully."
    elif command -v wget &> /dev/null; then
        echo "Updating script via wget..."
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
    local message="$1"
    if [[ "$logging_enabled" == true ]]; then
        echo "$(date '+%Y-%m-%d %H:%M:%S') - $message" >> "$LOG_FILE"
        [ "$verbose" == true ] && echo "Logged message: $message"
    fi
}

# Create a backup of the original file
create_backup() {
    local file="$1"
    if [[ "$create_backup" == true ]]; then
        cp "$file" "$file$BACKUP_SUFFIX"
        log_message "Backup created for $file as $file$BACKUP_SUFFIX"
        [ "$verbose" == true ] && echo "Backup created for $file as $file$BACKUP_SUFFIX"
    fi
}

# Apply text modifications
apply_modifications() {
    local content="$1"

    [ "$verbose" == true ] && echo "Applying modifications..."

    # Add first text if provided
    if [[ -n "$add_first" ]]; then
        content=$(echo "$content" | awk -v prefix="$add_first" '{print prefix $0}')
        log_message "Added '$add_first' to the beginning of each line."
        [ "$verbose" == true ] && echo "Added '$add_first' to the beginning of each line."
    fi

    # Add end text if provided
    if [[ -n "$add_end" ]]; then
        content=$(echo "$content" | awk -v suffix="$add_end" '{print $0 suffix}')
        log_message "Added '$add_end' to the end of each line."
        [ "$verbose" == true ] && echo "Added '$add_end' to the end of each line."
    fi

    # Replace or remove text
    if [[ -n "$select_text" ]]; then
        local awk_command
        if [[ "$use_regex" == true ]]; then
            awk_command='{gsub(/'"$select_text"'/, "'"$replace_text"'")} {print}'
        else
            awk_command='{gsub("'"$select_text"'", "'"$replace_text"'")} {print}'
        fi
        content=$(echo "$content" | awk "$awk_command")
        log_message "Replaced '$select_text' with '$replace_text'."
        [ "$verbose" == true ] && echo "Replaced '$select_text' with '$replace_text'."
    fi

    echo "$content"
}

# Show progress for large files
show_progress() {
    local file="$1"
    local total_lines=$(wc -l < "$file")
    local processed_lines=0

    while read -r line; do
        processed_lines=$((processed_lines + 1))
        local progress=$((processed_lines * 100 / total_lines))
        echo -ne "Processing: $progress% complete\r"
    done < "$file"
    echo -ne '\n'
}

# Process a single file
process_file() {
    local input_file="$1"

    [ "$verbose" == true ] && echo "Processing file: $input_file"

    if [[ ! -f "$input_file" ]]; then
        echo "Error: File $input_file does not exist."
        exit 1
    fi

    # Show progress for large files
    local line_count=$(wc -l < "$input_file")
    if [[ "$line_count" -gt 1000 ]]; then
        show_progress "$input_file"
    fi

    local input=$(cat "$input_file")
    [ "$verbose" == true ] && echo "Read input from $input_file."

    local output=$(apply_modifications "$input")

    # Create a backup if needed
    create_backup "$input_file"

    # Confirm action in interactive mode
    if [[ "$interactive_mode" == true ]]; then
        echo "Modifications:"
        echo "$output"
        read -p "Proceed with this action? (y/n): " choice
        case "$choice" in
            y|Y ) ;;
            * ) echo "Action cancelled by user." ; exit 1 ;;
        esac
    fi

    # Perform dry run or apply changes
    if [[ "$dry_run" == true ]]; then
        echo "Dry Run Mode: Previewing changes..."
        echo "$output"
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
}

# Process input files
process_files() {
    local files=("${!1}")

    [ "$verbose" == true ] && echo "Processing ${#files[@]} files."

    for input_file in "${files[@]}"; do
        [ "$verbose" == true ] && echo "Starting processing for file: $input_file"
        process_file "$input_file"
        [ "$verbose" == true ] && echo "Completed processing for file: $input_file"
    done
}

# Parse options and files
parse_options() {
    local files=()

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
            -g|--regex)
                use_regex=true
                shift
                ;;
            -b|--backup)
                create_backup=true
                shift
                ;;
            -l|--log)
                logging_enabled=true
                shift
                ;;
            -x|--interactive)
                interactive_mode=true
                shift
                ;;
            -n|--dry-run)
                dry_run=true
                shift
                ;;
            -v|--verbose)
                verbose=true
                shift
                ;;
            -V|--version)
                show_version
                exit 0
                ;;
            -u|--update)
                update_script
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -*)
                echo "Error: Unknown option: $1"
                show_help
                exit 1
                ;;
            *)
                files+=("$1")
                shift
                ;;
        esac
    done

    if [[ ${#files[@]} -eq 0 ]]; then
        echo "Error: No input files provided."
        show_help
        exit 1
    fi

    # Process files
    process_files files[@]
}

# Main execution
parse_options "$@"
