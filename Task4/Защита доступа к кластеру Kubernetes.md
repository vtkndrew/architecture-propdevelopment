### Задание 4. Защита доступа к кластеру Kubernetes

##### Таблица ролей
| Роль  | Права роли | Группы пользователей |
| --- | --- | --- |
| secrets-reader | read | secure-operator |
| cluster-reader | read | infrastructure-operator |
| cluster-writer | read + write | infrastructure-administrator |

##### Решение

- [скрипты для создания пользователей](./create_users.sh)
- [скрипты для создания ролей](./create_roles.sh)
- [скрипты, чтобы связать пользователей с ролями](./create_role_bindings.sh)

##### Проверка прав пользователей

```bash
# Проверить доступ secure-operator к секретам (должен быть разрешен)
kubectl auth can-i get secrets --as secure-operator
# yes

# Проверить доступ infrastructure-operator к pod'ам (только чтение)
kubectl auth can-i list pods --as infrastructure-operator
# yes
kubectl auth can-i delete pods --as infrastructure-operator
# no

# Проверить полные права infrastructure-administrator
kubectl auth can-i delete pods --as infrastructure-administrator
# yes
kubectl auth can-i create deployments --as infrastructure-administrator
# yes
```