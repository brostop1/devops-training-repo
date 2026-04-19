# Ansible: быстрый старт для проекта

Минимальный набор файлов:

- `ansible.cfg`
- `inventory.ini`
- `playbook.yml`

## 1) Установка Ansible (Ubuntu/WSL)

```bash
sudo apt update
sudo apt install -y ansible-core
```

Проверка:

```bash
ansible --version
ansible-playbook --version
```

## 2) Локальный запуск (тест)

Из каталога `ansible/`:

```bash
ansible all -i inventory.ini -m ping -l local
ansible-playbook -i inventory.ini playbook.yml -l local
```

Проверка приложения:

```bash
curl http://127.0.0.1:5000/health
```

Если порт `5000` занят:

```bash
ansible-playbook -i inventory.ini playbook.yml -l local -e app_port=5001
curl http://127.0.0.1:5001/health
```

## 3) Деплой на сервер

Откройте `inventory.ini` и добавьте хост в группу `app_servers`, например:

```ini
[app_servers]
server1 ansible_host=203.0.113.10 ansible_user=ubuntu ansible_ssh_private_key_file=~/.ssh/id_rsa
```

Проверка подключения:

```bash
ansible all -i inventory.ini -m ping -l app_servers
```

Запуск деплоя:

```bash
ansible-playbook -i inventory.ini playbook.yml -l app_servers
```

Если Docker на сервере еще не установлен:

```bash
ansible-playbook -i inventory.ini playbook.yml -l app_servers -e install_docker=true
```

Проверка после деплоя:

```bash
curl http://<SERVER_IP>:5000/health
```

## Что делает playbook

1. Проверяет подключение к хосту.
2. Опционально устанавливает Docker (`install_docker=true`).
3. Копирует `Dockerfile`, `docker-compose.yml`, папку `app/` в `deploy_dir`.
4. Проверяет, что целевой порт свободен.
5. Запускает `docker compose up -d --build`.
6. Ждет успешный ответ от `/health`.

