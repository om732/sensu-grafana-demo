# sensu-grafana-demo

## What is this?
sensuとGrafanaの連携デモです
Ansibleで環境構築します

## 前提
- Vagrantの利用を前提
- 各VMへの名前解決ができること(hostsに以下が設定されていること)以下、サンプル

```
192.168.33.21  client1
192.168.33.22  client2
192.168.33.20  monitor
```

## 実行
```bash
% git clone https://github.com/om732/sensu-grafana-demo.git
% cd sensu-grafana-demo
% vagrant up
% ansible-playbook --private-key .ssh/demo.key -i inventories/hosts sensu-server.yml
% ansible-playbook --private-key .ssh/demo.key -i inventories/hosts sensu-client.yml
```

## 確認
- uchiwa
    - http://192.168.33.20:3000/
- grafana
    - http://192.168.33.20/


## 構築環境
OSは全てCentOS6.5

- monitor
    - sensu-server
    - sensu-api
    - sensu-client
    - Redis
    - RabbitMQ
    - uchiwa
    - graphite
    - Grafana
    - ElasticSearch
- client1
    - sensu-client
- client2
    - java
    - Tomcat8
    - sensu-client

