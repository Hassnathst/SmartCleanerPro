#!/bin/bash
# === Handle info and update arguments ===
if [[ "$1" == "info" ]]; then
  echo "🧹 Smart Folder Cleaner Pro"
  echo "Version: $VERSION"
  echo "Script location: $SCRIPT_PATH"
  echo "Log file: $HOME/cleaner_log.txt"
  echo "Backups: $HOME/backups"
  exit 0
fi

if [[ "$1" == "update" ]]; then
  echo "🔄 Checking for updates..."
  tmpfile="/tmp/cleaner_update.sh"
  if curl -fsSL "$UPDATE_URL" -o "$tmpfile"; then
      echo "✅ Downloaded new version!"
      sudo mv "$tmpfile" "$SCRIPT_PATH"
      sudo chmod +x "$SCRIPT_PATH"
      echo "🚀 Cleaner updated successfully!"
  else
      echo "❌ Failed to download update."
  fi
  exit 0
fi

# === SMART FOLDER CLEANER PRO (with Backup + Safety + Colors + Animation) ===

LOGFILE="$HOME/cleaner_log.txt"
BACKUP_DIR="$HOME/backups"
TIMESTAMP=$(date "+%Y-%m-%d_%H-%M-%S")

# === Color codes ===
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
CYAN='\033[0;36m'
NC='\033[0m' # No Color

# === Spinner animation ===
spinner() {
  local pid=$!
  local delay=0.1
  local spin='|/-\'
  while ps -p $pid > /dev/null 2>&1; do
    for i in ${spin}; do
      echo -ne "\r${YELLOW}Processing... $i${NC}"
      sleep $delay
    done
  done
  echo -ne "\r${GREEN}Done!           ${NC}\n"
}

# === Function to create backup ===
create_backup() {
    folder_path=$1
    mkdir -p "$BACKUP_DIR"
    backup_file="$BACKUP_DIR/backup_$(basename "$folder_path")_$TIMESTAMP.zip"
    echo -e "${CYAN}Creating backup: $backup_file ...${NC}"
    (zip -r "$backup_file" "$folder_path" > /dev/null 2>&1) & spinner
    echo -e "${GREEN}✅ Backup created at $backup_file${NC}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Backup created: $backup_file" >> "$LOGFILE"
}

# === Header ===
clear
echo -e "${BLUE}=============================="
echo -e "   🧹 SMART FOLDER CLEANER PRO"
echo -e "==============================${NC}"
echo ""
echo -e "${CYAN}Choose an option:${NC}"
echo "1) Clean by file extension"
echo "2) Clean old files (by days)"
echo ""
read -p "Enter your choice (1 or 2): " choice

if [ "$choice" == "1" ]; then
    echo ""
    echo -e "${CYAN}Enter the folder path:${NC}"
    read folder
    echo -e "${CYAN}Enter the file extension to delete (example: .log or .tmp):${NC}"
    read ext

    echo ""
    echo -e "${YELLOW}You are about to delete all *$ext files in $folder${NC}"
    read -p "Are you sure? (Y/N): " confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        create_backup "$folder"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Cleaning by extension ($ext) in $folder" >> "$LOGFILE"
        echo -e "${YELLOW}Deleting all files ending with $ext inside $folder ...${NC}"
        (find "$folder" -type f -name "*$ext" -print -exec rm -f {} \; >> "$LOGFILE" 2>&1) & spinner
        echo -e "${GREEN}✅ Cleaning complete!${NC}"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Completed extension cleaning." >> "$LOGFILE"
    else
        echo -e "${RED}❌ Cleaning cancelled.${NC}"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Cleaning cancelled by user (extension)." >> "$LOGFILE"
    fi

elif [ "$choice" == "2" ]; then
    echo ""
    echo -e "${CYAN}Enter the folder path:${NC}"
    read folder
    echo -e "${CYAN}Delete files older than how many days?${NC}"
    read days

    echo ""
    echo -e "${YELLOW}You are about to delete files older than $days days in $folder${NC}"
    read -p "Are you sure? (Y/N): " confirm

    if [[ "$confirm" =~ ^[Yy]$ ]]; then
        create_backup "$folder"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Cleaning files older than $days days in $folder" >> "$LOGFILE"
        echo -e "${YELLOW}Deleting files older than $days days from $folder ...${NC}"
        (find "$folder" -type f -mtime +$days -print -exec rm -f {} \; >> "$LOGFILE" 2>&1) & spinner
        echo -e "${GREEN}✅ Old files cleaned successfully!${NC}"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Completed old-file cleaning." >> "$LOGFILE"
    else
        echo -e "${RED}❌ Cleaning cancelled.${NC}"
        echo "[$(date '+%Y-%m-%d %H:%M:%S')] Cleaning cancelled by user (old files)." >> "$LOGFILE"
    fi

else
    echo -e "${RED}❌ Invalid choice! Please run again and choose 1 or 2.${NC}"
    echo "[$(date '+%Y-%m-%d %H:%M:%S')] Invalid option selected." >> "$LOGFILE"
fi

echo ""
echo -e "${CYAN}🗂️ Log saved to:${NC} $LOGFILE"
echo -e "${CYAN}📦 Backups stored in:${NC} $BACKUP_DIR"
echo ""
