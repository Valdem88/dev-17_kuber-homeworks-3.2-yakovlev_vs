# Домашнее задание к занятию "Установка Kubernetes" dev-17_kuber-homeworks-3.2-yakovlev_vs
Установка Kubernetes


### Цель задания

Установить кластер K8s.

### Чеклист готовности к домашнему заданию

1. Развернутые ВМ с ОС Ubuntu 20.04-lts


### Инструменты и дополнительные материалы, которые пригодятся для выполнения задания

1. [Инструкция по установке kubeadm](https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/)
2. [Документация kubespray](https://kubespray.io/)

-----

### Задание 1. Установить кластер k8s с 1 master node

1. Подготовка работы кластера из 5 нод: 1 мастер и 4 рабочие ноды.
2. В качестве CRI — containerd.
3. Запуск etcd производить на мастере.
4. Способ установки выбрать самостоятельно.

### Решение

Создаем в yc скриптом необходимое количество виртуальных машин

```bash
$ yc vpc network create  --name net --labels my-label=netology --description "net yc"
id: enpvv1300q4m9eph957v
folder_id: b1g72hofn0r6eom3l3oo
created_at: "2023-04-19T09:34:32Z"
name: net
description: net yc
labels:
  my-label: netology

$ yc vpc subnet create  --name my-subnet --zone ru-central1-c --range 10.1.2.0/24 --network-name net --description "subnet yc"
id: b0c6muq7q1godpb243mu
folder_id: b1g72hofn0r6eom3l3oo
created_at: "2023-04-19T09:34:46Z"
name: my-subnet
description: subnet yc
network_id: enpvv1300q4m9eph957v
zone_id: ru-central1-c
v4_cidr_blocks:
  - 10.1.2.0/24  
$ sh vms_yc/create-vms.sh 
done (35s)
id: ef38qtie2og7aggs7s54
folder_id: b1g72hofn0r6eom3l3oo
created_at: "2023-04-19T10:08:25Z"
name: masterk8s
zone_id: ru-central1-c
platform_id: standard-v2
resources:
  memory: "2147483648"
  cores: "2"
  core_fraction: "100"
status: RUNNING
metadata_options:
  gce_http_endpoint: ENABLED
  aws_v1_http_endpoint: ENABLED
  gce_http_token: ENABLED
  aws_v1_http_token: DISABLED
boot_disk:
  mode: READ_WRITE
  device_name: ef3l93fbj9p42bn0vfc1
  auto_delete: true
  disk_id: ef3l93fbj9p42bn0vfc1
network_interfaces:
  - index: "0"
    mac_address: d0:0d:8d:76:4e:16
    subnet_id: b0c6muq7q1godpb243mu
    primary_v4_address:
      address: 10.1.2.15
........................................... 
```
![](pic/YCvm.jpg)

Скачиваем kubespray из репозитория
```bash
root@masterk8s:~# git clone https://github.com/kubernetes-sigs/kubespray
Cloning into 'kubespray'...
remote: Enumerating objects: 67498, done.
remote: Counting objects: 100% (222/222), done.
remote: Compressing objects: 100% (124/124), done.
remote: Total 67498 (delta 86), reused 197 (delta 80), pack-reused 67276
Receiving objects: 100% (67498/67498), 21.17 MiB | 16.67 MiB/s, done.
Resolving deltas: 100% (37986/37986), done.
root@masterk8s:~# ls -la
total 28
drwx------  5 root root 4096 Apr 19 10:19 .
drwxr-xr-x 18 root root 4096 Apr 19 10:09 ..
-rw-r--r--  1 root root 3106 Dec  5  2019 .bashrc
drwx------  2 root root 4096 Dec 14 10:02 .cache
drwxr-xr-x 17 root root 4096 Apr 19 10:19 kubespray
-rw-r--r--  1 root root  161 Dec  5  2019 .profile
drwx------  2 root root 4096 Apr 19 10:09 .ssh
```
Установка зависимостей
```bash
root@masterk8s:~/kubespray# pip3 install -r requirements.txt
Collecting ansible==5.7.1
  Downloading ansible-5.7.1.tar.gz (35.7 MB)
     |████████████████████████████████| 35.7 MB 6.9 kB/s
Collecting ansible-core==2.12.5
  Downloading ansible-core-2.12.5.tar.gz (7.8 MB)
     |████████████████████████████████| 7.8 MB 55 kB/s
Collecting cryptography==3.4.8
  Downloading cryptography-3.4.8-cp36-abi3-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (3.2 MB)
     |████████████████████████████████| 3.2 MB 69.8 MB/s
Collecting jinja2==2.11.3
  Downloading Jinja2-2.11.3-py2.py3-none-any.whl (125 kB)
     |████████████████████████████████| 125 kB 62.4 MB/s
Collecting jmespath==0.9.5
  Downloading jmespath-0.9.5-py2.py3-none-any.whl (24 kB)
Collecting MarkupSafe==1.1.1
  Downloading MarkupSafe-1.1.1-cp38-cp38-manylinux2010_x86_64.whl (32 kB)
Collecting netaddr==0.7.19
  Downloading netaddr-0.7.19-py2.py3-none-any.whl (1.6 MB)
     |████████████████████████████████| 1.6 MB 35.3 MB/s
Collecting pbr==5.4.4
  Downloading pbr-5.4.4-py2.py3-none-any.whl (110 kB)
     |████████████████████████████████| 110 kB 59.9 MB/s
Collecting ruamel.yaml==0.16.10
  Downloading ruamel.yaml-0.16.10-py2.py3-none-any.whl (111 kB)
     |████████████████████████████████| 111 kB 60.9 MB/s
Collecting ruamel.yaml.clib==0.2.7
  Downloading ruamel.yaml.clib-0.2.7-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.manylinux_2_24_x86_64.whl (555 kB)
     |████████████████████████████████| 555 kB 58.8 MB/s
Requirement already satisfied: PyYAML in /usr/lib/python3/dist-packages (from ansible-core==2.12.5->-r requirements.txt (line 2)) (5.3.1)
Collecting packaging
  Downloading packaging-23.1-py3-none-any.whl (48 kB)
     |████████████████████████████████| 48 kB 8.1 MB/s
Collecting resolvelib<0.6.0,>=0.5.3
  Downloading resolvelib-0.5.4-py2.py3-none-any.whl (12 kB)
Collecting cffi>=1.12
  Downloading cffi-1.15.1-cp38-cp38-manylinux_2_17_x86_64.manylinux2014_x86_64.whl (442 kB)
     |████████████████████████████████| 442 kB 51.7 MB/s
Collecting pycparser
  Downloading pycparser-2.21-py2.py3-none-any.whl (118 kB)
     |████████████████████████████████| 118 kB 56 kB/s
Building wheels for collected packages: ansible, ansible-core
  Building wheel for ansible (setup.py) ... done
  Created wheel for ansible: filename=ansible-5.7.1-py3-none-any.whl size=61777681 sha256=c39acb4cce8d1e2f48f1179c5cfd04e5bf4b1a25eb1afa25f88827eef517b2ab
  Stored in directory: /root/.cache/pip/wheels/02/07/2a/7b3eb5d79e268b769b0910cded0d524b4647ae5bc19f3ebb70
  Building wheel for ansible-core (setup.py) ... done
  Created wheel for ansible-core: filename=ansible_core-2.12.5-py3-none-any.whl size=2077336 sha256=ca3c5793e41f733a42386312b2c82cc315b2cc6aed9d73c8e639213bae322fab
  Stored in directory: /root/.cache/pip/wheels/13/09/5b/799a6bc9ca05da9805eaee2afea07e7f63e2ff03b37799d930
Successfully built ansible ansible-core
Installing collected packages: pycparser, cffi, cryptography, MarkupSafe, jinja2, packaging, resolvelib, ansible-core, ansible, jmespath, netaddr, pbr, ruamel.yaml.clib, ruamel.yaml
  Attempting uninstall: cryptography
    Found existing installation: cryptography 2.8
    Not uninstalling cryptography at /usr/lib/python3/dist-packages, outside environment /usr
    Can't uninstall 'cryptography'. No files were found to uninstall.
  Attempting uninstall: MarkupSafe
    Found existing installation: MarkupSafe 1.1.0
    Not uninstalling markupsafe at /usr/lib/python3/dist-packages, outside environment /usr
    Can't uninstall 'MarkupSafe'. No files were found to uninstall.
  Attempting uninstall: jinja2
    Found existing installation: Jinja2 2.10.1
    Not uninstalling jinja2 at /usr/lib/python3/dist-packages, outside environment /usr
    Can't uninstall 'Jinja2'. No files were found to uninstall.
Successfully installed MarkupSafe-1.1.1 ansible-5.7.1 ansible-core-2.12.5 cffi-1.15.1 cryptography-3.4.8 jinja2-2.11.3 jmespath-0.9.5 netaddr-0.7.19 packaging-23.1 pbr-5.4.4 pycparser-2.21 resolvelib-0.5.4 ruamel.yaml-0.16.10 ruamel.ya
ml.clib-0.2.7
```

Подготовим файл host.yaml
```bash
root@masterk8s:~/kubespray# declare -a IPS=(10.1.2.15 10.1.2.19 10.1.2.5 10.1.2.29 10.1.2.18)
root@masterk8s:~/kubespray# CONFIG_FILE=inventory/mycluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
DEBUG: Adding group all
DEBUG: Adding group kube_control_plane
DEBUG: Adding group kube_node
DEBUG: Adding group etcd
DEBUG: Adding group k8s_cluster
DEBUG: Adding group calico_rr
DEBUG: adding host node1 to group all
DEBUG: adding host node2 to group all
DEBUG: adding host node3 to group all
DEBUG: adding host node4 to group all
DEBUG: adding host node5 to group all
DEBUG: adding host node1 to group etcd
DEBUG: adding host node2 to group etcd
DEBUG: adding host node3 to group etcd
DEBUG: adding host node1 to group kube_control_plane
DEBUG: adding host node2 to group kube_control_plane
DEBUG: adding host node1 to group kube_node
DEBUG: adding host node2 to group kube_node
DEBUG: adding host node3 to group kube_node
DEBUG: adding host node4 to group kube_node
DEBUG: adding host node5 to group kube_node
root@masterk8s:~/kubespray# nano inventory/mycluster/hosts.yaml
root@masterk8s:~/kubespray# cat inventory/mycluster/hosts.yaml
all:
  hosts:
    masterk8s:
      ansible_host: 10.1.2.15
      ip: 10.1.2.15
      access_ip: 10.1.2.15
      ansible_user: yc-user
    worker1:
      ansible_host: 10.1.2.19
      ip: 10.1.2.19
      access_ip: 10.1.2.19
      ansible_user: yc-user
    worker2:
      ansible_host: 10.1.2.5
      ip: 10.1.2.5
      access_ip: 10.1.2.5
      ansible_user: yc-user
    worker3:
      ansible_host: 10.1.2.29
      ip: 10.1.2.29
      access_ip: 10.1.2.29
      ansible_user: yc-user
    worker4:
      ansible_host: 10.1.2.18
      ip: 10.1.2.18
      access_ip: 10.1.2.18
      ansible_user: yc-user
  children:
    kube_control_plane:
      hosts:
        masterk8s:
    kube_node:
      hosts:
        worker1:
        worker2:
        worker3:
        worker4:
    etcd:
      hosts:
        masterk8s:
    k8s_cluster:
      children:
        kube_control_plane:
        kube_node:
    calico_rr:
      hosts: {}
```

Добавим `PRIVATE KEY` на master чтобы ansible имел возможность подключаться к worker
```bash
root@masterk8s:~# cat .ssh/id_rsa 
-----BEGIN OPENSSH PRIVATE KEY-----
b3BlbnNzaC1rZXktdjEAAAAABG5vbmUAAAAEbm9uZQAAAAAAAAABAAABlwAAAAdzc2gtcn
NhAAAAAwEAAQAAAYEAwgPUsw4+oF+ip6Nu6pViId8jlOS8oAq0ztQNtR7V1B31oP73IK77
ChjSBtA9mmRf83mULAPLf+woWOOE06wd/ZhxueXZKsrNMu1g1NwTVmFHB57RvkglHXQvkC
nG+nuEXWchf1vuFnlnsCHLd+9F/T6jFyJoCMa8xMa6QCUJsCCQ33L7c7Ky+ozmPk0hANBY
eR7AFUZwjOxBFdJ37A/Gg06raSyjaiWgF2W/gpi/P3rWF7Xcst46qS59+fvYf/As4Zq/67
uVNk7VrZ/PZB3kIPIF8jOKvLXVeDdHyzpEcB/psvKwRne5vwPlgMSXnzFmdPKqrx9Sye0I
fq6qOO0CYlu9phIMz9moQaAxQU6NtF/GzM9R0s9CQwrn8kWghUbhQ4kCud3wsmGSlQZYLf
zOW0IRF1Dt0b6Vre5Hqzx3agpQYwYfCiHDJlWPYuiWpkTE8g19Zin8oX4sxAOQc096M/45
EJ2M7b6h+OTuR7nc+FTbaf8Hh+4KWhv7YLjsul27AAAFiDmTIMs5kyDLAAAAB3NzaC1yc2
EAAAGBAMID1LMOPqBfoqejbuqVYiHfI5TkvKAKtM7UDbUe1dQd9aD+9yCu+woY0gbQPZpk
X/N5lCwDy3/sKFjjhNOsHf2Ycbnl2SrKzTLtYNTcE1ZhRwee0b5IJR10L5Apxvp7hF1nIX
9b7hZ5Z7Ahy3fvRf0+oxciaAjGvMTGukAlCbAgkN9y+3OysvqM5j5NIQDQWHkewBVGcIzs
QRXSd+wPxoNOq2kso2oloBdlv4KYvz961he13LLeOqkuffn72H/wLOGav+u7lTZO1a2fz2
Qd5CDyBfIziry11Xg3R8s6RHAf6bLysEZ3ub8D5YDEl58xZnTyqq8fUsntCH6uqjjtAmJb
vaYSDM/ZqEGgMUFOjbRfxszPUdLPQkMK5/JFoIVG4UOJArnd8LJhkpUGWC38zltCERdQ7d
G+la3uR6s8d2oKUGMGHwohwyZVj2LolqZExPINfWYp/KF+LMQDkHNPejP+ORCdjO2+ofjk
7ke53PhU22n/B4fuClob+2C47LpduwAAAAMBAAEAAAGAOragEsPXzf7DIYpDEbi9ZtS5Vu
DV+HTk/MaNk2dOfI/Ier1OGlT54bdbL/aq/eMsamk7nwpS9laIa0YHN2uZ89nDaOeXDe0r
piLSL/id3YE41qSIgtYgbUZw8mbCMaFZkE6ag4lVhvWcnF/NzHDbtGTVRDYEV8uU6tPdH3
......................................................................
smk17ed0xygrtZAyl50d4PoR24yGUYA5a49U7WJPjZl1WtG0HI8plvDxUVy+oaImNx0Ju8
VhiTHIR2s8HoIye1JUiTsQSiBa8pQDyw3LzlIkaDN5FCpwR2k13wdMrVBu4aIjIoeyT3c0
djc85kRU4/MCN8ldN37a63TaseUXTvFl+IQbLyiWJ6vWtqiaJ5WUwQGJWtT+t1j4Z7AtRF
Bthwg8ksssH/sHGklNlnGiZqSZwP/NUovkNRFVyF0Qch3QhD8WWvZdOcApiOL/cX85AAAA
wQC1JaoeyfAd4JnOsgg0yHc8OluyQjhaM2l8mjDG9u3Jy/JE8sHud7e+fLxFzQwiLtxeac
fdru7jrpUEyjpMo4sTSX3abJsrQHh48PrFL+tr976uQLb2QGxVpRyp1ugb/RLXjzUkC3Nq
WrAAjNvsFcPBjuk+glB2Cfpz7jW4ZnKdPU5Co4gfMKk7pH/XovU1+veqj7qvTaRKX1+ev9
pPOJqQhw9u/mU99+DRoy4wVMaCaOiRcKcETWAnyogeJUCAn9wAAADBAOcWoj6kqj3ApwEh
y7OdSstpcYLFil1B5Qs8mOAjPMlGfPdBF/UVGwbGp7D40HouRKReUj7WYh7R3vRELq0eju
Jy8f3AQReYkxezzze+ZO/ZCvQVqsPQrgE9fcMN+5PaMpv/YPyBlMs+MvGE+vbdJg82I3Z4
Drkn5hr20iQOCFpQICptcUmUrNJ/XK/c9gRWir3DgrnhPgu08dShZ9uFmhG+E9yVhNWEqK
crGJ1lzUGJhFmAxEHoRYG5kjcHv5X8BQAAAMEA1u4T+XJvi+C3Nw96kuOJtDZBLS+rscZx
mv0UregBxhoU7lp+ye30nRByAhdLXL5zLcAQ4jA3CgWHIselawanSL3/MZ8BqoAyK2N3bC
aJ51meWfh2/ooJboi7wZUiRWZKdeviN3lJCJTQkJktUVrjepHszaYpIbRYB7sByly/1f6E
jY05kID8TQ0ftBv4JBVq3FNUWxj1/wi8RFmgzmyhuJmxwt/lrZEUKv7eC9/a5+5MkdJFkg
pCJwoXknh3296/AAAADHJvb3RAc2VydmVyMQECAwQFBg==
-----END OPENSSH PRIVATE KEY-----
```
Запуск playbook

```bash
root@masterk8s:~/kubespray# ansible-playbook -i inventory/mycluster/inventory.ini cluster.yml -b -v
..................
.............
PLAY RECAP ********************************************************************************************************************************************************************************************************************************
localhost                  : ok=3    changed=0    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0   
masterk8s                  : ok=738  changed=146  unreachable=0    failed=0    skipped=1261 rescued=0    ignored=8   
worker1                    : ok=511  changed=93   unreachable=0    failed=0    skipped=774  rescued=0    ignored=1   
worker2                    : ok=511  changed=93   unreachable=0    failed=0    skipped=773  rescued=0    ignored=1   
worker3                    : ok=511  changed=93   unreachable=0    failed=0    skipped=773  rescued=0    ignored=1   
worker4                    : ok=511  changed=92   unreachable=0    failed=0    skipped=773  rescued=0    ignored=1   

Wednesday 19 April 2023  11:29:01 +0000 (0:00:00.107)       0:18:34.478 *******
===============================================================================
kubernetes/preinstall : Update package management cache (APT) --------------------------------------------------------------------------------------------------------------------------------------------------------------------- 54.04s 
network_plugin/calico : Wait for calico kubeconfig to be created ------------------------------------------------------------------------------------------------------------------------------------------------------------------ 42.61s 
kubernetes/preinstall : Install packages requirements ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 42.33s 
kubernetes/kubeadm : Join to cluster ---------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 34.94s 
kubernetes/preinstall : Preinstall | wait for the apiserver to be running --------------------------------------------------------------------------------------------------------------------------------------------------------- 31.80s 
download : download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 28.60s 
kubernetes/control-plane : kubeadm | Initialize first master ---------------------------------------------------------------------------------------------------------------------------------------------------------------------- 25.65s 
download : download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 18.08s 
download : download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 17.44s 
download : download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 16.11s 
download : download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 13.79s 
download : download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 12.78s 
kubernetes-apps/ansible : Kubernetes Apps | Start Resources ----------------------------------------------------------------------------------------------------------------------------------------------------------------------- 12.56s 
download : download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 12.30s 
download : download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 10.97s 
download : download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------------------------------------------ 10.26s 
network_plugin/calico : Calico | Copy calicoctl binary from download dir ---------------------------------------------------------------------------------------------------------------------------------------------------------- 10.21s 
download : download_container | Remove container image from cache ------------------------------------------------------------------------------------------------------------------------------------------------------------------ 9.24s 
download : download_container | Download image if required ------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 9.03s 
etcd : reload etcd ----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------- 8.98s 
```

Проверяем

```bash
root@masterk8s:~/kubespray# kubectl version
WARNING: This version information is deprecated and will be replaced with the output from kubectl version --short.  Use --output=yaml|json to get the full version.
Client Version: version.Info{Major:"1", Minor:"26", GitVersion:"v1.26.3", GitCommit:"9e644106593f3f4aa98f8a84b23db5fa378900bd", GitTreeState:"clean", BuildDate:"2023-03-15T13:40:17Z", GoVersion:"go1.19.7", Compiler:"gc", Platform:"linu
x/amd64"}
Kustomize Version: v4.5.7
Server Version: version.Info{Major:"1", Minor:"26", GitVersion:"v1.26.3", GitCommit:"9e644106593f3f4aa98f8a84b23db5fa378900bd", GitTreeState:"clean", BuildDate:"2023-03-15T13:33:12Z", GoVersion:"go1.19.7", Compiler:"gc", Platform:"linu
x/amd64"}
```

```bash
root@masterk8s:~/.kube# kubectl get nodes
NAME        STATUS   ROLES           AGE   VERSION
masterk8s   Ready    control-plane   16m   v1.26.3
worker1     Ready    <none>          15m   v1.26.3
worker2     Ready    <none>          15m   v1.26.3
worker3     Ready    <none>          15m   v1.26.3
worker4     Ready    <none>          15m   v1.26.3

root@masterk8s:~/.kube# kubectl create deploy nginx --image=nginx:latest --replicas=2
deployment.apps/nginx created

root@masterk8s:~/.kube# kubectl get pod -o wide
NAME                     READY   STATUS    RESTARTS   AGE   IP            NODE      NOMINATED NODE   READINESS GATES
nginx-654975c8cd-ffknb   1/1     Running   0          33s   10.233.97.1   worker4   <none>           <none>
nginx-654975c8cd-wp22q   1/1     Running   0          33s   10.233.83.1   worker3   <none>           <none>
```
Подключение к api по внешнему адресу из моей локальной сети.

![](pic/kubectl_out.jpg)

![](pic/kubectl_out1.jpg)


В топку

```bash
$ sh vms_yc/delete-vms.sh 
...1s...6s...12s...17s...23s...done (24s)
...1s...6s...11s...17s...22s...done (22s)
...1s...6s...11s...17s...22s...done (24s)
...1s...6s...11s...17s...22s...27s...done (27s)
...1s...6s...11s...17s...22s...done (26s)

$ yc vpc subnet delete --name my-subnet && yc vpc network delete --name net
done (2s)
```
## Дополнительные задания (со звездочкой*)

**Настоятельно рекомендуем выполнять все задания под звёздочкой.**   Их выполнение поможет глубже разобраться в материале.   
Задания под звёздочкой дополнительные (необязательные к выполнению) и никак не повлияют на получение вами зачета по этому домашнему заданию. 

------
### Задание 2*. Установить HA кластер

1. Установить кластер в режиме HA
2. Использовать нечетное кол-во Master-node
3. Для cluster ip использовать keepalived или другой способ

### Правила приема работы

1. Домашняя работа оформляется в своем Git репозитории в файле README.md. Выполненное домашнее задание пришлите ссылкой на .md-файл в вашем репозитории.
2. Файл README.md должен содержать скриншоты вывода необходимых команд `kubectl get nodes`, а также скриншоты результатов
3. Репозиторий должен содержать тексты манифестов или ссылки на них в файле README.md
