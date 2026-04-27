# DevOps training — Flask + Docker + Ansible

**Предварительно (Ubuntu / WSL):** зависимости ставятся в каталог **`.venv`** (так обходится PEP 668 — системный Python «externally managed»). Нужны `python3` и пакет **`python3-venv`**:

```bash
sudo apt-get update
sudo apt-get install -y python3-venv
```

После `make install` используйте интерпретатор `.venv/bin/python` или по-прежнему команды `make run` / `make test`.

Краткие команды из корня репозитория. Полный список целей Makefile:

```bash
make help
```

## Локальный запуск

```bash
make install
make run
```

Вручную (после `python3 -m venv .venv` и `source .venv/bin/activate`):

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
PYTHONPATH=. .venv/bin/python -m pytest app/tests -v
```

## Линт

```bash
make lint
```

Проверяются Bash-скрипты (`shellcheck`) и код в `app/` (`ruff` ставится в `.venv` при `make install`).

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
dada