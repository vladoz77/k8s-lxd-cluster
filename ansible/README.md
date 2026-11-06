# Ansible: настройка Kubernetes-кластера

Каталог содержит playbook’и установки Kubernetes и роли для подготовки узлов, инициализации control plane и подключения узлов. LXD-инстансы обнаруживаются dynamic inventory plugin `community.general.lxd`.

## Playbook’и

| Playbook | Назначение |
|---|---|
| [`k8s-install-all.yaml`](k8s-install-all.yaml) | Полная установка: общая настройка узлов, первый master, дополнительные master в HA-режиме и worker. |
| [`k8s-master-install.yaml`](k8s-master-install.yaml) | Общая подготовка master, настройка HA при включённом `ha_enabled`, инициализация первого control plane и подключение дополнительных master. |
| [`k8s-add-worker.yaml`](k8s-add-worker.yaml) | Подготовка и подключение worker-узлов к уже созданному кластеру. |

## Установка зависимостей и запуск

Запускайте команды из каталога `ansible/`:

```bash
ansible-galaxy collection install -r requirements.yaml
ansible-inventory -i inventories/dev/lxd.yaml --graph
ansible-playbook -i inventories/dev/lxd.yaml k8s-install-all.yaml
```

Для другого окружения используйте `inventories/prod/lxd.yaml` и соответствующие `inventories/prod/group_vars/all.yaml`. Перед запуском проверьте соединение с LXD, выбранные группы `master`/`worker`, факты сетевого интерфейса и адрес API endpoint.

`ansible.cfg` задаёт `/usr/bin/python3` как Python interpreter для удалённых узлов и отключает проверку host key. Учитывайте это при оценке требований к безопасности SSH-соединений.

## Роли

- [`k8s-common-config`](roles/k8s-common-config/Readme.md) — базовая подготовка узлов и containerd.
- [`k8s-ha-master-config`](roles/k8s-ha-master-config/Readme.md) — HAProxy, Keepalived и виртуальный IP control plane.
- [`k8s-config-master`](roles/k8s-config-master/Readme.md) — `kubeadm init`, CNI и дополнительные компоненты на первом master.
- [`k8s-join-master`](roles/k8s-join-master/Readme.md) — присоединение control-plane узла в HA-кластере.
- [`k8s-join-worker`](roles/k8s-join-worker/Readme.md) — присоединение worker-узла.

## Переменные и секреты

Общие endpoint-переменные и выбор первого master заданы в [`group_vars/all.yaml`](group_vars/all.yaml). Параметры окружений находятся в `inventories/<environment>/group_vars/all.yaml`. Для параметров ролей см. `defaults/main.yaml` каждой роли.

Не храните пароли и другие секреты открытым текстом в inventory или `group_vars`. Используйте Ansible Vault либо другое защищённое хранилище и переопределяйте небезопасные значения по умолчанию перед запуском.
