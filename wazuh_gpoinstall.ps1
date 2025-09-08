Invoke-WebRequest -Uri https://packages.wazuh.com/4.x/windows/wazuh-agent-4.12.0-1.msi -OutFile $env:TMP\wazuh-agent.msi
msiexec.exe /i $env:TMP\wazuh-agent.msi /q WAZUH_MANAGER='192.168.130.249'
Start-Sleep -Seconds 10
NET START WazuhSvc
