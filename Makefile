.DEFAULT_GOAL := help

export PYTHONPATH := $(CURDIR)

.PHONY: help install lint test run docker-up docker-down diagnose ansible-ping ansible-local ansible-deploy

help: ## Показать все команды
	@grep -E '^[a-zA-Z0-9_-]+:.*?## ' Makefile | sort | awk 'BEGIN {FS = ":.*?## "}; {printf "  %-20s %s\n", $$1, $$2}'

install: ## Установить зависимости Python
	python3 -m pip install --upgrade pip
	python3 -m pip install -r app/requirements.txt

lint: ## Проверка кода: ruff или flake8 (Python), shellcheck (Bash)
	shellcheck scripts/*.sh
	@if command -v ruff >/dev/null 2>&1; then \
		ruff check app; \
	elif command -v flake8 >/dev/null 2>&1; then \
		flake8 app; \
	else \
		echo "Установите ruff или flake8: pip install ruff"; \
		exit 1; \
	fi

test: ## Запустить тесты
	python3 -m pytest app/tests -v

run: ## Локальный запуск Flask (dev-сервер)
	python3 app/main.py

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
