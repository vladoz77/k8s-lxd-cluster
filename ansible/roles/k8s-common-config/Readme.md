# Роль `k8s-common-config`

Подготавливает Linux-узлы к установке Kubernetes: настраивает системные параметры и модули ядра, устанавливает Kubernetes RPM-пакеты и ставит containerd, `runc` и `crictl`.

Роль вызывается на всех узлах из [`k8s-install-all.yaml`](../../k8s-install-all.yaml), а также перед подключением worker или настройкой master отдельными playbook’ами.

## Задачи

- Дожидается завершения cloud-init и задаёт часовой пояс `Europe/Moscow`.
- Настраивает Kubernetes package repository и устанавливает элементы списка `packages` через `dnf`.
- Устанавливает Python-пакеты из `pip_modules`.
- Отключает SELinux и swap; удаляет записи swap из `/etc/fstab`.
- Загружает и сохраняет список `modules` в `/etc/modules-load.d/modules.conf`.
- Применяет `sysctl_params` и настраивает kubectl bash completion для пользователя `username`.
- Загружает containerd, systemd unit, `runc` и `crictl`; создаёт конфигурации runtime, registry mirror и, при необходимости, proxy.

Роль ориентирована на RPM-системы с `dnf` (например, Rocky Linux) и использует коллекции `community.general` и `ansible.posix`.

## Переменные

Основные значения определены в `defaults/main.yaml`; repository URL и URL `crictl` находятся в `vars/main.yaml`.

| Переменная | Значение по умолчанию | Назначение |
|---|---|---|
| `username` | `user` | Локальный пользователь и владелец kubectl completion. |
| `password` | `password` | Параметр по умолчанию; задачи роли сейчас не устанавливают пароль. Не используйте это значение как пароль. |
| `kubernetesVersion` | `'1.33'` | Ветка Kubernetes RPM repository. |
| `kubernetesSubversion` | `'2'` | Версия задаётся в defaults, но непосредственно задачами этой роли не используется. |
| `proxy_url` | `""` | Proxy для загрузки и установки пакетов. |
| `containerd_version` | `'2.3.3'` | Версия загружаемого containerd. |
| `runc_version` | `'1.3.2'` | Версия загружаемого `runc`. |
| `crictl_version` | `v1.36.0` | Версия загружаемого `crictl`. |
| `containerd_proxy_enabled` | `false` | Создавать ли systemd drop-in для proxy containerd. |
| `containerd_http_proxy`, `containerd_https_proxy` | `proxy_url` | HTTP/HTTPS proxy для containerd. |
| `containerd_no_proxy` | список локальных и кластерных сетей/доменов | Значение `NO_PROXY` для containerd. |
| `containerd_sandbox_image` | `registry.k8s.io/pause:3.10` | Sandbox/pause image в containerd config. |
| `dockerhubMirror` | `false` | Настраивать ли registry mirror для `docker.io`. |
| `dockerhubMirrorURLs` | список mirror URL | URL зеркал Docker Hub. |
| `packages` | список RPM-пакетов | Устанавливаемые системные и Kubernetes-пакеты. |
| `pip_modules` | `kubernetes`, `oauthlib>=3.2.0`, `requests-oauthlib` | Python-модули, устанавливаемые через `pip3`. |
| `modules` | список модулей ядра | Модули, загружаемые сейчас и при последующих загрузках. |
| `sysctl_params` | список ключей и значений | Системные параметры ядра для Kubernetes. |

Списки пакетов, модулей ядра и sysctl можно переопределить в inventory. В окружениях проекта версии и наборы пакетов задаются в `inventories/<environment>/group_vars/all.yaml`.

## Handlers

- `start iscsid` — включает и запускает `iscsid`.
- `restart kubelet` — включает и перезапускает kubelet.
- `restart containerd` — перечитывает systemd и включает/перезапускает containerd.

## Пример

```yaml
- hosts: all
  become: true
  roles:
    - role: k8s-common-config
      vars:
        username: cluster-admin
        kubernetesVersion: "1.35"
        dockerhubMirror: true
```
