# Этап 8.1. Подготовка контроллера домена (AD, Audit, Sysmon)

## Задача
Настроить контроллер домена для генерации максимального количества данных для SOC (включая Event ID 4688 и логи Sysmon). Создать тестовые учетные записи для симуляции атак.

## Действия

### 1. Создание пользователей
Созданы учетные записи с разными привилегиями для имитации атак:
- `jdoe`, `asmith`, `bjohnson` — обычные пользователи (слабые пароли, цель для Password Spraying).
- `svc_sql` — сервисная учетная запись с зарегистрированным SPN (цель для Kerberoasting).
- `da_admin` — член группы Domain Admins (цель для Privilege Escalation).

### 2. Настройка Advanced Audit Policy
Через `Default Domain Policy` включены:
- `Audit Process Creation` (Success, Failure).
- `Audit Logon` (Success, Failure).
- Изменен реестр `ProcessCreationIncludeCmdLine_Enabled = 1` для записи полных командных строк в Event ID 4688.

### 3. Установка Sysmon
Установлен Sysmon64 с конфигурацией SwiftOnSecurity для расширенного мониторинга (создание процессов с хэшами, сетевые соединения, изменения реестра).
Wazuh Agent настроен на сбор логов из канала `Microsoft-Windows-Sysmon/Operational`.

## Результат
- Контроллер домена готов к симуляции атак.
- Wazuh получает расширенные логи Sysmon и полные командные строки процессов.