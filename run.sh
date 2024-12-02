#!/bin/bash

# Docker Compose файл
COMPOSE_FILE="compose.yaml"

# Сервисы, которые можно запускать одновременно
PARALLEL_SERVICES=(
  "minio1"
  "postgres"
  "python-exec"
  "kafka1"
  "kafka2"
  "kafka3"
)

# Сервисы, которые нужно запускать с интервалом
SEQUENTIAL_SERVICES=(
#  "kafka-ui"
  "notion-config"
  "notion-eureka"
  "notion-gateway"
  "notion-security"
  "notion-core"
  "notion-code-exec"
  "notion-s3"
  "notion-notification"
)

wait_for_postgres() {
  local container_name="postgres"
  local sql_scripts=(
    "./init-db/init-databases.sql:postgres"
    "./init-db/code-exec-init.sql:notion-code-exec"
    "./init-db/notion-s3-init.sql:notion-s3"
  )

  echo "Ожидание запуска Postgres..."
  while ! docker exec "$container_name" pg_isready -U postgres > /dev/null 2>&1; do
    echo "Postgres еще не готов, ожидаем..."
    sleep 5
  done

  echo "Postgres готов. Выполняем SQL-скрипты..."
  for script in "${sql_scripts[@]}"; do
    IFS=":" read -r script_path db_name <<< "$script"

    if [ -f "$script_path" ]; then
      echo "Выполняем $script_path для базы данных $db_name..."
      docker exec -i "$container_name" psql -U postgres -d "$db_name" < "$script_path"
      if [ $? -eq 0 ]; then
        echo "SQL-скрипт $script_path успешно выполнен для базы данных $db_name."
      else
        echo "Ошибка выполнения SQL-скрипта $script_path для базы данных $db_name."
        exit 1
      fi
    else
      echo "SQL-скрипт $script_path не найден."
      exit 1
    fi
  done

  echo "Все SQL-скрипты успешно выполнены."
}

# Интервал между запуском сервисов (в секундах)
INTERVAL=20
mkdir -p "minio_storage/mnt/data/compose"
echo "Директория minio_storage/mnt/data/compose создана."

echo "Запуск параллельных сервисов: ${PARALLEL_SERVICES[*]}"
docker-compose -f "$COMPOSE_FILE" up -d "${PARALLEL_SERVICES[@]}"
echo "Параллельные сервисы запущены."

# Выполнение SQL-скрипта после запуска Postgres
if [[ " ${PARALLEL_SERVICES[*]} " == *"postgres"* ]]; then
  wait_for_postgres
fi

# Запуск сервисов с интервалом
for i in "${!SEQUENTIAL_SERVICES[@]}"; do
  SERVICE="${SEQUENTIAL_SERVICES[$i]}"
  echo "Запуск сервиса: $SERVICE"
  docker-compose -f "$COMPOSE_FILE" up -d "$SERVICE"

  # Ожидание только если это не последний сервис
  if [ "$i" -lt $((${#SEQUENTIAL_SERVICES[@]} - 1)) ]; then
    echo "Ожидание $INTERVAL секунд перед запуском следующего сервиса..."
    sleep "$INTERVAL"
  fi
done



echo "Все сервисы успешно запущены."
