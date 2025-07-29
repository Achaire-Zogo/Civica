# EasyLifePay Backend

Backend API pour l'application EasyLifePay, développé avec FastAPI.

## Installation

1. Cloner le dépôt
2. Installer les dépendances :
   ```
   pip install -r requirements.txt
   ```

## Démarrage

Pour lancer le serveur de développement :

```
python3 -m venv venv
source venv/bin/activate
pip install --upgrade pip
pip install -r requirements.txt
python3 app.py
```

ou

```
uvicorn app:app --reload
```

Le serveur sera accessible à l'adresse : http://localhost:8000

## Documentation API

Une fois le serveur démarré, la documentation interactive de l'API est disponible aux adresses :
- Swagger UI : http://localhost:8000/api/docs
- ReDoc : http://localhost:8000/api/redoc
