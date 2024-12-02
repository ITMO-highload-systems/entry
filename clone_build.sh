#!/bin/bash

# Список URL репозиториев
REPOSITORIES=(
  "https://github.com/ITMO-highload-systems/core.git=notion-core"
  "https://github.com/ITMO-highload-systems/s3.git=notion-s3"
  "https://github.com/ITMO-highload-systems/code-exec.git=notion-code-exec"
  "https://github.com/ITMO-highload-systems/gateway.git=notion-gateway"
  "https://github.com/ITMO-highload-systems/security.git=notion-security"
  "https://github.com/ITMO-highload-systems/config-server.git=notion-config"
  "https://github.com/ITMO-highload-systems/eureka.git=notion-eureka"
  "https://github.com/ITMO-highload-systems/notification.git=notion-notification"
)

# Директория, куда будут клонироваться репозитории
CLONE_DIR="cloned_repositories"

# Создаем директорию, если ее нет
mkdir -p "$CLONE_DIR"

# Переходим в директорию для клонирования
cd "$CLONE_DIR" || exit 1

# Функция для обработки одного репозитория
process_repo() {
  local repo_info="$1"
  local repo_url
  local image_name
  local repo_name

  # Разделяем URL репозитория и имя Docker-образа
  repo_url="${repo_info%=*}"
  image_name="${repo_info#*=}"

  # Извлечение имени репозитория из URL
  repo_name=$(basename "$repo_url" .git)

  # Клонирование репозитория
  if git clone "$repo_url"; then
    echo "Клонирован репозиторий: $repo_name"
    cd "$repo_name" || exit 1

    # Запуск команды Gradle
    if ./gradlew clean build -x test; then
      echo "Успешно выполнена команда в репозитории: $repo_name"
    else
      echo "Ошибка выполнения команды в репозитории: $repo_name"
    fi

    # Сборка Docker-образа
    if docker build -t "$image_name" .; then
      echo "Docker-образ успешно собран: $image_name"
    else
      echo "Ошибка сборки Docker-образа: $image_name"
    fi

    cd ..
  else
    echo "Ошибка клонирования репозитория: $repo_url"
  fi
}

# Обработка всех репозиториев
for REPO_URL in "${REPOSITORIES[@]}"; do
  process_repo "$REPO_URL"
done

echo "Скрипт завершен."
