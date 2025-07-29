from pydantic import BaseModel, EmailStr, Field, ConfigDict

class CheckEmail(BaseModel):
    """Model for user login credentials"""
    email: str = "koro1@gmail.com"  

    model_config = ConfigDict(from_attributes=True)

class CheckEmailAndCode(BaseModel):
    email: str = ""
    code: str = ""

    model_config = ConfigDict(from_attributes=True)


class UserChangePassword(BaseModel):
    email: str = ""
    password: str = ""
    confirm_password: str = ""

    model_config = ConfigDict(from_attributes=True)

class FCMToken(BaseModel):
    fcm_token: str = ""
    user_id: str = ""
    
    model_config = ConfigDict(from_attributes=True)


class UserIdRequest(BaseModel):
    user_id: str = ""
    
    model_config = ConfigDict(from_attributes=True)