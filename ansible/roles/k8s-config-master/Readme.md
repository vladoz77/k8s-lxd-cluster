# Роль `k8s-config-master`

Инициализирует первый Kubernetes control-plane узел командой `kubeadm init`, устанавливает выбранный CNI и, при необходимости, Calico CLI или NodeLocalDNS. Роль выполняется только на `k8s_first_master` из [`k8s-install-all.yaml`](../../k8s-install-all.yaml).

## Последовательность работы

1. Проверяет обязательные переменные, сетевой интерфейс, CIDR и настройки CNI/HA.
2. Проверяет наличие манифеста API server и пропускает повторный `kubeadm init`, если узел уже инициализирован.
3. Формирует kubeadm config и инициализирует control plane.
4. Сохраняет лог инициализации локально в `local_kubeconfig_dir`, создаёт kubeconfig для `username`.
5. Дожидается готовности API endpoint.
6. На первом master устанавливает Calico либо Cilium, а также опциональные Calicoctl и NodeLocalDNS.

Поддерживаемые значения `cni_plugin`: `calico`, `cilium` и `none`. Для Cilium роль пропускает установку kube-proxy; для Calico это происходит, если включён `calico_ebpf_enabled`.

## Основные переменные

Настройки определены в `defaults/main.yaml`, вспомогательные URL и имена шаблонов — в `vars/main.yaml`.

| Переменная | По умолчанию | Назначение |
|---|---|---|
| `kube_domain_name` | `cluster.local` | DNS-домен Kubernetes. |
| `ha_enabled` | `false` | Использовать HA API endpoint и HA-конфигурацию. |
| `vip_address`, `vip_port` | `192.168.1.222`, `8443` | Виртуальный endpoint API при HA. |
| `podSubnet`, `serviceSubnet` | `10.244.0.0/16`, `10.243.0.0/16` | CIDR Pod и Service сетей. |
| `interface_name` | задаётся inventory | Интерфейс с IPv4-адресом узла; обязателен для этой роли. |
| `cni_plugin` | `calico` | CNI: `calico`, `cilium` или `none`. |
| `calico_version` | `v3.29.2` | Версия Calico. |
| `calico_ebpf_enabled` | `false` | eBPF dataplane Calico; отключает kube-proxy. |
| `calico_encapsulation_type` | `NONE` | Инкапсуляция Calico: `NONE`, `IPIP` или `VXLAN`. |
| `calicoctl_enabled` | `true` | Устанавливать ли `calicoctl` при использовании Calico. |
| `calicoctl_version` | `v3.22.2` | Версия `calicoctl`. |
| `calicoctl_intsall_path` | `/usr/local/bin/calicoctl` | Путь установки `calicoctl` (имя переменной в defaults написано именно так). |
| `cilium_version` | `1.18.0` | Версия Helm chart Cilium. |
| `cilium_namespace` | `cilium-system` | Namespace релиза Cilium. |
| `cilium_operator_replicas` | `2` | Количество Cilium operator replicas. |
| `cilium_gateway_api_enabled` | `true` | Устанавливать Gateway API CRD для Cilium. |
| `cilium_l2_enabled` | `true` | Настраивать Cilium L2 announcements и LB IP pool. |
| `cilium_lb_pool_start`, `cilium_lb_pool_stop` | `172.10.10.200`, `172.10.10.250` | Границы диапазона адресов LoadBalancer. |
| `gateway_api_version` | `v1.3.0` | Версия Gateway API CRD. |
| `helm_version` | `v3.17.0` | Версия устанавливаемого Helm. |
| `nodelocaldns` | `false` | Устанавливать NodeLocalDNS. |
| `nodelocaldns_address` | `169.254.20.10` | Адрес локального DNS cache. |
| `nodelocaldns_image` | `registry.k8s.io/dns/k8s-dns-node-cache:1.23.1` | Образ NodeLocalDNS. |
| `system_reserved`, `system_memory`, `system_cpu`, `system_ephemeral_storage` | `true`, `512Mi`, `500m`, `5Gi` | Настройки резерва ресурсов kubelet. |
| `container_log_max_size`, `container_log_max_file` | `1Mi`, `3` | Ограничения размера и количества container log files. |
| `base_kube_conf_dir` | `/etc/kubernetes/admin.conf` | kubeconfig администратора на master. |
| `home_kube_dir` | `/home/{{ username }}/.kube` | kubeconfig-каталог пользователя на узле. |
| `local_kubeconfig_dir` | `kubeconfig` | Каталог на Ansible controller для локального kubeconfig и логов init. |

Endpoint переменные `api_endpoint_host`, `api_endpoint_port` и `k8s_first_master` вычисляются в [`group_vars/all.yaml`](../../group_vars/all.yaml) с учётом инвентаря и `ha_enabled`.

## Пример

```yaml
- hosts: master
  become: true
  roles:
    - role: k8s-config-master
```

Перед запуском включите `k8s-common-config` и обеспечьте доступность LXD-узла по заданному интерфейсу. В режиме HA сначала установите HAProxy/Keepalived на master-узлах, чтобы заданный API endpoint стал доступен.
