# Git Repository Walkthrough Utility

A shell script that allows you to interactively navigate through git commits and view diffs between commits.

## Features

- **Interactive Navigation**: Navigate through commits using arrow keys
- **Diff Viewing**: View changes between commits as uncommitted files in VS Code
- **State Preservation**: Automatically restores your original git state when exiting
- **Visual Feedback**: Color-coded output for better user experience

## Usage

1. Navigate to a directory containing a git repository
2. Run the script:
   ```bash
   ./git-walkthrough.sh
   ```

## Controls

- **→ (Right Arrow)**: Move to the next commit (or show diff if diff mode is on)
- **← (Left Arrow)**: Move to the previous commit (or show diff if diff mode is on)
- **d**: Toggle diff mode on/off
- **q**: Quit and restore original state

## How It Works

1. The script saves your current git state (branch and commit)
2. It checks out the first commit in the repository history
3. You can navigate through commits using arrow keys
4. Press 'd' to toggle diff mode on/off
5. When diff mode is ON, arrow keys show diffs between commits as uncommitted changes
6. When diff mode is OFF, arrow keys navigate between commits normally
7. The diff is shown as uncommitted changes that you can view in VS Code
8. When you quit, your original state is automatically restored

## Requirements

- Bash shell
- Git repository
- VS Code (for viewing diffs)

## Safety Features

- Automatically restores original git state on exit
- Prevents navigation beyond available commits
- Validates that you're in a git repository before starting
