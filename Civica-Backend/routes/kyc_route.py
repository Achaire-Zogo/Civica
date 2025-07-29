#!/usr/bin/env python3
from typing import List, Optional, Dict, Any, Union
from fastapi import APIRouter, Depends, HTTPException, status
from pydantic import BaseModel, Field, validator
import os
import base64
import json
import logging
from datetime import datetime
import uuid
from typing import Optional
from regula.documentreader.webclient import *
import shutil
import tempfile
from pathlib import Path
from dependencies import StandardResponse, handle_exception
from fastapi import Request, Body, UploadFile, File, Form
import sys
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
import time
from security.token_utils import verify_token
# Configure logging
logging.basicConfig(level=logging.INFO)
logger = logging.getLogger(__name__)

http_bearer = HTTPBearer()

router = APIRouter(
    prefix="/api/kyc",
    tags=["KYC"],
    responses={404: {"description": "Not found"}},
)

# Regula API configuration
REGULA_API_HOST = os.getenv('REGULA_API_HOST', 'https://api.regulaforensics.com')
REGULA_API_KEY = os.getenv('REGULA_API_KEY', '123')  # Set your actual API key in environment variables
REGULA_AUTH_TOKEN = os.getenv('REGULA_AUTH_TOKEN', '123')  # Set your actual auth token

# Directory to save processed documents temporarily
UPLOAD_FOLDER = os.path.join(os.getcwd(), 'temp_uploads')
os.makedirs(UPLOAD_FOLDER, exist_ok=True)

# Supported document types
DOCUMENT_TYPES = ['cni', 'passport', 'permit']

@router.post('/upload', response_model=StandardResponse)
async def upload_kyc_document(
    documentType: str = Form(..., description="Type of document (cni, passport, permit)"),
    userId: str = Form(..., description="User ID"),
    frontImage: UploadFile = File(..., description="Front image of the document"),
    backImage: UploadFile = File(None, description="Back image of the document (required for CNI and Permit)"),
    credentials: HTTPAuthorizationCredentials = Depends(http_bearer)
):
    """
    Upload KYC documents for verification
    """
    try:
        if not credentials.credentials:
            return StandardResponse(statusCode=404, message="token not found", data=None)
        #verify token
        verif_token = verify_token(credentials.credentials)
        if not verif_token:
            return StandardResponse(statusCode=401, message="Unauthorized", data=None)
        # Validate document type
        if documentType not in DOCUMENT_TYPES:
            return StandardResponse(
                statusCode=400,
                message=f"Invalid document type. Must be one of: {', '.join(DOCUMENT_TYPES)}",
                data={}
            )

        # For CNI and Permit, back image is required
        if documentType in ['cni', 'permit'] and not backImage:
            return StandardResponse(
                statusCode=400,
                message=f"Back image is required for {documentType.upper()} documents",
                data={}
            )

        # Files to clean up later
        files_to_cleanup = []
        
        try:
            # Save front image directly in temp_uploads folder
            front_filename = f"{userId}_front_{int(time.time())}{Path(frontImage.filename).suffix}"
            front_path = os.path.join(UPLOAD_FOLDER, front_filename)
            with open(front_path, "wb") as buffer:
                shutil.copyfileobj(frontImage.file, buffer)
            files_to_cleanup.append(front_path)
            
            # Save back image if provided
            back_path = None
            if backImage:
                back_filename = f"{userId}_back_{int(time.time())}{Path(backImage.filename).suffix}"
                back_path = os.path.join(UPLOAD_FOLDER, back_filename)
                with open(back_path, "wb") as buffer:
                    shutil.copyfileobj(backImage.file, buffer)
                files_to_cleanup.append(back_path)
            
            # Process with Regula (simplified example)
            document_paths = {
                'front': front_path,
                'back': back_path
            }
            
            # Here you would typically call process_documents_with_regula
            # For now, we'll just return success
            
            return StandardResponse(
                statusCode=200,
                message=f"{documentType.upper()} document uploaded successfully",
                data={
                    "documentType": documentType,
                    "userId": userId,
                    "files": [f for f in [front_path, back_path] if f is not None]
                }
            )
            
        except Exception as e:
            logger.error(f"Error processing document: {str(e)}")
            return handle_exception(e, context="Error processing document")
            
        # finally:
            # Clean up individual files after processing (not the entire directory)
            # for file_path in files_to_cleanup:
            #     try:
            #         if os.path.exists(file_path):
            #             os.remove(file_path)
            #             logger.info(f"Cleaned up file: {file_path}")
            #     except Exception as e:
            #         logger.error(f"Error cleaning up file {file_path}: {str(e)}")
    
    except HTTPException as he:
        logger.error(f"HTTP error in upload_kyc_document: {str(he)}")
        return handle_exception(he, context="HTTP error in upload_kyc_document")
    except Exception as e:
        logger.error(f"Unexpected error in upload_kyc_document: {str(e)}")
        return handle_exception(e, context="Unexpected error in upload_kyc_document")




@router.get('/health', response_model=StandardResponse)
def health_check():
    """Health check endpoint for the KYC service"""
    try:
        with DocumentReaderApi(REGULA_API_HOST) as api:
            api.api_client.default_headers = {
                "X-CLIENT-KEY": REGULA_API_KEY,
                "Authorization": f"Bearer {REGULA_AUTH_TOKEN}"
            }
            health_info = api.healthz()
            
            return StandardResponse(
                statusCode=200,
                message='KYC service is healthy',
                data={
                    'apiVersion': health_info.version,
                }
            )
    except Exception as e:
        logger.error(f"Health check failed: {str(e)}")
        return StandardResponse(
            statusCode=500,
            message=f'KYC service health check failed: {str(e)}',
            data={}
        )

# Pydantic models for request validation
class DocumentData(BaseModel):
    documentNumber: Optional[str] = None
    fullName: Optional[str] = None
    dateOfBirth: Optional[str] = None
    dateOfExpiry: Optional[str] = None
    nationality: Optional[str] = None
    gender: Optional[str] = None

# Base model for all requests
class BaseDocumentRequest(BaseModel):
    userId: str = Field(..., description="User ID for the KYC submission")
    documentData: Optional[DocumentData] = Field(None, description="Optional pre-extracted document data")

# Passport request model
class PassportRequest(BaseDocumentRequest):
    passportImage: str = Field(..., description="Base64 encoded passport image")
    selfieImage: Optional[str] = Field(None, description="Optional base64 encoded selfie image")
    
    @validator('passportImage', 'selfieImage')
    def validate_base64(cls, v):
        if v is not None and not isinstance(v, str):
            raise ValueError('Image must be a base64 encoded string')
        return v

# ID Card/Permit request model
class IdCardRequest(BaseDocumentRequest):
    frontImage: str = Field(..., description="Base64 encoded front image of ID card or driver's license")
    backImage: str = Field(..., description="Base64 encoded back image of ID card or driver's license")
    selfieImage: Optional[str] = Field(None, description="Optional base64 encoded selfie image")
    
    @validator('frontImage', 'backImage', 'selfieImage')
    def validate_base64(cls, v):
        if v is not None and not isinstance(v, str):
            raise ValueError('Image must be a base64 encoded string')
        return v

# Selfie only request model
class SelfieRequest(BaseModel):
    userId: str = Field(..., description="User ID for the KYC submission")
    selfieImage: str = Field(..., description="Base64 encoded selfie image")
    
    @validator('selfieImage')
    def validate_base64(cls, v):
        if v is not None and not isinstance(v, str):
            raise ValueError('Image must be a base64 encoded string')
        return v

# Legacy model for backwards compatibility
class DocumentImages(BaseModel):
    documentImage: Optional[str] = Field(None, description="Base64 encoded passport image")
    frontImage: Optional[str] = Field(None, description="Base64 encoded front image of ID card or driver's license")
    backImage: Optional[str] = Field(None, description="Base64 encoded back image of ID card or driver's license")
    selfieImage: Optional[str] = Field(None, description="Base64 encoded selfie image")
    
    @validator('documentImage', 'frontImage', 'backImage', 'selfieImage')
    def validate_base64(cls, v):
        if v is not None and not isinstance(v, str):
            raise ValueError('Image must be a base64 encoded string')
        return v
    
    @validator('*')
    def at_least_one_document_image(cls, v, values):
        # This will run on the first field, checking if we have at least one document image
        if list(values.keys()) == []:
            # We're validating the first field
            if v is None and all(field not in values for field in ['documentImage', 'frontImage']):
                raise ValueError('At least one document image is required (passport or front ID)')
        return v

class KycSubmissionRequest(BaseDocumentRequest):
    images: DocumentImages = Field(..., description="Document images in base64 format")

# Generic endpoint for backward compatibility
@router.post('/submit', response_model=StandardResponse)
async def submit_kyc(submission: KycSubmissionRequest):
    """
    Process KYC document submission
    
    Accepts:
    - Single document (passport)
    - Double-sided document (ID card, driver's license)
    - Optional selfie image
    """
    try:
        # Data is already validated by Pydantic
        user_id = submission.userId
        images = submission.images.dict(exclude_none=True)
        
        # Save document images to temporary files
        document_paths = {}
        for image_key, image_data in images.items():
            if image_key != 'selfieImage':  # Handle document images
                if not image_data:
                    continue
                
                # Decode base64 image
                try:
                    image_bytes = base64.b64decode(image_data)
                    temp_path = os.path.join(UPLOAD_FOLDER, f"{user_id}_{image_key}_{uuid.uuid4()}.jpg")
                    with open(temp_path, 'wb') as f:
                        f.write(image_bytes)
                    document_paths[image_key] = temp_path
                except Exception as e:
                    logger.error(f"Error saving image {image_key}: {str(e)}")
                    return StandardResponse(
                        statusCode=400,
                        message=f'Invalid image format for {image_key}',
                        data={}
                    )
        
        # Process document with Regula
        result = process_documents_with_regula(document_paths)
        
        if not result.get('success'):
            return StandardResponse(
                statusCode=400,
                message=result.get('error'),
                data={}
            )
            
        # Store additional data
        document_data = submission.documentData.dict(exclude_none=True) if submission.documentData else {}
        
        # Merge data from document_data with extracted Regula data
        final_result = {
            'success': True,
            'userId': user_id,
            'timestamp': datetime.now().isoformat(),
            'documentData': {
                **document_data,
                **result.get('extractedData', {})
            },
            'verificationResult': result.get('verificationResult', {}),
            'documentType': result.get('documentType', 'unknown')
        }
        
        # Save to database (implementation depends on your database setup)
        # db.save_kyc_data(final_result)
        
        # Clean up temporary files
        for temp_path in document_paths.values():
            try:
                if os.path.exists(temp_path):
                    os.remove(temp_path)
            except Exception as e:
                logger.warning(f"Failed to delete temporary file {temp_path}: {str(e)}")
        
        return StandardResponse(
            statusCode=200,
            message='KYC submission processed successfully',
            data=final_result
        )
        
    except Exception as e:
        logger.error(f"Error processing KYC submission: {str(e)}")
        return StandardResponse(
            statusCode=500,
            message=f'Server error: {str(e)}',
            data={}
        )

def process_documents_with_regula(document_paths):
    """
    Process documents using Regula Document Reader API
    
    Args:
        document_paths (dict): Dictionary mapping image types to file paths
        
    Returns:
        dict: Processing results
    """
    try:
        with DocumentReaderApi(REGULA_API_HOST) as api:
            # Set up authentication
            api.api_client.default_headers = {
                "X-CLIENT-KEY": REGULA_API_KEY,
                "Authorization": f"Bearer {REGULA_AUTH_TOKEN}"
            }
            
            # Configure processing parameters
            params = ProcessParams(
                scenario=Scenario.FULL_PROCESS
            )
            
            # Prepare recognition images
            recognition_images = []
            
            for image_key, image_path in document_paths.items():
                page_index = 0
                if image_key == 'documentImage' or image_key == 'frontImage':
                    page_index = 0
                elif image_key == 'backImage':
                    page_index = 1
                
                with open(image_path, 'rb') as f:
                    image_data = f.read()
                    recognition_images.append(
                        RecognitionImage(image=image_data, light_index=Light.WHITE, page_index=page_index)
                    )
            
            # Create and process the recognition request
            request = RecognitionRequest(process_params=params, images=recognition_images)
            response = api.process(request)
            
            # Process the response
            doc_overall_status = "valid" if response.status.overall_status == 0 else "not valid"
            
            # Extract text fields
            extracted_data = {}
            for field in response.text.field_list:
                if field.field_name and field.value:
                    extracted_data[field.field_name] = field.value
            
            # Get specific fields we're interested in
            document_number = response.text.get_field(TextFieldType.DOCUMENT_NUMBER).get_value() if response.text.get_field(TextFieldType.DOCUMENT_NUMBER) else None
            document_type = response.result_by_type(result_type=Result.DOCUMENT_TYPE).one_candidate.document_name if response.result_by_type(result_type=Result.DOCUMENT_TYPE) else "Unknown"
            full_name = response.text.get_field(TextFieldType.FIRST_NAME).get_value() + " " + response.text.get_field(TextFieldType.LAST_NAME).get_value() if response.text.get_field(TextFieldType.FIRST_NAME) and response.text.get_field(TextFieldType.LAST_NAME) else None
            date_of_birth = response.text.get_field(TextFieldType.DATE_OF_BIRTH).get_value() if response.text.get_field(TextFieldType.DATE_OF_BIRTH) else None
            date_of_expiry = response.text.get_field(TextFieldType.DATE_OF_EXPIRY).get_value() if response.text.get_field(TextFieldType.DATE_OF_EXPIRY) else None
            nationality = response.text.get_field(TextFieldType.NATIONALITY).get_value() if response.text.get_field(TextFieldType.NATIONALITY) else None
            gender = response.text.get_field(TextFieldType.SEX).get_value() if response.text.get_field(TextFieldType.SEX) else None
            
            # Specific data extraction
            specific_fields = {
                'documentNumber': document_number,
                'fullName': full_name,
                'dateOfBirth': date_of_birth,
                'dateOfExpiry': date_of_expiry,
                'nationality': nationality,
                'gender': gender
            }
            
            # Extract document images (encoded as base64)
            document_images = {}
            portrait = response.images.get_field(GraphicFieldType.PORTRAIT).get_value()
            if portrait:
                document_images['portrait'] = base64.b64encode(portrait).decode('utf-8')
                
            document_front = response.images.get_field(GraphicFieldType.DOCUMENT_FRONT).get_value()
            if document_front:
                document_images['documentFront'] = base64.b64encode(document_front).decode('utf-8')
                
            # Récupérer l'image du dos du document en vérifiant si le champ existe d'abord
            doc_rear_field = response.images.get_field(GraphicFieldType.DOCUMENT_REAR)
            if doc_rear_field and doc_rear_field.get_value():
                document_images['documentBack'] = base64.b64encode(doc_rear_field.get_value()).decode('utf-8')
                
            return {
                'success': True,
                'documentType': document_type,
                'extractedData': {
                    **extracted_data,
                    **specific_fields
                },
                'processedImages': document_images,
                'verificationResult': {
                    'overallStatus': doc_overall_status
                }
            }
            
    except Exception as e:
        logger.error(f"Regula processing error: {str(e)}")
        return {
            'success': False,
            'error': f'Document processing failed: {str(e)} \nLine: {sys.exc_info()[2].tb_lineno}'
        }

class DocumentVerificationRequest(BaseModel):
    images: DocumentImages = Field(..., description="Document images in base64 format")

# Endpoints spécifiques pour chaque type de document
@router.post('/passport', response_model=StandardResponse)
async def verify_passport(request: PassportRequest):
    """
    Process passport document verification
    """
    try:
        # Save passport image to temporary file
        user_id = request.userId
        document_paths = {}
        
        # Process passport image
        try:
            image_bytes = base64.b64decode(request.passportImage)
            temp_path = os.path.join(UPLOAD_FOLDER, f"{user_id}_passport_{uuid.uuid4()}.jpg")
            with open(temp_path, 'wb') as f:
                f.write(image_bytes)
            document_paths['documentImage'] = temp_path
        except Exception as e:
            logger.error(f"Error saving passport image: {str(e)}")
            return StandardResponse(
                statusCode=400,
                message='Invalid passport image format',
                data={}
            )
            
        # Process document with Regula
        result = process_documents_with_regula(document_paths)
        
        if not result.get('success'):
            return StandardResponse(
                statusCode=400,
                message=result.get('error'),
                data={}
            )
            
        # Store additional data
        document_data = request.documentData.dict(exclude_none=True) if request.documentData else {}
        
        # Add selfie if provided
        if request.selfieImage:
            result['documentType'] = 'Passport with Selfie'
            try:
                selfie_bytes = base64.b64decode(request.selfieImage)
                if 'processedImages' not in result:
                    result['processedImages'] = {}
                result['processedImages']['selfieImage'] = request.selfieImage
            except Exception as e:
                logger.warning(f"Error processing selfie image: {str(e)}")
        else:
            result['documentType'] = 'Passport'
            
        # Merge data
        final_result = {
            'success': True,
            'userId': user_id,
            'timestamp': datetime.now().isoformat(),
            'documentData': {
                **document_data,
                **result.get('extractedData', {})
            },
            'verificationResult': result.get('verificationResult', {}),
            'documentType': result.get('documentType', 'Passport'),
            'images': result.get('processedImages', {})
        }
        
        # Clean up temporary files
        for temp_path in document_paths.values():
            try:
                if os.path.exists(temp_path):
                    os.remove(temp_path)
            except Exception as e:
                logger.warning(f"Failed to delete temporary file {temp_path}: {str(e)}")
        
        return StandardResponse(
            statusCode=200,
            message='Passport verification processed successfully',
            data=final_result
        )
        
    except Exception as e:
        logger.error(f"Error processing passport verification: {str(e)}")
        return StandardResponse(
            statusCode=500,
            message=f'Server error: {str(e)}',
            data={}
        )

@router.post('/idcard', response_model=StandardResponse)
async def verify_idcard(request: IdCardRequest):
    """
    Process ID card/driver's license verification (front and back)
    """
    try:
        # Save ID card images to temporary files
        user_id = request.userId
        document_paths = {}
        
        # Process front image
        try:
            front_bytes = base64.b64decode(request.frontImage)
            front_path = os.path.join(UPLOAD_FOLDER, f"{user_id}_front_{uuid.uuid4()}.jpg")
            with open(front_path, 'wb') as f:
                f.write(front_bytes)
            document_paths['frontImage'] = front_path
        except Exception as e:
            logger.error(f"Error saving front image: {str(e)}")
            return StandardResponse(
                statusCode=400,
                message='Invalid front image format',
                data={}
            )
            
        # Process back image
        try:
            back_bytes = base64.b64decode(request.backImage)
            back_path = os.path.join(UPLOAD_FOLDER, f"{user_id}_back_{uuid.uuid4()}.jpg")
            with open(back_path, 'wb') as f:
                f.write(back_bytes)
            document_paths['backImage'] = back_path
        except Exception as e:
            logger.error(f"Error saving back image: {str(e)}")
            return StandardResponse(
                statusCode=400,
                message='Invalid back image format',
                data={}
            )
        
        # Process document with Regula
        result = process_documents_with_regula(document_paths)
        
        if not result.get('success'):
            return StandardResponse(
                statusCode=400,
                message=result.get('error'),
                data={}
            )
            
        # Store additional data
        document_data = request.documentData.dict(exclude_none=True) if request.documentData else {}
        
        # Add selfie if provided
        if request.selfieImage:
            result['documentType'] = 'ID Card with Selfie'
            try:
                selfie_bytes = base64.b64decode(request.selfieImage)
                if 'processedImages' not in result:
                    result['processedImages'] = {}
                result['processedImages']['selfieImage'] = request.selfieImage
            except Exception as e:
                logger.warning(f"Error processing selfie image: {str(e)}")
        else:
            result['documentType'] = 'ID Card/License'
        
        # Merge data
        final_result = {
            'success': True,
            'userId': user_id,
            'timestamp': datetime.now().isoformat(),
            'documentData': {
                **document_data,
                **result.get('extractedData', {})
            },
            'verificationResult': result.get('verificationResult', {}),
            'documentType': result.get('documentType', 'ID Card/License'),
            'images': result.get('processedImages', {})
        }
        
        # Clean up temporary files
        for temp_path in document_paths.values():
            try:
                if os.path.exists(temp_path):
                    os.remove(temp_path)
            except Exception as e:
                logger.warning(f"Failed to delete temporary file {temp_path}: {str(e)}")
        
        return StandardResponse(
            statusCode=200,
            message='ID card verification processed successfully',
            data=final_result
        )
        
    except Exception as e:
        logger.error(f"Error processing ID card verification: {str(e)}")
        return StandardResponse(
            statusCode=500,
            message=f'Server error: {str(e)}',
            data={}
        )

@router.post('/selfie', response_model=StandardResponse)
async def verify_selfie(request: SelfieRequest):
    """
    Process selfie verification only (no document)
    """
    try:
        # Process selfie image
        user_id = request.userId
        
        try:
            selfie_bytes = base64.b64decode(request.selfieImage)
            selfie_path = os.path.join(UPLOAD_FOLDER, f"{user_id}_selfie_{uuid.uuid4()}.jpg")
            with open(selfie_path, 'wb') as f:
                f.write(selfie_bytes)
            
            # In a real application, you might want to process the selfie against a previously
            # stored document or use facial recognition, but for this example we'll just store it
            
            # Clean up temporary file
            if os.path.exists(selfie_path):
                os.remove(selfie_path)
                
        except Exception as e:
            logger.error(f"Error saving selfie image: {str(e)}")
            return StandardResponse(
                statusCode=400,
                message='Invalid selfie image format',
                data={}
            )
        
        # Return success response with selfie data
        final_result = {
            'success': True,
            'userId': user_id,
            'timestamp': datetime.now().isoformat(),
            'documentType': 'Selfie',
            'images': {
                'selfieImage': request.selfieImage
            }
        }
        
        return StandardResponse(
            statusCode=200,
            message='Selfie processed successfully',
            data=final_result
        )
        
    except Exception as e:
        logger.error(f"Error processing selfie: {str(e)}")
        return StandardResponse(
            statusCode=500,
            message=f'Server error: {str(e)}',
            data={}
        )

# Endpoint for generic document verification (legacy support)
@router.post('/verify', response_model=StandardResponse)
async def verify_document(verification: DocumentVerificationRequest):
    """
    Verify a document without storing the results
    Used for quick document checks before full submission
    """
    try:
        # Data is already validated by Pydantic
        images = verification.images.dict(exclude_none=True)
        
        # Save document images to temporary files
        document_paths = {}
        for image_key, image_data in images.items():
            if image_key != 'selfieImage':  # Handle document images
                if not image_data:
                    continue
                
                # Decode base64 image
                try:
                    image_bytes = base64.b64decode(image_data)
                    temp_id = uuid.uuid4()
                    temp_path = os.path.join(UPLOAD_FOLDER, f"verify_{image_key}_{temp_id}.jpg")
                    with open(temp_path, 'wb') as f:
                        f.write(image_bytes)
                    document_paths[image_key] = temp_path
                except Exception as e:
                    logger.error(f"Error saving image {image_key}: {str(e)}")
                    return StandardResponse(
                        statusCode=400,
                        message=f'Invalid image format for {image_key}',
                        data={}
                    )
        
        # Process document with Regula
        result = process_documents_with_regula(document_paths)
        
        # Clean up temporary files
        for temp_path in document_paths.values():
            try:
                if os.path.exists(temp_path):
                    os.remove(temp_path)
            except Exception as e:
                logger.warning(f"Failed to delete temporary file {temp_path}: {str(e)}")
        
        if result.get('success'):
            return StandardResponse(
                statusCode=200,
                message='Document verification processed successfully',
                data=result
            )
        else:
            return StandardResponse(
                statusCode=400,
                message=result.get('error'),
                data={}
            )
            
    except Exception as e:
        logger.error(f"Error processing document verification: {str(e)}")
        return StandardResponse(
            statusCode=500,
            message=f'Server error: {str(e)}',
            data={}
        )