# README #



## Проектная работа:
## Создание процесса непрерывной поставки для приложения с применением Практик CI/CD и быстрой обратной связью ##

### Требования ###
* Автоматизированные процессы создания и управления платформой
* Ресурсы Ya.cloud
* Инфраструктура для CI/CD
* Инфраструктура для сбора обратной связи
* Использование практики IaC (Infrastructure as Code) для управления
конфигурацией и инфраструктурой
* Настроен процесс CI/CD
* Все, что имеет отношение к проекту хранится в Git

### Дано: 
* Микросервисное приложение
* База данных
* Менеджер очередей сообщений
* Пример сайта для парсинга
#### Структура сервиса ####
![image](https://github.com/skorospelovas/Otus_DevOps_final_project/assets/106163438/eb823e46-e74a-42df-9b43-a87908fc95f4)


#### Структура разработанной инфраструктуры ####
![image](https://github.com/skorospelovas/Otus_DevOps_final_project/assets/106163438/6fce16cc-ccb1-41ca-9cbf-5858a95076f9)




## Установка ##
### Используемые локальные инструменты

Рабочая станция с OS – linux Mint 21.3
С установленными:

* Yandex CLI
* Packer
* Terraform
* Ansible
* Kubectl
* HELM

### Используемые внешние ресурсы

* Yandex Cloud
* Домен project.space с прописанными серверами имен ns1.yandexcloud.net. и ns2.yandexcloud.net.

### Предварительная подготовка рабочего места

Необходимо иметь аккаунт на Yandex Cloud https://console.cloud.yandex.ru/

Для доступа к созываемым ресурсам сгенерировать пару ключей

## 
    ssh-keygen -t rsa -f ~/.ssh/id_rsa -C ubuntu -P ""

Создать профиль для  Yandex  CLI https://cloud.yandex.ru/docs/cli/operations/profile/profile-create
Создать сервисный аккаунт в Yandex.Cloud

##
    $ yc config list - Получить Folder-id
    $ SVC_ACCT="прописать свое имя"
    $ FOLDER_ID="вписать полученный Folder-id" 
 
Создать аккаунт и назначить права:

##
    $ yc iam service-account create --name $SVC_ACCT --folder-id $FOLDER_ID
    $ ACCT_ID=$(yc iam service-account get $SVC_ACCT | \
    grep ^id | \
    awk '{print $2}') 

 ##
    $ yc resource-manager folder add-access-binding --id $FOLDER_ID \
    --role editor \ 
    --service-account-id $ACCT_

Создать IAM key и экспортировать его в файл

##
    yc iam key create --service-account-id $ACCT_ID --output «путь к файлу»/key.json
    git clone https://github.com/skorospelovas/Otus_DevOps_final_project.git
    cd Otus_DevOps_final_project/infra

Подготовить образ для MongoDB сервера:
Переименовать файл infra/packer/variables.json.example в variables.json и вставить свои значения

Выполнить сборку:
##
    packer build -var-file packer/variables.json packer/mongodb.json

Получить id созданного образа:
##
    yc compute image list

Переименовать файл infra/terraform/ terraform.tfvars.example в variables.json и вставить свои значения
Перейти и выполнить
##
    cd terraform
    terraform init
    terraform apply

Так как мы обходимся без резервирования статических ip адресов, после запуска выполнения необхоидмо в Yandex Cloud, посмотреть ip адрес созданной A записи gitlab.project.space и
на локальной машине в файл /etc/hosts добавить запись вида:
##
    <ip адрес> gitlab.project.space

Terraform произведет установку:
* VM для  MongoDB на базе созданного образа без публичного IP
* VM для  Gitlab 
* Managed Service for Kubernetes с тремя нодами
* Создаст 3 диска в YC для кластера ElasticSearch
* Создаст файл переменных для Ansible
* Передаст управление Ansible

Ansible создаст:
* Сервер Gitlab с адресом https://gitlab.project.space 
* В K8s создаст 3 PersistentVolume для ElasticSearch

После того как закончит работу Ansible, найти в экране вывода пароль root, скопировать.

Перейти по адресу https://gitlab.project.space, залогинится.

Создать два проекта crawler и ui

В каждом из проектов 
* Создать переменные СI_REGISTRY_USER CI_REGISTRY_PASSWORD с реквизитами от DockerHub (Settings/CI/CD)
* Получить токены регистрации gitlab-runner 

Добавить репозитарий Helm:
##
    helm repo add bitnami https://charts.bitnami.com/bitnami

Выполнить с добавлением токенов:
##
    helm install --namespace gitlab gitlab-runner-ui \
    --set gitlabUrl=https://gitlab.project.space/ \
    --set runnerRegistrationToken="..." \
    --set runners.privileged=true \
     gitlab/gitlab-runner

##
    helm install --namespace gitlab gitlab-runner-crawler \
    --set gitlabUrl=https://gitlab.project.space/ \
    --set runnerRegistrationToken="..." \
    --set runners.privileged=true \
     gitlab/gitlab-runner

Добавить права раннеру
##
    kubectl create clusterrolebinding gitlab-cluster-admin \
    --clusterrole=cluster-admin \
    --serviceaccount=gitlab:default

### Установка микросервисов

Выполнить установку ingress-ngnix
##
    kubectl apply -f https://raw.githubusercontent.com/kubernetes/ingress-nginx/controller-v0.34.1/deploy/static/provider/cloud/deploy.yaml

Посмотреть IP LoadBalancer:
##
    kubectl get svc -n ingress-nginx

Через веб интерфейс YC создать А DNS записи поддоменов app, staging, prometheus,  grafana, zipkin , kibana  домен project.space на внешний IP LoadBalancer.

Установить RabbitMQ
##
    export RABBITMQ_PASSWORD=crawler_pass
##
    helm install rabbitmq \
    --set auth.password=$RABBITMQ_PASSWORD \
    bitnami/rabbitmq \
    --namespace production

Перейти в папку 
OTUS_DevOps_final_project/microservices

Выполнить:
##
    kubectl apply -f app -n production
    kubectl apply -f tracing -n production
    kubectl apply -f logging -n logging
    kubectl apply -f monitoring -n monitoring
    helm repo add bitnami https://charts.bitnami.com/bitnami

Через пару минут можно проверить работу:

http://app.project.space
http://prometheus.project.space
http://grafana.project.space
http://zipkin.project.space
http://kibana.project.space

В Kibana настроить Data View по индексу  filebeat-*
В Grafana установить пароль, и сменить у подключённого DataSourse Prometheus HttpMethod на POST

### CI/CD
В папках src/ui и src/crawler выполнить 
##
    git init
    git remote add origin https://gitlab.project.space/root/ui
    git remote add origin https://gitlab.project.space/root/crawler

Сделать коммит в репозитарии, запустится пайплайн со сборкой, тестом, деплоем на staging (по адресу http://staging.project.space ) и ручным деплоем на production (http://app.project.space )
