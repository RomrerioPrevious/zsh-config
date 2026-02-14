#!/bin/bash

# Цвета для вывода
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Функция для вывода сообщений
print_message() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

# Проверка наличия интернета
print_message "Проверка подключения к интернету..."
if ! ping -c 1 github.com &> /dev/null; then
    print_error "Нет подключения к интернету!"
    exit 1
fi

# Обновление списка пакетов
print_message "Обновление списка пакетов..."
sudo apt update

# 1. Установка zsh
print_message "Установка zsh..."
sudo apt install -y zsh
if [ $? -eq 0 ]; then
    print_success "zsh установлен"
else
    print_error "Ошибка установки zsh"
    exit 1
fi

# 2. Смена shell на zsh
print_message "Смена shell на zsh..."
if [ "$SHELL" != "$(which zsh)" ]; then
    chsh -s $(which zsh)
    print_success "Shell изменен на zsh. Изменения вступят в силу после перезагрузки."
else
    print_message "zsh уже является текущим shell"
fi

# 3. Установка oh-my-zsh
print_message "Установка oh-my-zsh..."
if [ ! -d "$HOME/.oh-my-zsh" ]; then
    sh -c "$(curl -fsSL https://raw.github.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended
    print_success "oh-my-zsh установлен"
else
    print_message "oh-my-zsh уже установлен"
fi

# 4. Установка темы powerlevel10k
print_message "Установка темы powerlevel10k..."
if [ ! -d "${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k" ]; then
    git clone --depth=1 https://github.com/romkatv/powerlevel10k.git ${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}/themes/powerlevel10k
    print_success "powerlevel10k установлена"
else
    print_message "powerlevel10k уже установлена"
fi

# 5. Загрузка и установка .zshrc
print_message "Загрузка .zshrc из репозитория..."
curl -fsSL https://raw.githubusercontent.com/RomrerioPrevious/zsh-config/main/.zshrc -o $HOME/.zshrc
if [ $? -eq 0 ]; then
    print_success ".zshrc загружен"
else
    print_error "Ошибка загрузки .zshrc"
fi

# 6. Установка плагинов
print_message "Установка плагинов..."
ZSH_CUSTOM=${ZSH_CUSTOM:-$HOME/.oh-my-zsh/custom}

# Плагин zsh-autosuggestions
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-autosuggestions" ]; then
    git clone https://github.com/zsh-users/zsh-autosuggestions $ZSH_CUSTOM/plugins/zsh-autosuggestions
    print_success "zsh-autosuggestions установлен"
fi

# Плагин zsh-syntax-highlighting
if [ ! -d "$ZSH_CUSTOM/plugins/zsh-syntax-highlighting" ]; then
    git clone https://github.com/zsh-users/zsh-syntax-highlighting $ZSH_CUSTOM/plugins/zsh-syntax-highlighting
    print_success "zsh-syntax-highlighting установлен"
fi

# Плагин z (обычно уже включен в oh-my-zsh)
print_message "Плагин z уже доступен в oh-my-zsh"

# 7. Загрузка .p10k.zsh
print_message "Загрузка .p10k.zsh из репозитория..."
curl -fsSL https://raw.githubusercontent.com/RomrerioPrevious/zsh-config/main/.p10k.zsh -o $HOME/.p10k.zsh
if [ $? -eq 0 ]; then
    print_success ".p10k.zsh загружен"
else
    print_error "Ошибка загрузки .p10k.zsh"
fi

# 8. Установка дополнительных утилит
print_message "Установка yazi, neofetch, tree..."
sudo apt install -y neofetch tree

# Установка yazi (может потребоваться дополнительные действия)
print_message "Установка yazi..."
if ! command -v yazi &> /dev/null; then
    # Yazi может устанавливаться через cargo или другие менеджеры
    # Проверяем наличие cargo и устанавливаем через него
    if command -v cargo &> /dev/null; then
        cargo install yazi
    else
        print_warning "Cargo не найден. Установка yazi через apt (если доступно)..."
        sudo apt install -y yazi || print_warning "Yazi не найден в репозиториях. Установите вручную."
    fi
else
    print_message "yazi уже установлен"
fi

# Установка logo-ls
print_message "Установка logo-ls..."
if ! command -v logo-ls &> /dev/null; then
    # Скачиваем последнюю версию с GitHub
    LATEST_VERSION=$(curl -s https://api.github.com/repos/canta2899/logo-ls/releases/latest | grep -oP '"tag_name": "\K(.*)(?=")')
    wget https://github.com/canta2899/logo-ls/releases/download/${LATEST_VERSION}/logo-ls_amd64.deb
    sudo dpkg -i logo-ls_amd64.deb
    rm logo-ls_amd64.deb
    print_success "logo-ls установлен"
else
    print_message "logo-ls уже установлен"
fi

# 9. Установка brew
print_message "Установка Homebrew..."
if ! command -v brew &> /dev/null; then
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
    
    # Добавление brew в PATH для текущей сессии
    echo 'eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"' >> $HOME/.profile
    eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    
    print_success "Homebrew установлен"
else
    print_message "Homebrew уже установлен"
fi

# 10. Установка nvim через brew
print_message "Установка neovim через brew..."
brew install neovim
if [ $? -eq 0 ]; then
    print_success "neovim установлен"
else
    print_error "Ошибка установки neovim"
fi

# 11. Копирование lua файлов для nvim
print_message "Настройка neovim..."

# Создание директории для конфигурации nvim
NVIM_CONFIG_DIR="$HOME/.config/nvim"
mkdir -p $NVIM_CONFIG_DIR

# Создаем временную директорию для клонирования репозитория
TEMP_DIR=$(mktemp -d)
print_message "Клонирование репозитория с конфигами nvim..."
git clone https://github.com/RomrerioPrevious/Romrerio-Neo.git $TEMP_DIR

# Копирование lua файлов
if [ -d "$TEMP_DIR" ]; then
    # Копируем все lua файлы и папки
    cp -r $TEMP_DIR/* $NVIM_CONFIG_DIR/ 2>/dev/null
    
    # Если есть папка lua, копируем её содержимое
    if [ -d "$TEMP_DIR/lua" ]; then
        mkdir -p $NVIM_CONFIG_DIR/lua
        cp -r $TEMP_DIR/lua/* $NVIM_CONFIG_DIR/lua/
    fi
    
    print_success "Конфигурационные файлы nvim скопированы"
    
    # Удаляем временную директорию
    rm -rf $TEMP_DIR
else
    print_error "Не удалось клонировать репозиторий"
fi

print_message "Установка завершена!"
print_warning "Для применения изменений перезагрузите систему или выполните:"
print_warning "exec zsh"
print_warning "Или перезапустите терминал"