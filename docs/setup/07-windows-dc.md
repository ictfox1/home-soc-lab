# Этап 8. Развёртывание Windows Server 2022 и Active Directory

## Задача
Развернуть контроллер домена (Domain Controller) для имитации корпоративной инфраструктуры и подключить его к Wazuh.

## Параметры ВМ
| Параметр | Значение |
| :--- | :--- |
| Имя ВМ | `soc-dc` |
| IP (internal) | `10.10.10.50/24` |
| Домен | `soclab.local` |
| ОС | Windows Server 2022 Standard (Desktop Experience) |

## Действия
1. Установлен Windows Server 2022 (Desktop Experience).
2. Настроен статический IP `10.10.10.50` и DNS `127.0.0.1`.
3. Установлена роль **Active Directory Domain Services (AD DS)** и **DNS Server**.
4. Сервер повышен до контроллера домена `soclab.local` (новый лес).
5. Установлен Wazuh Agent (версия для Windows).

## Результат
- Создан домен `soclab.local`.
- Контроллер домена `soc-dc` успешно подключен к SIEM Wazuh.
- Готово к созданию пользователей и добавлению клиентских машин.