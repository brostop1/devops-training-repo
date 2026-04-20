.DEFAULT_GOAL := help

export PYTHONPATH := $(CURDIR)

VENV := $(CURDIR)/.venv
PY := $(VENV)/bin/python
PIP := $(VENV)/bin/pip

.PHONY: help install lint test run docker-up docker-down diagnose ansible-ping ansible-local ansible-deploy

help: ## Показать все команды
	@grep -E '^[a-zA-Z0-9_-]+:.*?## ' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

install: ## Создать .venv и установить зависимости (обходит PEP 668 на Ubuntu/WSL)
	@command -v python3 >/dev/null || { echo "Нужен python3"; exit 1; }
	@python3 -c "import venv" 2>/dev/null || { \
		echo "Нет модуля venv. Установите:"; \
		echo "  sudo apt-get update && sudo apt-get install -y python3-venv"; \
		exit 1; \
	}
	@test -d "$(VENV)" || python3 -m venv "$(VENV)"
	$(PIP) install --upgrade pip
	$(PIP) install -r app/requirements.txt
	$(PIP) install ruff

lint: install ## Проверка кода: ruff (Python), shellcheck (Bash)
	shellcheck scripts/*.sh
	$(PY) -m ruff check app

test: install ## Запустить тесты
	$(PY) -m pytest app/tests -v

run: install ## Локальный запуск Flask (dev-сервер)
	$(PY) app/main.py

docker-up: ## Поднять стек в Docker Compose
	docker compose up -d --build

docker-down: ## Остановить Docker Compose
	docker compose down

diagnose: ## Диагностика сервера (пример URL — health)
	./scripts/server-info.sh http://localhost:5000/health

ansible-ping: ## Ansible: ping по inventory (локально)
	cd ansible && ansible all -i inventory.ini -m ping -l local

ansible-local: ## Ansible: деплой playbook на localhost
	cd ansible && ansible-playbook -i inventory.ini playbook.yml -l local

ansible-deploy: ## Ansible: деплой на app_servers (настройте inventory.ini)
	cd ansible && ansible-playbook -i inventory.ini playbook.yml -l app_servers
