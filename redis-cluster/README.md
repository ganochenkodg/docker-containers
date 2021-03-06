# redis-cluster

## Логи
| file                              | description    |
|:----------------------------------|:---------------|
| /var/log/container/redis_6379.log | Основной лог   |
| /var/log/container/keepalived.log | Лог Keepalived |

## privileged mode

Контейнер необходимо запускать в privileged режиме и с --net=host, для возможности назначения динамического ip на сетевой интерфейс.

## Переменные окружения

### redis

| Имя переменной | Описание                                                     |
|:---------------|:-------------------------------------------------------------|
| BIND_ADDRESS   | Адрес, на котором биндить порт. Не стоит указывать публичный |
| BIND_PORT      | Используемый порт, по умолчанию 6379                         |
| REDIS_PASS     | Пароль доступа к редису, по дефолту password                 |
| ISSLAVE        | Является ли данная нода репликой, по дефолту no              |


### keepalive

| Имя переменной       | Описание                                                   |
|:---------------------|:-----------------------------------------------------------|
| NODE_NAME            | Имя текущей ноды, должно быть уникальным                   |
| OTHER_NODE_NAME      | Сетевое имя второй ноды, нужно для связи по протоколу vrrp |
| KEEPALIVED_INTERFACE | Интерфейс для плавающего ip, по дефолту eth0               |
| FLOAT_IP             | Адрес, назначаемый мастеру кластера                        |
