# Lesta-end

## Запуск проекта локально:

Для того чтобы запустить проект локально, необходимо склонировать репозиторий:
```
git clone https://github.com/ilyaKrivitskiy/lesta-end.git
```

Перейти в рабочую директорию:
```
cd lesta-end
```

Затем изменить файл `.env.example` на `.env`:
```
mv .env.example .env
```

После чего можно будет запустить:
```
docker compose up --build -d
```
⚠️ Обратите внимание на доступность необходимых портов на хостовой машине
и отсутствие docker volume с таким же названием, что и в docker-compose.

## Как настроить Jenkins

1. **Установка Jenkins**

Установите Jenkins на сервер или локальную машину через Docker, предварительно прописав в базовом образе 
`RUN apt-get install flake8`.
Подробнее: https://www.jenkins.io/doc/book/installing/

2. **Настройка Jenkins Agent**

- Можно использовать встроенный агент Jenkins.

3. **Добавление учетных данных в Jenkins**

- Docker Hub credentials (для публикации образов)
- GitHub Personal Access Token (для доступа к репозиторию)
- SSH ключ (для доступа к удалённому серверу для деплоя)

4. **Создание Jenkins pipeline**

CI pipeline есть в Github репозитории.
   

- **CD pipeline**:
```
pipeline {
    agent any
    environment {
        DEPLOY_HOST = '{LINUX_PROD_IP}'
        DEPLOY_USER = '{USERNAME_PROD_HOST}'
        SSH_KEY_ID = '{SSH_KEY_ID}'
        DEPLOY_PATH = 'lesta-end'
        DOCKER_IMAGE = '{DOCKER_IMAGE}'
    }

    stages {
        stage('Copy artifact') {
            steps {
                copyArtifacts(
                    projectName: 'lesta-end',
                    selector: lastSuccessful(),
                    filter: 'docker-compose.yaml',
                    target: 'artifacts'
                )
            }
        }
        stage('Delivery and Deploy') {
            steps {
                sshagent (credentials: [env.SSH_KEY_ID]) {
                    sh """
                        ssh ${DEPLOY_USER}@${DEPLOY_HOST} 'mkdir -p /home/${DEPLOY_USER}/${DEPLOY_PATH}'
                        scp $WORKSPACE/artifacts/docker-compose.yaml ${DEPLOY_USER}@${DEPLOY_HOST}:/home/${DEPLOY_USER}/${DEPLOY_PATH}/
                    """
                }
                sshagent (credentials: [env.SSH_KEY_ID]) {
                    sh """
                    ssh -o StrictHostKeyChecking=no ${DEPLOY_USER}@${DEPLOY_HOST} '
                        docker pull ${DOCKER_IMAGE} &&
                        cd /home/${DEPLOY_USER}/lesta-end &&
                        docker compose down &&
                        docker compose up -d --build
                    '
                    """
                }
            }
        }
    }
}
``` 

## Как работает CI/CD

### CI (Continuous Integration)

При каждом пуше в GitHub:
- Jenkins автоматически (webhook добавлен в GitHub) запускает pipeline, который:
  - Проверяет исходный код
  - Собирает Docker-образ с Flask приложением
  - Прогоняет линтером flake8 python код
  - Публикует образ в Docker Hub
  - Создает артефакт в виде docker-compose.yaml

### CD (Continuous Deployment)

После успешного CI:

- Запускается CD pipeline по триггеру, который:
  - Подключается к удалённому серверу через SSH
  - Забирает артефакт и отправляет его на продовый сервер
  - Обновляет файл `docker-compose.yaml`
  - Перезапускает сервисы с новым образом Docker

## Примеры API-запросов

⚠️ В примерах ниже сервер взят localhost.
Если приложение хостится на другом сервере - нужно указать его IP-дрес.

GET /ping
```
curl http://localhost:5000/ping
```

Результат:
`{"status":"ok"}`

POST /submit
```
curl -X POST http://localhost:5000/submit \
-H "Content-Type: application/json" \
-d '{"name": "Kirill", "score": 38}'
```

Результат:
`{"id":5,"message":"Score submitted"}`

Выполняем несколько раз, наполняя базу.

GET /results
```
curl http://localhost:5000/results
```

Результат:
```
[{"id":5,"name":"Kirill","score":38,"timestamp":"2025-06-09T12:27:33.433221"},
{"id":4,"name":"Kirill","score":48,"timestamp":"2025-06-09T12:27:28.419973"},
{"id":3,"name":"Ilya","score":101,"timestamp":"2025-06-09T10:28:52.132358"},
{"id":2,"name":"Kirill","score":88,"timestamp":"2025-06-09T10:28:46.093889"},
{"id":1,"name":"Danya","score":100,"timestamp":"2025-06-09T10:28:38.418823"}]
```