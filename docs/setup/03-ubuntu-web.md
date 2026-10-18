# Этап 4. Развёртывание soc-ubuntu-web (Уязвимый веб-сервер)

## Задача
Создать целевую машину (жертву) для отработки веб-атак. Чтобы сэкономить дисковое пространство, ВМ создана через **Linked Clone** от `soc-wazuh`.

## Параметры ВМ

| Параметр | Значение |
| :--- | :--- |
| Имя ВМ | `soc-ubuntu-web` |
| IP (internal) | `10.10.10.40/24` |
| Hostname | `soc-ubuntu-web` |
| Стек | Apache, MySQL, PHP (LAMP) |
| Уязвимое ПО | DVWA |

## Действия

1. При помощи команды `./VBoxManage.exe clonevm "soc-wazuh" --name "soc-ubuntu-web" --optionы link --snapshot "Shot 1" --register` создаy связанный клон для экономии дискового пространства.
2. Сменены MAC-адреса адаптеров, чтобы избежать конфликтов `./VBoxManage modifyvm "soc-ubuntu-web" --macaddress1 auto --macaddress2 auto` и меняем порт прослушиваемый гипервизором на 2223.
3. Изменены настройки внутренний сети (10.10.10.40) и изменено имя хоста.
4. Установлены необходимые зависимости для развертки web-сервера `sudo apt install apache2 mysql-server php php-mysqli php-gd git -y`.
5. Скопирован репозиторий для установки уязвимого web-сервера `sudo git clone https://github.com/digininja/DVWA.git`
6. Настроена база данных MySQL для DVWA.


## Результат 

- Веб-сервер доступен с хоста по адресу `http://127.0.0.1:8080/DVWA`.
- Внутренний IP `10.10.10.40` доступен из сети `soclab`.