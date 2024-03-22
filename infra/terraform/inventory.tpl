[master]
%{ for ip in master-external-ip ~}
${ip}
%{ endfor ~}

[gitlab]
%{ for ip in gitlab-external-ip ~}
${ip}
%{ endfor ~}