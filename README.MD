1. Чтобы создать сервера на платформе Yandex Cloud, запустите Terraform спецификацию
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

2. Чтобы запустить установку с помощью ansible:

```bash
cd ansible
ansible-playbook -i inventories/production/hosts.ini playbook.yml
```