# 🛡️ Home SOC Lab

![Status](https://img.shields.io/badge/status-completed-brightgreen?style=flat-square)
![Focus](https://img.shields.io/badge/focus-blue%20team-blue?style=flat-square)
![Role](https://img.shields.io/badge/target-SOC%20Analyst-green?style=flat-square)
![Stack](https://img.shields.io/badge/stack-Wazuh%20%7C%20Suricata%20%7C%20VirtualBox-orange?style=flat-square)
![License](https://img.shields.io/badge/license-MIT-lightgrey?style=flat-square)

> Домашняя лаборатория для отработки полного цикла работы SOC-аналитика:
> **атака → детект → расследование → документирование → рекомендации**.

---

## 📑 Содержание

- [🎯 Цель проекта](#-цель-проекта)
- [🏗️ Архитектура](#️-архитектура)
- [🧰 Используемый стек](#-используемый-стек)
- [🔄 Методология](#-методология)
- [📋 Прогресс проекта](#-прогресс-проекта)
- [📁 Структура репозитория](#-структура-репозитория)
- [🚨 Отчёты об инцидентах](#-отчёты-об-инцидентах)
- [🚀 Как воспроизвести](#-как-воспроизвести)
- [📚 Чему я научился](#-чему-я-научился)
- [👤 Автор](#-автор)
- [📄 Лицензия](#-лицензия)

---

## 🎯 Цель проекта

Построить изолированный стенд, имитирующий корпоративную сеть небольшой компании, и на нём отработать навыки, которые требуются от **SOC Analyst L1** и **Blue Team** специалиста:

- Централизованный сбор логов с гетерогенной инфраструктуры (Linux + Windows + AD)
- Написание и тюнинг правил корреляции в SIEM (включая кастомные правила)
- Детектирование сетевых атак через IDS
- Настройка автоматического реагирования (Active Response)
- Проведение расследований (triage, timeline, IOC extraction)
- Маппинг событий на **MITRE ATT&CK**
- Составление **Incident Report** по методологии **NIST SP 800-61**

Проект полностью воспроизводим: все конфиги, скрипты и настройки выложены в этом репозитории.

---

## 🏗️ Архитектура

```mermaid
flowchart TD
    subgraph HOST ["Хост (Windows 10/11) - VirtualBox"]
        SSH["SSH-клиент"]
    end

    subgraph NAT ["NAT Network (Интернет)"]
        NAT_IF1["Adapter 1"]
        NAT_IF2["Adapter 1"]
        NAT_IF3["Adapter 1"]
    end

    subgraph LAB ["Internal Network 'soclab' (10.10.10.0/24)"]
        direction TB
        Wazuh["<b>soc-wazuh</b><br>10.10.10.10<br>SIEM (Wazuh)"]
        Suricata["<b>soc-suricata</b><br>10.10.10.20<br>IDS (Suricata)"]
        Kali["<b>soc-kali</b><br>10.10.10.30<br>Атакующий (Kali)"]
        Web["<b>soc-ubuntu-web</b><br>10.10.10.40<br>Жертва (DVWA)"]
        DC["<b>soc-dc</b><br>10.10.10.50<br>Domain Controller"]
        Win10["<b>soc-win10</b><br>10.10.10.60<br>Рабочая станция"]
    end

    %% Подключения к NAT
    SSH -. "Проброс портов" .-> NAT_IF1
    SSH -. "Проброс портов" .-> NAT_IF2
    SSH -. "Проброс портов" .-> NAT_IF3
    
    NAT_IF1 --> Wazuh
    NAT_IF2 --> Suricata
    NAT_IF3 --> Kali

    %% Внутренние взаимодействия (Логика SOC)
    Wazuh <== "Сбор логов (Агенты)" ==> Suricata
    Wazuh <== "Сбор логов (Агенты)" ==> Web
    Wazuh <== "Сбор логов (Агенты)" ==> DC
    Wazuh <== "Сбор логов (Агенты)" ==> Win10

    Suricata -. "Анализ трафика<br>(Promiscuous Mode)" .-> LAB
    
    Kali == "Атаки (Nmap, Hydra)" ==> Web
    Kali == "Атаки" ==> Win10
    Kali == "Атаки" ==> DC

    classDef siem fill:#e1f5fe,stroke:#0288d1,stroke-width:2px;
    classDef ids fill:#fff3e0,stroke:#f57c00,stroke-width:2px;
    classDef victim fill:#ffebee,stroke:#c62828,stroke-width:2px;
    classDef attacker fill:#e8f5e9,stroke:#2e7d32,stroke-width:2px;
    classDef win fill:#f3e5f5,stroke:#6a1b9a,stroke-width:2px;

    class Wazuh siem;
    class Suricata ids;
    class Web victim;
    class Kali attacker;
    class DC,Win10 win;
```

**Компоненты стенда:**

| # | ВМ | Роль | ОС |
|---|----|------|-----|
| 1 | `soc-wazuh` | SIEM: сбор, корреляция, алертинг | Ubuntu Server 22.04 |
| 2 | `soc-suricata` | IDS: анализ сетевого трафика | Ubuntu Server 22.04 |
| 3 | `soc-kali` | Атакующий | Kali Linux |
| 4 | `soc-ubuntu-web` | Жертва: веб-сервер с DVWA | Ubuntu Server 22.04 |
| 5 | `soc-dc` | Domain Controller + AD | Windows Server 2022 |
| 6 | `soc-win10` | Рабочая станция в домене | Windows 10 |

Все ВМ находятся в изолированной сети **`10.10.10.0/24`** и не имеют доступа в интернет (кроме управления через NAT).

---

## 🧰 Используемый стек

| Компонент | Технология | Назначение |
|-----------|-----------|------------|
| Гипервизор | **VirtualBox** | Хостинг виртуальных машин |
| SIEM | **Wazuh** | Сбор логов, корреляция, алертинг, FIM, Active Response |
| IDS | **Suricata** | Сигнатурный анализ трафика |
| Атакующий | **Kali Linux** | Симуляция атак (Nmap, Hydra, Metasploit, Burp) |
| Целевые ОС | **Ubuntu Server, Windows Server 2022, Windows 10** | Имитация реальной инфраструктуры |
| Инструменты Windows | **Sysmon, Advanced Audit Policy** | Глубокое логирование процессов и событий |
| Уязвимое приложение | **DVWA** | Тренировка веб-атак |
| Маппинг | **MITRE ATT&CK** | Классификация техник атакующих |
| Методология | **NIST SP 800-61** | Оформление расследований |

---

## 🔄 Методология

Каждый этап проекта документируется по единой схеме:

1. **Задача** — что нужно сделать
2. **Действия** — как именно я это делал (с командами)
3. **Результат** — что получилось, скриншоты
4. **Выводы** — что я узнал, какие были проблемы

Отчёты об инцидентах оформляются по фазам **NIST SP 800-61**:

```text
Detection → Analysis → Containment → Eradication → Recovery → Lessons Learned
```

Каждый инцидент маппится на технику из **MITRE ATT&CK** с указанием ID.

---

## 📋 Прогресс проекта

- [x] Этап 0: Определение цели и требований
- [x] Этап 1: Планирование архитектуры и создание репозитория
- [x] Этап 2: Установка и настройка гипервизора
- [x] Этап 3: Настройка изолированной сети
- [x] Этап 4: Развёртывание целевых машин (Ubuntu Web)
- [x] Этап 5: Установка и настройка Wazuh SIEM
- [x] Этап 6: Установка и настройка Suricata IDS
- [x] Этап 7: Интеграция Suricata и Wazuh
- [x] Этап 8: Развёртывание Windows-инфраструктуры (DC, Win10)
- [x] Этап 9: Настройка Sysmon и продвинутого аудита
- [x] Этап 10: Развёртывание Kali Linux и симуляция атак
- [x] Этап 11: Расследование инцидентов, тюнинг правил и финализация

---

## 📁 Структура репозитория

```text
home-soc-lab/
├── README.md
├── LICENSE
├── .gitignore
├── docs/
│   ├── setup/                   # Инструкции по развёртыванию
│   │   ├── 01-hypervisor.md
│   │   ├── 02-wazuh-vm-setup.md
│   │   ├── 03-ubuntu-web.md
│   │   ├── 04-wazuh-installation.md
│   │   ├── 05-suricata-ids.md
│   │   ├── 06-wazuh-suricata-integration.md
│   │   ├── 07-windows-dc.md
│   │   ├── 08-windows-client.md
|   |   ├── 09-ad-users-and-audit.md
|   |   ├── 10-wazuh-hardening.md
|   |   ├── 11-ubuntu-web-monitoring.md
│   │   └── 12-kali-attacker.md
│   └── incidents/               # Отчёты об инцидентах
│       ├── INC-001-ssh-bruteforce.md
│       ├── INC-002-web-sqli-scan.md
│       └── INC-003-win10-suspicious-activity.md
├── scripts/                     # Скрипты автоматизации
└── screenshots/                 # Скриншоты дашбордов и результатов
```

---

## 🚨 Отчёты об инцидентах

| ID | Инцидент | Техника MITRE ATT&CK | Отчёт |
|----|----------|----------------------|-------|
| **INC-001** | SSH Brute Force (Hydra) и Active Response | `T1110.001` (Brute Force) | [Открыть](docs/incidents/INC-001-ssh-bruteforce.md) |
| **INC-002** | SQL-инъекция и сетевое сканирование | `T1190`, `T1595` | [Открыть](docs/incidents/INC-002-web-sqli-scan.md) |
| **INC-003** | Поведение Ransomware (vssadmin) и триаж False Positive | `T1490`, `T1059` | [Открыть](docs/incidents/INC-003-win10-suspicious-activity.md) |

---

## 🚀 Как воспроизвести

Для воспроизведения лаборатории необходимо выполнить следующие шаги (детали в папке `docs/setup/`):

1. Установить VirtualBox и создать изолированную сеть `soclab` (Internal Network).
2. Развернуть `soc-wazuh` (Ubuntu Server) и установить Wazuh SIEM (All-in-One).
3. Развернуть `soc-ubuntu-web` (клон) и установить LAMP + уязвимое приложение DVWA.
4. Развернуть `soc-suricata` (клон) и настроить IDS в режиме Promiscuous Mode, подключить к Wazuh.
5. Развернуть Windows Server (`soc-dc`), поднять AD, установить Sysmon и Wazuh Agent.
6. Развернуть Windows 10 (`soc-win10`), ввести в домен, установить Sysmon и Wazuh Agent.
7. Развернуть Kali Linux (`soc-kali`) и провести симуляцию атак согласно отчетам об инцидентах.
8. Настроить кастомные правила и Active Response в Wazuh для защиты инфраструктуры.

---

## 📚 Чему я научился

В ходе работы над проектом я получил следующие практические навыки:

- **Развёртывание и архитектура:** Спроектировал изолированную сеть в VirtualBox, настроил NAT и Internal Network, проброс портов.
- **SIEM (Wazuh):** Установил Wazuh All-in-One, настроил сбор логов (JSON, EventChannel), разобрался с модулями SCA и FIM (`who-data`).
- **IDS (Suricata):** Настроил Suricata в режиме Promiscuous Mode, обновил и сконфигурировал правила (Emerging Threats), настроил интеграцию с Wazuh через парсинг `eve.json`.
- **Windows Security:** Настроил Advanced Audit Policy, Event ID 4688, установил и сконфигурировал Sysmon (SwiftOnSecurity).
- **Кастомные правила (Rule Tuning):** Научился писать собственные правила корреляции в Wazuh (например, для детекта удаления теневых копий `vssadmin`).
- **Active Response:** Настроил автоматическую блокировку IP-адресов через `iptables` при детекте SSH-брутфорса.
- **Incident Response:** Отработал триаж ложных срабатываний (False Positives) и оформление отчетов по методологии NIST SP 800-61 с маппингом на MITRE ATT&CK.

---

## 👤 Автор

**Андрей** — начинающий специалист в области ИБ, цель: **SOC Analyst / Blue Team**

- 🐙 GitHub: [@ictfoxi](https://github.com/ictfoxi)
- 💼 Целевая роль: SOC Analyst L1
- 📍 Открыт к предложениям и стажировкам

---

## 📄 Лицензия

Проект распространяется под лицензией **MIT** — см. файл [LICENSE](LICENSE).