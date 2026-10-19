# Этап 5. Установка Suricata IDS на soc-suricata

## Задача
Развернуть систему обнаружения вторжений (IDS) Suricata на отдельной ВМ `soc-suricata` для мониторинга сетевого трафика в изолированной сети `soclab`.

## Параметры ВМ

| Параметр | Значение |
| :--- | :--- |
| Имя ВМ | `soc-suricata` |
| IP (internal) | `10.10.10.20/24` |
| Promiscuous Mode | Allow All (на Adapter 2) |
| Интерфейс мониторинга | `enp0s8` |


## Действия

1. Создан Linked Clone от `soc-wazuh` (снимок `Shot 1`).
2. Настроен **Promiscuous Mode: Allow All** на внутреннем адаптере, чтобы Suricata видела трафик между другими ВМ (а не только свой).
3. Установлен пакет `suricata` (`sudo apt install suricata -y`).
4. В `/etc/suricata/suricata.yaml` изменены параметры:
   - `HOME_NET: "[10.10.10.0/24]"`
   - `af-packet -> interface: enp0s8`
5. Обновлены правила (`sudo suricata-update`), сервис перезапущен.
6. Проверена генерация событий в `/var/log/suricata/eve.json` при ICMP-запросе с `soc-ubuntu-web`.

## Результат
- Suricata успешно развёрнута и слушает внутренний интерфейс.
- Трафик фиксируется в формате JSON (`eve.json`), готов к интеграции с Wazuh.