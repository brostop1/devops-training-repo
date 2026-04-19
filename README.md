# DevOps training — Flask + Docker + Ansible

Краткие команды из корня репозитория. Полный список целей Makefile:

```bash
make help
```

## Локальный запуск

```bash
make install
make run
```

Вручную:

```bash
pip install -r app/requirements.txt
PYTHONPATH=. python app/main.py
```

Приложение: [http://127.0.0.1:5000](http://127.0.0.1:5000), health: [http://127.0.0.1:5000/health](http://127.0.0.1:5000/health).

## Docker Compose

```bash
make docker-up
```

Вручную:

```bash
docker compose up -d
```

Остановка: `make docker-down`.

## Тесты

```bash
make test
```

Вручную:

```bash
PYTHONPATH=. pytest app/tests/ -v
```

## Линт

```bash
pip install ruff   # один раз, если ещё не стоит
make lint
```

Проверяются Bash-скрипты (`shellcheck`) и код в `app/` (`ruff` или `flake8`).

## Диагностика сервера

```bash
make diagnose
```

Вручную:

```bash
./scripts/server-info.sh http://localhost:5000/health
```

## Ansible

Подробности и деплой на сервер — в [ansible/README.md](ansible/README.md).

Из корня репозитория:

```bash
ansible-playbook -i ansible/inventory.ini ansible/playbook.yml -l local
```

Или через Makefile:

```bash
make ansible-local
```
