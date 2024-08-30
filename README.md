# Replacer Script

![logo](images/logo.png)

## Overview

The Replacer Script is a versatile tool for modifying text in files or from standard input (stdin). It supports various operations such as adding text, replacing or removing text, batch processing, backup creation, logging, interactive mode, and more.

## Installation

1. **Download the Script:**
   Use one of the following commands to download the script:
    ```bash
    wget https://github.com/anyrta7/replacer/raw/master/replacer.sh
    ```
    or
    ```bash
    curl -O https://github.com/anyrta7/replacer/raw/master/replacer.sh
    ```
2. **Make the Script Executable:**
    Grant execute permissions to the script with the following command:
    ```bash
    chmod +x replacer.sh
    ```


## Usage

To use the script, run it with the input file(s) and desired options. The script will process text based on the provided options.
```bash
./replacer.sh <input_file(s)> [options]
```

### Options:

- `-af, --add-first <text>`: Add the specified text at the beginning of each line.
- `-ae, --add-end <text>`: Add the specified text at the end of each line.
- `-s, --select <text>`: Specify text to search for in each line.
- `-r, --replace <text>`: Replace the selected text with the specified text. If this option is empty, the selected text will be removed.
- `--output <file>`: Define the output file where the results will be written. If not specified, the script will overwrite the original input file(s).
- `--regex`: Use regular expressions for text selection and replacement.
- `--ignore-case`: Perform case-insensitive search and replace.
- `--multiline`: Enable multiline regular expression processing.
- `--backup`: Create a backup of the original file(s) before applying changes.
- `--log`: Enable logging of operations to `replacer.log`.
- `--interactive`: Enable interactive mode, which prompts for user confirmation before making changes.
- `--dry-run`: Show what changes would be made without applying them.
- `--version`: Display the version of the script.
- `--update`: Update the script to the latest version from GitHub.
- `-h, --help`: Display help information and usage instructions.

### Examples:

1. **Add Text to the Beginning and End of Each Line:**
    ```bash
    ./replacer.sh input.txt -af 'https://' -ae '/path' --output output.txt
    ```

2. **Replace Text in Multiple Files with Backup and Logging:**
    ```bash
    ./replacer.sh input1.txt input2.txt -s 'old_text' -r 'new_text' --backup --log
    ```
3. **Use the Script with stdin and Remove Text:**
    ```bash
    cat input.txt | ./replacer.sh -s 'foo' -r ''
    ```
4. **Perform a Dry Run to Preview Changes:**
    ```bash
    ./replacer.sh input.txt -s 'old_text' -r 'new_text' --dry-run
    ```
5. **Update the Script to the Latest Version:**
    ```bash
    ./replacer.sh --update
    ```

## Notes

- If no `--output` option is provided, the script will overwrite the original input files.
- The `--update` option will pull the latest version of the script from GitHub. Ensure that `git`, `curl`, or `wget` is available for updating the script.
- Use the `--interactive` option to confirm changes before they are applied, preventing accidental modifications.

For additional help or information, refer to the help message using `-h` or `--help`.

