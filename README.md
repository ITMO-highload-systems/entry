# Проект Notion

Этот проект включает несколько сервисов, связанных между собой. Для его запуска необходимо выполнить два скрипта: `clone_build.sh` и `run.sh`.

## Шаги для запуска проекта

1. **Клонирование репозиториев и сборка Docker образов:**

   Для начала необходимо клонировать все необходимые репозитории и собрать Docker образы. Для этого используйте скрипт `clone_build.sh`.

   **Запуск:**

   ```bash
   ./clone_build.sh
   ```

2. **Запуск образов и накатывание миграций для базы данных:**

   После клонирования сборки образов необходимо запустить их. Для этого используйте скрипт `run.sh`.

   **Запуск:**

   ```bash
   ./run.sh
   ```