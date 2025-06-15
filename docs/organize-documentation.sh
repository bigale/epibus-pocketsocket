#!/bin/bash

# AI-Kit Industrial IoT - Documentation Organization Script
# Creates symlink-based hierarchical folder views for documentation
# Based on: Time Buckets, SDLC Lifecycle, System Functionality

set -e

PROJECT_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
DOCS_ROOT="${PROJECT_ROOT}"
WORKSPACE_ROOT="${PROJECT_ROOT}/.."

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
PURPLE='\033[0;35m'
CYAN='\033[0;36m'
NC='\033[0m'

echo -e "${PURPLE}🗂️  AI-Kit Documentation Organization Script${NC}"
echo -e "${PURPLE}=============================================${NC}"

# Create base organization directories
create_base_structure() {
    echo -e "${BLUE}📁 Creating base directory structure...${NC}"
    
    # Time-based organization
    mkdir -p "$DOCS_ROOT/by-time/2025-06-15-today"
    mkdir -p "$DOCS_ROOT/by-time/2025-06-14-yesterday" 
    mkdir -p "$DOCS_ROOT/by-time/week-prior"
    mkdir -p "$DOCS_ROOT/by-time/historical"
    
    # SDLC Lifecycle organization
    mkdir -p "$DOCS_ROOT/by-lifecycle/planning"
    mkdir -p "$DOCS_ROOT/by-lifecycle/implementation"
    mkdir -p "$DOCS_ROOT/by-lifecycle/testing"
    mkdir -p "$DOCS_ROOT/by-lifecycle/debugging"
    mkdir -p "$DOCS_ROOT/by-lifecycle/enhancement"
    mkdir -p "$DOCS_ROOT/by-lifecycle/documentation"
    mkdir -p "$DOCS_ROOT/by-lifecycle/architecture"
    mkdir -p "$DOCS_ROOT/by-lifecycle/completion"
    
    # System Functionality organization
    mkdir -p "$DOCS_ROOT/by-system/admin-tools"
    mkdir -p "$DOCS_ROOT/by-system/node-red"
    mkdir -p "$DOCS_ROOT/by-system/browser-ui"
    mkdir -p "$DOCS_ROOT/by-system/window-management"
    mkdir -p "$DOCS_ROOT/by-system/integration"
    mkdir -p "$DOCS_ROOT/by-system/character-simulation"
    mkdir -p "$DOCS_ROOT/by-system/content-management"
    mkdir -p "$DOCS_ROOT/by-system/diagnostics"
    mkdir -p "$DOCS_ROOT/by-system/success-reports"
    
    echo -e "${GREEN}✅ Base structure created${NC}"
}

# Analyze file and determine time bucket
get_time_bucket() {
    local file_path="$1"
    local mod_date=$(stat -c "%Y" "$file_path" 2>/dev/null || echo "0")
    local today=$(date +%s)
    local yesterday=$((today - 86400))
    local week_ago=$((today - 604800))
    
    if [ "$mod_date" -gt "$yesterday" ]; then
        echo "2025-06-15-today"
    elif [ "$mod_date" -gt "$((yesterday - 86400))" ]; then
        echo "2025-06-14-yesterday"
    elif [ "$mod_date" -gt "$week_ago" ]; then
        echo "week-prior"
    else
        echo "historical"
    fi
}

# Analyze filename and content to determine SDLC phase
get_sdlc_phase() {
    local filename="$(basename "$1")"
    local filepath="$1"
    
    # Planning phase patterns
    if [[ "$filename" =~ (PLAN|ARCHITECTURE|DESIGN) ]]; then
        echo "planning"
        return
    fi
    
    # Architecture patterns
    if [[ "$filename" =~ (ARCHITECTURE|VIRTUAL-DESKTOP) ]]; then
        echo "architecture"
        return
    fi
    
    # Implementation patterns
    if [[ "$filename" =~ (IMPLEMENT|COMPLETE|INTEGRATION|SIMULATOR) ]]; then
        echo "implementation"
        return
    fi
    
    # Testing patterns  
    if [[ "$filename" =~ (TEST|VALIDATION) ]]; then
        echo "testing"
        return
    fi
    
    # Debugging patterns
    if [[ "$filename" =~ (DEBUG|FIX|FIXED|ERROR|RESOLVED) ]]; then
        echo "debugging"
        return
    fi
    
    # Enhancement patterns
    if [[ "$filename" =~ (ENHANCEMENT|IMPROVED|ENHANCED|UX) ]]; then
        echo "enhancement"
        return
    fi
    
    # Completion/Success patterns
    if [[ "$filename" =~ (SUCCESS|FINAL|SUMMARY|REPORT) ]]; then
        echo "completion"
        return
    fi
    
    # Documentation patterns
    if [[ "$filename" =~ (README|GUIDE|DOC) ]]; then
        echo "documentation"
        return
    fi
    
    # Default to implementation
    echo "implementation"
}

# Analyze filename and content to determine system functionality
get_system_function() {
    local filename="$(basename "$1")"
    local filepath="$1"
    
    # Admin tools patterns
    if [[ "$filename" =~ (ADMIN|UNIFIED|BACKGROUND-PROCESS) ]]; then
        echo "admin-tools"
        return
    fi
    
    # Node-RED patterns
    if [[ "$filename" =~ (NODE-RED|BUTTON|EDITOR|DASHBOARD-PATH|FLOW) ]]; then
        echo "node-red"
        return
    fi
    
    # Browser/UI patterns
    if [[ "$filename" =~ (BROWSER|POPUP|VISIBILITY|JAVASCRIPT|TAB) ]]; then
        echo "browser-ui"
        return
    fi
    
    # Window management patterns
    if [[ "$filename" =~ (WINDOW|VIRTUAL-DESKTOP|CONNECTIVITY) ]]; then
        echo "window-management"
        return
    fi
    
    # Character simulation patterns
    if [[ "$filename" =~ (CHARACTER|SIMULATOR|KYOKO|BYAKUYA|CHIHIRO|CELESTIA|SAKURA) ]]; then
        echo "character-simulation"
        return
    fi
    
    # Content management patterns
    if [[ "$filename" =~ (CONTENT|COLLECTIONS) ]]; then
        echo "content-management"
        return
    fi
    
    # Integration patterns
    if [[ "$filename" =~ (INTEGRATION|SERVICE-DISCOVERY|COLLABORATIVE) ]]; then
        echo "integration"
        return
    fi
    
    # Success reports patterns
    if [[ "$filename" =~ (SUCCESS|FINAL|PROJECT|REPORT|SUMMARY) ]]; then
        echo "success-reports"
        return
    fi
    
    # Diagnostics patterns
    if [[ "$filename" =~ (DEBUG|PORT-STATUS|ANALYSIS|COMPARISON) ]]; then
        echo "diagnostics"
        return
    fi
    
    # Default to integration
    echo "integration"
}

# Create symlink with error handling
create_symlink() {
    local source_file="$1"
    local target_dir="$2"
    local link_name="$(basename "$source_file")"
    local target_link="$target_dir/$link_name"
    
    # Remove existing symlink if it exists
    [ -L "$target_link" ] && rm "$target_link"
    
    # Create symlink with relative path
    local rel_path=$(realpath --relative-to="$target_dir" "$source_file")
    ln -sf "$rel_path" "$target_link"
    
    echo -e "  ${CYAN}→${NC} $(basename "$target_dir")/${GREEN}$(basename "$source_file")${NC}"
}

# Process a single markdown file
process_markdown_file() {
    local file_path="$1"
    local filename="$(basename "$file_path")"
    
    echo -e "${YELLOW}📄 Processing: $filename${NC}"
    
    # Skip if file doesn't exist or is not a regular file
    [ ! -f "$file_path" ] && return
    
    # Get classifications
    local time_bucket=$(get_time_bucket "$file_path")
    local sdlc_phase=$(get_sdlc_phase "$file_path")
    local system_function=$(get_system_function "$file_path")
    
    # Create symlinks in each organizational structure
    create_symlink "$file_path" "$DOCS_ROOT/by-time/$time_bucket"
    create_symlink "$file_path" "$DOCS_ROOT/by-lifecycle/$sdlc_phase"
    create_symlink "$file_path" "$DOCS_ROOT/by-system/$system_function"
}

# Clean existing symlinks
clean_symlinks() {
    echo -e "${YELLOW}🧹 Cleaning existing symlinks...${NC}"
    find "$DOCS_ROOT" -type l -delete 2>/dev/null || true
    echo -e "${GREEN}✅ Cleanup complete${NC}"
}

# Generate file entries with dates, sorted by modification time (newest first)
generate_sorted_file_entries() {
    local dir_path="$1"
    local index_file="$2"
    
    # Create temporary file to store file info with timestamps
    local temp_file=$(mktemp)
    
    # Get files with modification timestamps (including seconds for precise sorting)
    find "$dir_path" -type l -printf '%T@ %f\n' | while IFS=' ' read -r timestamp filename; do
        local source_file=$(readlink -f "$dir_path/$filename")
        local rel_path=$(realpath --relative-to="$DOCS_ROOT" "$source_file")
        local file_date=$(date -d "@$timestamp" '+%Y-%m-%d %H:%M:%S')
        echo "$timestamp|$filename|$rel_path|$file_date" >> "$temp_file"
    done
    
    # Sort by timestamp (newest first) and generate markdown entries
    if [ -s "$temp_file" ]; then
        sort -t'|' -k1,1nr "$temp_file" | while IFS='|' read -r timestamp filename rel_path file_date; do
            echo "- [$filename]($rel_path) *($file_date)*" >> "$index_file"
        done
    fi
    
    # Clean up
    rm -f "$temp_file"
}

# Main processing function
organize_documentation() {
    echo -e "${BLUE}🔍 Scanning for markdown files...${NC}"
    
    # Process root-level markdown files
    while IFS= read -r -d '' file; do
        process_markdown_file "$file"
    done < <(find "$WORKSPACE_ROOT" -maxdepth 1 -name "*.md" -type f -print0)
    
    # Process docs directory markdown files
    while IFS= read -r -d '' file; do
        process_markdown_file "$file"
    done < <(find "$DOCS_ROOT" -maxdepth 1 -name "*.md" -type f -print0)
    
    # Process subdirectory markdown files (excluding node_modules)
    while IFS= read -r -d '' file; do
        # Skip if in node_modules or other excluded directories
        [[ "$file" =~ node_modules ]] && continue
        [[ "$file" =~ \.git ]] && continue
        [[ "$file" =~ by-time|by-lifecycle|by-system ]] && continue
        
        process_markdown_file "$file"
    done < <(find "$WORKSPACE_ROOT" -name "*.md" -type f -not -path "*/node_modules/*" -not -path "*/.git/*" -not -path "*/by-*/*" -print0)
}

# Generate summary report
generate_summary() {
    echo -e "\n${PURPLE}📊 Documentation Organization Summary${NC}"
    echo -e "${PURPLE}====================================${NC}"
    
    echo -e "\n${CYAN}📅 By Time:${NC}"
    for time_dir in "$DOCS_ROOT/by-time"/*; do
        [ -d "$time_dir" ] || continue
        local count=$(find "$time_dir" -type l | wc -l)
        echo -e "  $(basename "$time_dir"): $count files"
    done
    
    echo -e "\n${CYAN}🔄 By SDLC Phase:${NC}"
    for lifecycle_dir in "$DOCS_ROOT/by-lifecycle"/*; do
        [ -d "$lifecycle_dir" ] || continue
        local count=$(find "$lifecycle_dir" -type l | wc -l)
        echo -e "  $(basename "$lifecycle_dir"): $count files"
    done
    
    echo -e "\n${CYAN}⚙️  By System Function:${NC}"
    for system_dir in "$DOCS_ROOT/by-system"/*; do
        [ -d "$system_dir" ] || continue
        local count=$(find "$system_dir" -type l | wc -l)
        echo -e "  $(basename "$system_dir"): $count files"
    done
    
    local total_files=$(find "$DOCS_ROOT/by-time" -type l | wc -l)
    echo -e "\n${GREEN}✅ Total files organized: $total_files${NC}"
}

# Generate comprehensive index file
generate_documentation_index() {
    local index_file="$DOCS_ROOT/index.md"
    local current_date=$(date '+%Y-%m-%d %H:%M:%S')
    
    echo -e "${CYAN}📑 Generating documentation index...${NC}"
    
    cat > "$index_file" << EOF
# 🗂️ AI-Kit Industrial IoT - Documentation Index

> **Generated**: $current_date  
> **Total Files**: $(find "$DOCS_ROOT/by-time" -type l | wc -l)  
> **Auto-maintained by**: \`organize-documentation.sh\`

This comprehensive index provides clickable links to all project documentation organized by three facets: time, SDLC lifecycle, and system functionality.

---

## 📅 Documentation by Time

EOF

    # Generate time-based index
    for time_dir in "$DOCS_ROOT/by-time"/*; do
        [ -d "$time_dir" ] || continue
        local time_bucket=$(basename "$time_dir")
        local file_count=$(find "$time_dir" -type l | wc -l)
        
        # Map time bucket to readable format
        local time_display=""
        case "$time_bucket" in
            "2025-06-15-today") time_display="📅 Today ($(date '+%Y-%m-%d'))" ;;
            "2025-06-14-yesterday") time_display="📅 Yesterday" ;;
            "week-prior") time_display="📅 Past Week" ;;
            "historical") time_display="📅 Historical" ;;
            *) time_display="📅 $time_bucket" ;;
        esac
        
        echo "### $time_display" >> "$index_file"
        echo "*$file_count files*" >> "$index_file"
        echo "" >> "$index_file"
        
        # List files in this time bucket
        if [ "$file_count" -gt 0 ]; then
            generate_sorted_file_entries "$time_dir" "$index_file"
        else
            echo "*No files in this time period*" >> "$index_file"
        fi
        echo "" >> "$index_file"
    done

    # Generate SDLC lifecycle index
    cat >> "$index_file" << EOF

---

## 🔄 Documentation by SDLC Phase

EOF

    for lifecycle_dir in "$DOCS_ROOT/by-lifecycle"/*; do
        [ -d "$lifecycle_dir" ] || continue
        local phase=$(basename "$lifecycle_dir")
        local file_count=$(find "$lifecycle_dir" -type l | wc -l)
        
        # Map phase to readable format with icons
        local phase_display=""
        case "$phase" in
            "planning") phase_display="📋 Planning & Architecture" ;;
            "implementation") phase_display="🔨 Implementation & Development" ;;
            "testing") phase_display="🧪 Testing & Validation" ;;
            "debugging") phase_display="🐛 Debugging & Fixes" ;;
            "enhancement") phase_display="✨ Enhancements & UX" ;;
            "documentation") phase_display="📚 Documentation & Guides" ;;
            "architecture") phase_display="🏗️ System Architecture" ;;
            "completion") phase_display="🎉 Completion & Success" ;;
            *) phase_display="📄 $phase" ;;
        esac
        
        echo "### $phase_display" >> "$index_file"
        echo "*$file_count files*" >> "$index_file"
        echo "" >> "$index_file"
        
        # List files in this phase
        if [ "$file_count" -gt 0 ]; then
            generate_sorted_file_entries "$lifecycle_dir" "$index_file"
        else
            echo "*No files in this phase*" >> "$index_file"
        fi
        echo "" >> "$index_file"
    done

    # Generate system function index
    cat >> "$index_file" << EOF

---

## ⚙️ Documentation by System Function

EOF

    for system_dir in "$DOCS_ROOT/by-system"/*; do
        [ -d "$system_dir" ] || continue
        local function=$(basename "$system_dir")
        local file_count=$(find "$system_dir" -type l | wc -l)
        
        # Map function to readable format with icons
        local function_display=""
        case "$function" in
            "admin-tools") function_display="🛠️ Admin Tools & Management" ;;
            "node-red") function_display="🔴 Node-RED System" ;;
            "browser-ui") function_display="🌐 Browser & UI" ;;
            "window-management") function_display="🖥️ Window Management" ;;
            "integration") function_display="🔗 System Integration" ;;
            "character-simulation") function_display="🎭 Character Simulation" ;;
            "content-management") function_display="📝 Content Management" ;;
            "diagnostics") function_display="🔍 Diagnostics & Analysis" ;;
            "success-reports") function_display="🏆 Success Reports" ;;
            *) function_display="⚙️ $function" ;;
        esac
        
        echo "### $function_display" >> "$index_file"
        echo "*$file_count files*" >> "$index_file"
        echo "" >> "$index_file"
        
        # List files in this function area
        if [ "$file_count" -gt 0 ]; then
            generate_sorted_file_entries "$system_dir" "$index_file"
        else
            echo "*No files in this function area*" >> "$index_file"
        fi
        echo "" >> "$index_file"
    done

    # Add footer with metadata
    cat >> "$index_file" << EOF

---

## 📊 Documentation Statistics

| Facet | Categories | Total Files |
|-------|------------|-------------|
| 📅 Time | $(find "$DOCS_ROOT/by-time" -mindepth 1 -maxdepth 1 -type d | wc -l) periods | $(find "$DOCS_ROOT/by-time" -type l | wc -l) |
| 🔄 SDLC | $(find "$DOCS_ROOT/by-lifecycle" -mindepth 1 -maxdepth 1 -type d | wc -l) phases | $(find "$DOCS_ROOT/by-lifecycle" -type l | wc -l) |
| ⚙️ System | $(find "$DOCS_ROOT/by-system" -mindepth 1 -maxdepth 1 -type d | wc -l) functions | $(find "$DOCS_ROOT/by-system" -type l | wc -l) |

## 🔗 Quick Navigation

- **[📂 Browse by Time](by-time/)** - Find documents by creation/modification date
- **[🔄 Browse by Lifecycle](by-lifecycle/)** - Explore by development phase  
- **[⚙️ Browse by System](by-system/)** - Navigate by functional area
- **[🗂️ Navigation Guide](README-NAVIGATION.md)** - Detailed usage instructions

## 🛠️ Maintenance

This index is automatically generated and maintained by:
\`\`\`bash
./organize-documentation.sh
\`\`\`

The script analyzes all markdown files and creates both the symlink organization and this comprehensive index.

---

*Generated by AI-Kit Documentation Organization System*  
*Last updated: $current_date*
EOF

    echo -e "${GREEN}✅ Documentation index created: $index_file${NC}"
}

# Create navigation helper
create_navigation_helper() {
    cat > "$DOCS_ROOT/README-NAVIGATION.md" << 'EOF'
# 🗂️ AI-Kit Documentation Navigation Guide

This directory contains organized views of all project documentation using symlinks.

## 📁 Directory Structure

### 📅 By Time (`by-time/`)
- **2025-06-15-today/** - Today's documentation
- **2025-06-14-yesterday/** - Yesterday's files
- **week-prior/** - Files from the past week
- **historical/** - Older documentation

### 🔄 By SDLC Phase (`by-lifecycle/`)
- **planning/** - Architecture and design documents
- **implementation/** - Development and integration docs
- **testing/** - Testing and validation documents
- **debugging/** - Bug fixes and problem resolution
- **enhancement/** - Improvements and UX enhancements
- **documentation/** - READMEs and guides
- **architecture/** - System architecture documents
- **completion/** - Success reports and summaries

### ⚙️ By System Function (`by-system/`)
- **admin-tools/** - Admin scripts and management tools
- **node-red/** - Node-RED related documentation
- **browser-ui/** - Browser interface and UI fixes
- **window-management/** - Virtual desktop and window management
- **integration/** - System integration documents
- **character-simulation/** - Character-specific documentation
- **content-management/** - Content and collections
- **diagnostics/** - Debug and analysis documents
- **success-reports/** - Project success documentation

## 🎯 Usage Tips

1. **Finding Recent Work**: Check `by-time/2025-06-15-today/`
2. **Understanding Architecture**: Browse `by-lifecycle/architecture/`
3. **System-Specific Issues**: Navigate to relevant `by-system/` folder
4. **Project Status**: Review `by-system/success-reports/`

## 🔗 Symlink Structure

All files are symlinks pointing to the original files. This allows:
- Multiple organizational views of the same content
- No file duplication
- Automatic updates when source files change
- Easy maintenance through the organization script

## 🛠️ Maintenance

Run the organization script to update the structure:
```bash
./docs/organize-documentation.sh
```

Generated automatically by AI-Kit Documentation Organization Script.
EOF

    echo -e "${GREEN}✅ Navigation helper created: $DOCS_ROOT/README-NAVIGATION.md${NC}"
}

# Main execution
main() {
    # Handle command line options
    case "${1:-}" in
        "--clean"|"-c")
            clean_symlinks
            exit 0
            ;;
        "--help"|"-h")
            echo "AI-Kit Documentation Organization Script"
            echo "======================================="
            echo ""
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  -c, --clean    Clean existing symlinks only"
            echo "  -h, --help     Show this help"
            echo ""
            echo "Default: Full reorganization of documentation"
            exit 0
            ;;
    esac
    
    # Full reorganization
    create_base_structure
    clean_symlinks
    organize_documentation
    create_navigation_helper
    generate_documentation_index
    generate_summary
    
    echo -e "\n${GREEN}🎉 Documentation organization complete!${NC}"
    echo -e "${CYAN}💡 Browse organized docs in: $DOCS_ROOT/by-*/${NC}"
}

# Execute main function
main "$@"
