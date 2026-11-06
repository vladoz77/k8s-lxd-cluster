# Роль `k8s-join-worker`

Подключает worker-узлы к уже инициализированному кластеру с помощью `kubeadm join`. Вызывается после [`k8s-common-config`](../k8s-common-config/Readme.md), который устанавливает containerd и `kubeadm`.

## Последовательность работы

1. Проверяет настройки интерфейса, первого master и HA endpoint, а также наличие сетевых facts.
2. Проверяет готовность API endpoint по HTTPS `readyz`.
3. Если на узле нет `/etc/kubernetes/kubelet.conf`, получает bootstrap token (TTL 15 минут) и CA cert hash с `k8s_first_master`.
4. Рендерит временный kubeadm join config в `/root`, выполняет `kubeadm join` и удаляет конфиг с токеном независимо от результата.

Уже присоединённый worker пропускает шаги `kubeadm join`. Для API endpoint используется VIP при `ha_enabled: true`, иначе IPv4-адрес первого master и порт 6443.

## Переменные и требования

У этой роли нет собственного `defaults/main.yaml`. Она использует переменные inventory/group vars:

| Переменная | Назначение |
|---|---|
| `interface_name` | Интерфейс worker и master, на котором должны быть доступны IPv4 facts. |
| `k8s_first_master` | Имя первого control-plane узла в inventory. |
| `ha_enabled` | Выбор API endpoint. |
| `vip_address`, `vip_port` | Обязательны при `ha_enabled: true`. |
| `api_endpoint_host`, `api_endpoint_port` | Адрес и порт API endpoint; в проекте вычисляются в [`group_vars/all.yaml`](../../group_vars/all.yaml). |

Требуются `community.general`, `ansible.posix` и `kubernetes.core` согласно [`requirements.yaml`](../../requirements.yaml), доступ по SSH/Ansible ко всем нужным узлам, а также доступность API server с worker.

## Пример

```yaml
- hosts: worker
  become: true
  roles:
    - role: k8s-common-config
    - role: k8s-join-worker
```
