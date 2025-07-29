#!/usr/bin/env python3
import base64
import os
from cryptography.hazmat.primitives.ciphers import Cipher, algorithms, modes
from cryptography.hazmat.backends import default_backend

# Clés de chiffrement (doivent correspondre à celles utilisées dans l'application Flutter)
KEY = b"kufulismartlockislachoixaveczaza"[:32]  # AES-256 nécessite une clé de 32 octets
# IV fixe correspondant à celui utilisé dans Flutter
IV = b"hellotoutlemonde"[:16]  # IV de 16 octets

def pad(data):
    """Ajouter du padding PKCS7 aux données"""
    padding_length = 16 - (len(data) % 16)
    padding = bytes([padding_length]) * padding_length
    return data + padding

def unpad(data):
    """Supprimer le padding PKCS7 des données"""
    padding_length = data[-1]
    return data[:-padding_length]

def encrypt(text):
    """Chiffrer un texte avec AES-CBC"""
    if isinstance(text, str):
        text = text.encode('utf-8')
    
    # Ajouter du padding
    padded_data = pad(text)
    
    # Créer le chiffreur
    backend = default_backend()
    cipher = Cipher(algorithms.AES(KEY), modes.CBC(IV), backend=backend)
    encryptor = cipher.encryptor()
    
    # Chiffrer les données
    encrypted_data = encryptor.update(padded_data) + encryptor.finalize()
    
    # Encoder en base64 pour faciliter le stockage/transmission
    return base64.b64encode(encrypted_data).decode('utf-8')

def decrypt(encrypted_text):
    """Déchiffrer un texte chiffré avec AES-CBC"""
    if isinstance(encrypted_text, str):
        encrypted_data = base64.b64decode(encrypted_text)
    else:
        encrypted_data = encrypted_text
    
    # Créer le déchiffreur
    backend = default_backend()
    cipher = Cipher(algorithms.AES(KEY), modes.CBC(IV), backend=backend)
    decryptor = cipher.decryptor()
    
    # Déchiffrer les données
    decrypted_padded_data = decryptor.update(encrypted_data) + decryptor.finalize()
    
    # Supprimer le padding
    decrypted_data = unpad(decrypted_padded_data)
    
    # Convertir en chaîne de caractères
    return decrypted_data.decode('utf-8')

# Exemple d'utilisation
# if __name__ == "__main__":
#     # Test de chiffrement/déchiffrement
#     original_text = "Ceci est un test de chiffrement pour EasyLifePay"
#     encrypted = encrypt(original_text)
#     decrypted = decrypt(encrypted)
    
#     print(f"Texte original: {original_text}")
#     print(f"Texte chiffré: {encrypted}")
#     print(f"Texte déchiffré: {decrypted}")
#     print(f"Les textes correspondent: {original_text == decrypted}")