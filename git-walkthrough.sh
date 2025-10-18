#!/bin/bash

# Git Repository Walkthrough Utility
# Navigate through git commits interactively and view diffs

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Global variables
CURRENT_COMMIT=""
COMMIT_LIST=()
CURRENT_INDEX=0
ORIGINAL_BRANCH=""
ORIGINAL_COMMIT=""
DIFF_MODE=false

# Function to print colored output
print_colored() {
    local color=$1
    local message=$2
    echo -e "${color}${message}${NC}"
}

# Function to check if we're in a git repository
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        print_colored $RED "Error: Not in a git repository"
        exit 1
    fi
}

# Function to get all commits in chronological order
get_commit_list() {
    COMMIT_LIST=($(git rev-list --reverse --all))
    if [ ${#COMMIT_LIST[@]} -eq 0 ]; then
        print_colored $RED "Error: No commits found in repository"
        exit 1
    fi
}

# Function to save current state
save_current_state() {
    ORIGINAL_BRANCH=$(git branch --show-current)
    ORIGINAL_COMMIT=$(git rev-parse HEAD)
    print_colored $GREEN "Saved current state: branch '$ORIGINAL_BRANCH', commit '$ORIGINAL_COMMIT'"
}

# Function to restore original state
restore_original_state() {
    if [ -n "$ORIGINAL_BRANCH" ]; then
        print_colored $YELLOW "Restoring original state..."
        git reset --hard > /dev/null 2>&1
        git checkout "$ORIGINAL_BRANCH" > /dev/null 2>&1
        print_colored $GREEN "Restored to branch '$ORIGINAL_BRANCH'"
        ORIGINAL_BRANCH=""  # Prevent double restore
    fi
}

# Function to checkout a specific commit
checkout_commit() {
    local commit=$1
    git checkout "$commit" > /dev/null 2>&1
    CURRENT_COMMIT=$commit
    print_colored $GREEN "Checked out commit: $(git log --oneline -1 "$commit")"
}

# Function to show diff between current and next commit
show_diff() {
    if [ $CURRENT_INDEX -lt $((${#COMMIT_LIST[@]} - 1)) ]; then
        local current_commit=${COMMIT_LIST[$CURRENT_INDEX]}
        local next_commit=${COMMIT_LIST[$((CURRENT_INDEX + 1))]}
        
        # Checkout the current commit first (in case we're in a temp branch)
        git checkout "$current_commit" > /dev/null 2>&1
        
        # Get the files changed between commits
        git diff --name-only "$current_commit" "$next_commit" > /dev/null 2>&1
        
        # Apply the diff as uncommitted changes
        git checkout "$current_commit" > /dev/null 2>&1
        git diff "$current_commit" "$next_commit" | git apply --cached 2>&1 | grep -v "warning:" || true
        git diff "$current_commit" "$next_commit" | git apply 2>&1 | grep -v "warning:" || true
        
        CURRENT_COMMIT=$current_commit
        
    else
        print_colored $RED "No next commit available"
    fi
}

# Function to toggle diff mode
toggle_diff_mode() {
    if [ "$DIFF_MODE" = true ]; then
        DIFF_MODE=false
        # Clean up any uncommitted changes when turning off diff mode
        git reset --hard > /dev/null 2>&1
        print_colored $YELLOW "Diff mode OFF - Navigation will show commits normally"
    else
        DIFF_MODE=true
        print_colored $GREEN "Diff mode ON - Navigation will show diffs between commits"
        # Show the diff immediately when turning on diff mode
        show_diff
    fi
}

# Function to display current status
show_status() {
    clear
    print_colored $BLUE "=== Git Repository Walkthrough ==="
    echo
    print_colored $GREEN "Current commit: $(git log --oneline -1)"
    print_colored $YELLOW "Position: $((CURRENT_INDEX + 1)) of ${#COMMIT_LIST[@]}"
    if [ "$DIFF_MODE" = true ]; then
        print_colored $GREEN "Diff mode: ON"
    else
        print_colored $YELLOW "Diff mode: OFF"
    fi
    echo
    print_colored $BLUE "Navigation:"
    echo "  → (right arrow) - Next commit"
    echo "  ← (left arrow)  - Previous commit"
    echo "  d               - Toggle diff mode"
    echo "  q               - Quit and restore original state"
    echo
}

# Function to handle keyboard input
handle_input() {
    while true; do
        read -rsn1 key
        
        case $key in
            $'\x1b')  # ESC sequence
                read -rsn2 key
                case $key in
                    '[C')  # Right arrow
                        if [ $CURRENT_INDEX -lt $((${#COMMIT_LIST[@]} - 1)) ]; then
                            CURRENT_INDEX=$((CURRENT_INDEX + 1))
                            if [ "$DIFF_MODE" = true ]; then
                                show_diff
                            else
                                checkout_commit "${COMMIT_LIST[$CURRENT_INDEX]}"
                            fi
                            show_status
                        else
                            print_colored $RED "Already at the last commit"
                        fi
                        ;;
                    '[D')  # Left arrow
                        if [ $CURRENT_INDEX -gt 0 ]; then
                            CURRENT_INDEX=$((CURRENT_INDEX - 1))
                            if [ "$DIFF_MODE" = true ]; then
                                show_diff
                            else
                                checkout_commit "${COMMIT_LIST[$CURRENT_INDEX]}"
                            fi
                            show_status
                        else
                            print_colored $RED "Already at the first commit"
                        fi
                        ;;
                esac
                ;;
            'd')
                toggle_diff_mode
                show_status
                ;;
            'q')
                print_colored $YELLOW "Quitting..."
                restore_original_state
                exit 0
                ;;
        esac
    done
}

# Main function
main() {
    print_colored $BLUE "Git Repository Walkthrough Utility"
    echo
    
    # Check if we're in a git repository
    check_git_repo
    
    # Get commit list
    get_commit_list
    
    # Save current state
    save_current_state
    
    # Start from the first commit
    CURRENT_INDEX=0
    checkout_commit "${COMMIT_LIST[0]}"
    
    # Show initial status
    show_status
    
    # Handle user input
    handle_input
}

# Trap to ensure we restore state on exit
trap 'restore_original_state' EXIT

# Run main function
main "$@"
