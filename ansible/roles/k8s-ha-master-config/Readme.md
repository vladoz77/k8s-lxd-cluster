# Роль `k8s-ha-master-config`

Устанавливает и настраивает HAProxy как TCP load balancer для Kubernetes API server и Keepalived для VRRP/VIP failover между control-plane узлами. В проектных playbook’ах роль запускается только при `ha_enabled: true`.

## Как работает

- Устанавливает пакеты `haproxy` и `keepalived`.
- Создаёт конфигурации из `haproxy.cfg.j2` и `keepalived.conf.j2`.
- HAProxy принимает соединения на `vip_port` и распределяет их между всеми узлами группы `master` на TCP/6443.
- Keepalived назначает VIP на `interface_name`; первый узел группы `master` получает роль `MASTER`, остальные — `BACKUP`.
- Handler’ы перезапускают и включают соответствующие systemd-сервисы при создании конфигураций.

Шаблоны используют собранные Ansible facts по сетевому интерфейсу; перед применением на всех master должны быть доступны корректные facts и адреса интерфейсов. VRRP-протокол должен быть разрешён сетевой инфраструктурой.

## Переменные

| Переменная | Значение по умолчанию | Назначение |
|---|---|---|
| `ha_enabled` | `false` | В проектных playbook’ах включает вызов роли при значении `true`. |
| `vip_address` | `192.168.1.222` | Виртуальный IPv4-адрес. Шаблон Keepalived сейчас добавляет к нему маску `/24`. |
| `vip_port` | `8443` | Порт frontend HAProxy для Kubernetes API. |
| `interface_name` | `enp5s0` | Сетевой интерфейс для Keepalived VRRP. |
| `ha_packages` | `[haproxy, keepalived]` | Пакеты, устанавливаемые через yum. |
| `haproxy_config_tempate` | `haproxy.cfg.j2` | Имя шаблона HAProxy (переменная в коде содержит это написание). |
| `haproxy_config_dir` | `/etc/haproxy/haproxy.cfg` | Путь конфигурации HAProxy. |
| `keepalived_config_template` | `keepalived.conf.j2` | Шаблон конфигурации Keepalived. |
| `keepalived_config_dir` | `/etc/keepalived/keepalived.conf` | Путь конфигурации Keepalived. |

## Важное поведение текущих задач

Установка пакетов и создание конфигураций зависят от отсутствия файлов конфигурации: существующие файлы роль не перезаписывает. Проверьте этот факт перед повторным запуском после изменения переменных; не полагайтесь на роль как на средство обновления уже созданных конфигураций.

## Пример

```yaml
- hosts: master
  become: true
  roles:
    - role: k8s-ha-master-config
      when: ha_enabled | bool
```
