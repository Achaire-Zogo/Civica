import os 
import jwt
from dotenv import load_dotenv 
load_dotenv()

def generate_token(data):
    """
    generate token for user 
    """
    secret_key = os.getenv("SECRET_KEY")
    payload = {
        'user':data ,
    }

    token = jwt.encode(payload,secret_key,algorithm='HS256')

    return token

def verify_token(token):
    """
    verify token for user 
    """
    secret_key = os.getenv("SECRET_KEY")
    try:
        payload = jwt.decode(token,secret_key,algorithms=['HS256'])
        return payload
    except jwt.ExpiredSignatureError:
        return None
    except jwt.InvalidTokenError:
        return None
    except Exception as e:
        return None