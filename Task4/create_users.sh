#!/bin/bash

# Директория для сертификатов
CERTS_DIR="./k8s-users-certs"
mkdir -p "$CERTS_DIR"

# Получаем CA Minikube из файлов
CA_CERT_PATH="$HOME/.minikube/ca.crt"
CA_KEY_PATH="$HOME/.minikube/ca.key"

if [[ ! -f "$CA_CERT_PATH" || ! -f "$CA_KEY_PATH" ]]; then
  echo "Ошибка: Не найдены CA-сертификаты Minikube."
  echo "Попробуйте: minikube delete && minikube start"
  exit 1
fi

cp "$CA_CERT_PATH" "$CERTS_DIR/ca.crt"
cp "$CA_KEY_PATH" "$CERTS_DIR/ca.key"

# Функция для создания пользователя
create_user() {
  local USER=$1
  local GROUP=$2
  
  echo "Создаем пользователя: $USER (группа: $GROUP)"
  
  # Генерация ключа и CSR
  openssl genrsa -out "$CERTS_DIR/$USER.key" 2048
  openssl req -new -key "$CERTS_DIR/$USER.key" -out "$CERTS_DIR/$USER.csr" -subj "/CN=$USER/O=$GROUP"
  
  # Подписываем сертификат
  openssl x509 -req -in "$CERTS_DIR/$USER.csr" \
    -CA "$CERTS_DIR/ca.crt" \
    -CAkey "$CERTS_DIR/ca.key" \
    -CAcreateserial \
    -out "$CERTS_DIR/$USER.crt" \
    -days 365
  
  # Добавляем пользователя в kubectl config
  kubectl config set-credentials "$USER" \
    --client-certificate="$CERTS_DIR/$USER.crt" \
    --client-key="$CERTS_DIR/$USER.key"

  kubectl config set-context "$USER-context" \
    --cluster=minikube \
    --user="$USER" \
    --namespace=default
}

# Создаем каждого пользователя отдельно
create_user "secure-operator" "secure-operator-group"
create_user "infrastructure-operator" "infrastructure-operator-group"
create_user "infrastructure-administrator" "infrastructure-administrator-group"

echo "Пользователи созданы:"
echo "1. secure-operator"
echo "2. infrastructure-operator"
echo "3. infrastructure-administrator"
echo "Сертификаты сохранены в: $CERTS_DIR"