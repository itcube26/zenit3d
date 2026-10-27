#!/bin/bash
set -e

echo "🖨️  Начало установки конфигурации ZENIT для OrcaSlicer..."

# 1. Определяем все возможные пути к конфигурации OrcaSlicer
CONFIG_DIRS=(
    "$HOME/.var/app/com.orcaslicer.OrcaSlicer/config/OrcaSlicer/"
    "$HOME/snap/orcaslicer/current/.config/OrcaSlicer"
    "$HOME/.config/OrcaSlicer"
)

# 2. Создаем временную директорию и скачиваем репозиторий
TEMP_DIR=$(mktemp -d)
REPO_URL="https://github.com/itcube26/zenit3d/archive/refs/heads/main.zip"

echo "⬇️  Скачивание конфигурации из репозитория..."
if ! curl -sSL "$REPO_URL" -o "$TEMP_DIR/zenit3d.zip"; then
    echo "❌ Ошибка скачивания. Проверьте URL репозитория."
    rm -rf "$TEMP_DIR"
    exit 1
fi

echo "📦 Распаковка файлов..."
if ! command -v unzip &> /dev/null; then
    echo "❌ Утилита 'unzip' не найдена. Установите ее (например: sudo apt install unzip)"
    rm -rf "$TEMP_DIR"
    exit 1
fi
unzip -q "$TEMP_DIR/zenit3d.zip" -d "$TEMP_DIR"

# 3. Проходим по всем возможным директориям и устанавливаем конфиги туда, где они есть
INSTALLED_COUNT=0

for TARGET_DIR in "${CONFIG_DIRS[@]}"; do
    if [ -d "$TARGET_DIR" ]; then
        echo "✅ Найдена активная установка в: $TARGET_DIR"
        
        # Создаем резервную копию существующих файлов (если они есть)
        BACKUP_DIR="$TARGET_DIR/zenit_backup_$(date +%Y%m%d_%H%M%S)"
        echo "💾 Создание резервной копии в: $BACKUP_DIR"
        mkdir -p "$BACKUP_DIR"
        
        [ -d "$TARGET_DIR/printers" ] && cp -r "$TARGET_DIR/printers" "$BACKUP_DIR/" 2>/dev/null || true
        [ -d "$TARGET_DIR/system" ] && cp -r "$TARGET_DIR/system" "$BACKUP_DIR/" 2>/dev/null || true
        [ -d "$TARGET_DIR/user" ] && cp -r "$TARGET_DIR/user" "$BACKUP_DIR/" 2>/dev/null || true

        # Копируем новые файлы конфигурации ZENIT
        echo "📂 Копирование конфигурации ZENIT..."
        cp -r "$TEMP_DIR/zenit3d-main/printers" "$TARGET_DIR/"
        cp -r "$TEMP_DIR/zenit3d-main/system" "$TARGET_DIR/"
        cp -r "$TEMP_DIR/zenit3d-main/user" "$TARGET_DIR/"
        
        ((INSTALLED_COUNT++))
        echo "----------------------------------------"
    fi
done

# 4. Очистка временных файлов
rm -rf "$TEMP_DIR"

# 5. Итоговый вывод
echo ""
if [ "$INSTALLED_COUNT" -gt 0 ]; then
    echo "🎉 Готово! Конфигурация ZENIT успешно установлена в $INSTALLED_COUNT директорию(ий)."
    echo "🔄 Пожалуйста, полностью закройте и перезапустите OrcaSlicer."
    echo "💡 После запуска выберите принтер серии ZENIT в меню слева."
else
    echo "⚠️  Ни одна директория конфигурации OrcaSlicer не найдена."
    echo "💡 Совет: Запустите OrcaSlicer хотя бы один раз, чтобы он создал папку конфигурации, а затем запустите этот скрипт снова."
fi