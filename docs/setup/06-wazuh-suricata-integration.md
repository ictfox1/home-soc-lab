# Этап 7. Интеграция Suricata IDS и Wazuh SIEM

## Задача
Настроить централизованный сбор алертов от системы обнаружения вторжений Suricata в SIEM Wazuh.

## Действия

1. Обновлены и загружены правила Suricata (Emerging Threats). 
2. Успешно загружено более 52 000 правил.
3. На ВМ `soc-suricata` установлен Wazuh Agent.
4. В конфигурационный файл агента `/var/ossec/etc/ossec.conf` добавлен блок для мониторинга JSON-логов Suricata:
   ```xml
   <localfile>
     <log_format>json</log_format>
     <location>/var/log/suricata/eve.json</location>
   </localfile>
5. В файле `/etc/suricata/suricata.yaml` был указан параметр `EXTERNAL_NET: "any"` для корректного срабатывания правил в изолированной сети.
6. Был сделан скриншот работы wazuh по `eve.json` при помощи тестового правиал, которые помечало алертом весь HTTP трафик. В итоговой версии правило убрано.