#!/bin/bash
set -e

echo "🖨️  Начало установки конфигурации ZENIT для OrcaSlicer..."

# 1. Определение целевой директории конфигурации OrcaSlicer
CONFIG_DIR=""

if [ -d "$HOME/.var/app/io.github.softfever.OrcaSlicer/config/OrcaSlicer" ]; then
    CONFIG_DIR="$HOME/.var/app/io.github.softfever.OrcaSlicer/config/OrcaSlicer"
    echo "✅ Обнаружена версия Flatpak."
elif [ -d "$HOME/snap/orcaslicer/current/.config/OrcaSlicer" ]; then
    CONFIG_DIR="$HOME/snap/orcaslicer/current/.config/OrcaSlicer"
    echo "✅ Обнаружена версия Snap."
elif [ -d "$HOME/.config/OrcaSlicer" ]; then
    CONFIG_DIR="$HOME/.config/OrcaSlicer"
    echo "✅ Обнаружена стандартная версия (AppImage / Deb / RPM)."
else
    # Если OrcaSlicer еще ни разу не запускался, создаем стандартную директорию
    CONFIG_DIR="$HOME/.config/OrcaSlicer"
    echo "⚠️  Директория конфигурации не найдена. Будет создана стандартная: $CONFIG_DIR"
    mkdir -p "$CONFIG_DIR"
fi

echo "🎯 Целевая директория: $CONFIG_DIR"

# 2. Создание временной директории и скачивание репозитория
TEMP_DIR=$(mktemp -d)
REPO_URL="https://github.com/itcube26/zenit3d/archive/refs/heads/main.zip"

echo "⬇️  Скачивание конфигурации из репозитория..."
if ! curl -sSL "$REPO_URL" -o "$TEMP_DIR/zenit3d.zip"; then
    echo "❌ Ошибка скачивания. Проверьте URL репозитория."
    rm -rf "$TEMP_DIR"
    exit 1
fi

# 3. Распаковка
echo "📦 Распаковка файлов..."
if ! command -v unzip &> /dev/null; then
    echo "❌ Утилита 'unzip' не найдена. Установите ее (например: sudo apt install unzip)"
    rm -rf "$TEMP_DIR"
    exit 1
fi
unzip -q "$TEMP_DIR/zenit3d.zip" -d "$TEMP_DIR"

# 4. Резервное копирование существующих файлов (если они есть)
BACKUP_DIR="$CONFIG_DIR/zenit_backup_$(date +%Y%m%d_%H%M%S)"
if [ -d "$CONFIG_DIR/printers" ] || [ -d "$CONFIG_DIR/system" ] || [ -d "$CONFIG_DIR/user" ]; then
    echo "💾 Создание резервной копии существующих настроек в: $BACKUP_DIR"
    mkdir -p "$BACKUP_DIR"
    [ -d "$CONFIG_DIR/printers" ] && cp -r "$CONFIG_DIR/printers" "$BACKUP_DIR/"
    [ -d "$CONFIG_DIR/system" ] && cp -r "$CONFIG_DIR/system" "$BACKUP_DIR/"
    [ -d "$CONFIG_DIR/user" ] && cp -r "$CONFIG_DIR/user" "$BACKUP_DIR/"
fi

# 5. Копирование новых файлов
echo "📂 Копирование конфигурации ZENIT..."
# Примечание: имя папки при распаковке будет zenit3d-main (или имя_ветки)
cp -r "$TEMP_DIR/zenit3d-main/printers" "$CONFIG_DIR/"
cp -r "$TEMP_DIR/zenit3d-main/system" "$CONFIG_DIR/"
cp -r "$TEMP_DIR/zenit3d-main/user" "$CONFIG_DIR/"

# 6. Очистка временных файлов
rm -rf "$TEMP_DIR"

echo ""
echo "🎉 Готово! Конфигурация ZENIT успешно установлена."
echo "🔄 Пожалуйста, полностью закройте и перезапустите OrcaSlicer."
echo "💡 После запуска выберите принтер серии ZENIT в меню слева."