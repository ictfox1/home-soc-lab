#!/bin/bash
echo "Запуск лаборатории home-soc-lab..."
VBoxManage startvm "soc-wazuh" --type headless
VBoxManage startvm "soc-ubuntu-web" --type headless
VBoxManage startvm "soc-suricata" --type headless
echo "Все Vm запущены. Можно подключаться по SSH."