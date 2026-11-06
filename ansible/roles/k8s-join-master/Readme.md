# Роль `k8s-join-master`

Подключает дополнительный узел управления к уже инициализированному Kubernetes HA-кластеру. В [`k8s-install-all.yaml`](../../k8s-install-all.yaml) запускается последовательно для master-узлов, отличных от `k8s_first_master`, только при `ha_enabled: true`.

## Последовательность работы

1. Проверяет HA-переменные, адрес интерфейса и доступность endpoint.
2. Пропускает узел, если уже существует `/etc/kubernetes/manifests/kube-apiserver.yaml`.
3. На первом master создаёт bootstrap token со сроком действия 30 минут, получает CA hash и загружает control-plane certificates.
4. На присоединяемом узле создаёт временный kubeadm config с режимом `JoinConfiguration` и `controlPlane`, запускает `kubeadm join`, затем удаляет config с секретами.
5. Копирует admin kubeconfig в домашний `.kube` каталог пользователя.

Роль требует, чтобы первый master уже был инициализирован, API endpoint/VIP был настроен, а контейнерный runtime и `kubeadm` были установлены.

## Переменные

| Переменная | Источник/значение | Назначение |
|---|---|---|
| `ha_enabled` | `defaults/main.yaml`, `false` | Включает присоединение дополнительного control-plane узла. |
| `vip_address`, `vip_port` | defaults/inventory | HA API endpoint. |
| `interface_name` | inventory | Интерфейс master с IPv4. |
| `k8s_first_master` | [`group_vars/all.yaml`](../../group_vars/all.yaml) | Узел, на котором создаются token и certificate key. |
| `api_endpoint_host`, `api_endpoint_port` | [`group_vars/all.yaml`](../../group_vars/all.yaml) | Адрес и порт endpoint, передаваемые kubeadm. |
| `base_kube_conf_dir` | `/etc/kubernetes/admin.conf` | Исходный kubeconfig на master. |
| `home_kube_dir` | `/home/{{ username }}/.kube` | Каталог kubeconfig пользователя на присоединяемом узле. |

## Пример

```yaml
- hosts: master
  become: true
  serial: 1
  roles:
    - role: k8s-join-master
      when:
        - ha_enabled | bool
        - inventory_hostname != k8s_first_master
```

Bootstrap token и certificate key используются для присоединения control plane. Роль скрывает их в выводе Ansible и удаляет временный файл join-конфигурации после выполнения.
