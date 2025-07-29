import React, { useState } from 'react';
import {
  Box,
  Card,
  CardContent,
  TextField,
  Button,
  Typography,
  Alert,
  Container,
  Paper,
  InputAdornment,
  IconButton,
  Link,
  Divider,
  CircularProgress
} from '@mui/material';
import {
  Visibility,
  VisibilityOff,
  Email,
  Lock,
  Business,
  TrendingUp,
  Security
} from '@mui/icons-material';
import { useNavigate } from 'react-router-dom';
import authService from '../services/authService';

const LoginPage: React.FC = () => {
  const [email, setEmail] = useState('');
  const [password, setPassword] = useState('');
  const [showPassword, setShowPassword] = useState(false);
  const [error, setError] = useState('');
  const [isLoading, setIsLoading] = useState(false);
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');
    setIsLoading(true);

    if (!email || !password) {
      setError('Veuillez remplir tous les champs');
      setIsLoading(false);
      return;
    }

    try {
      const result = await authService.login({ email, password });
      
      if (result.success) {
        console.log(result);
        navigate('/dashboard', { replace: true });
      } else {
        setError(result.message);
      }
    } catch (err) {
      setError('Une erreur est survenue');
    } finally {
      setIsLoading(false);
    }
  };

  return (
    <Box
      sx={{
        minHeight: '100vh',
        display: 'flex',
        background: 'linear-gradient(135deg, #1e3c72 0%, #2a5298 100%)',
        position: 'relative',
        overflow: 'hidden'
      }}
    >
      {/* Left Side - Hero Section */}
      <Box
        sx={{
          flex: 1,
          display: { xs: 'none', md: 'flex' },
          flexDirection: 'column',
          justifyContent: 'center',
          alignItems: 'flex-start',
          padding: '80px 60px',
          color: 'white',
          position: 'relative',
          '&::before': {
            content: '""',
            position: 'absolute',
            top: 0,
            left: 0,
            right: 0,
            bottom: 0,
            background: 'url("data:image/svg+xml,%3Csvg width="60" height="60" viewBox="0 0 60 60" xmlns="http://www.w3.org/2000/svg"%3E%3Cg fill="none" fill-rule="evenodd"%3E%3Cg fill="%23ffffff" fill-opacity="0.05"%3E%3Ccircle cx="30" cy="30" r="4"/%3E%3C/g%3E%3C/g%3E%3C/svg%3E")',
            opacity: 0.3
          }
        }}
      >
        <Box sx={{ position: 'relative', zIndex: 1 }}>
          <Typography
            variant="h2"
            sx={{
              fontWeight: 'bold',
              marginBottom: 3,
              fontSize: { md: '3rem', lg: '3.5rem' },
              lineHeight: 1.2
            }}
          >
            Rejoignez +25 000 entreprises et propulser votre croissance
          </Typography>
          
          <Box sx={{ display: 'flex', alignItems: 'center', gap: 4, marginTop: 4 }}>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
              <Business sx={{ fontSize: 40, color: '#4CAF50' }} />
              <Typography variant="body1">Gestion simplifiée</Typography>
            </Box>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
              <TrendingUp sx={{ fontSize: 40, color: '#FF9800' }} />
              <Typography variant="body1">Croissance rapide</Typography>
            </Box>
            <Box sx={{ display: 'flex', alignItems: 'center', gap: 1 }}>
              <Security sx={{ fontSize: 40, color: '#2196F3' }} />
              <Typography variant="body1">Sécurisé</Typography>
            </Box>
          </Box>
        </Box>
      </Box>

      {/* Right Side - Login Form */}
      <Box
        sx={{
          flex: { xs: 1, md: 0.6 },
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          padding: { xs: 2, sm: 4 },
          backgroundColor: 'white',
          position: 'relative'
        }}
      >
        <Paper elevation={10} sx={{ width: '100%', maxWidth: 450, borderRadius: 3 }}>
          <CardContent sx={{ padding: 4 }}>
            {/* Logo/Brand Section */}
            <Box sx={{ textAlign: 'center', marginBottom: 4 }}>
              <Typography
                variant="h4"
                sx={{
                  fontWeight: 'bold',
                  color: '#1e3c72',
                  marginBottom: 1
                }}
              >
                CiviQuizz
              </Typography>
              <Typography
                variant="h6"
                sx={{
                  color: '#666',
                  fontWeight: 500
                }}
              >
                Nous sommes heureux de vous revoir
              </Typography>
              <Typography
                variant="body2"
                sx={{
                  color: '#999',
                  marginTop: 1
                }}
              >
                Veuillez vous connecter à votre compte pour accéder au tableau de bord
              </Typography>
            </Box>

            {/* Error Alert */}
            {error && (
              <Alert severity="error" sx={{ marginBottom: 3, borderRadius: 2 }}>
                {error}
              </Alert>
            )}

            {/* Login Form */}
            <Box component="form" onSubmit={handleSubmit}>
              {/* Email Field */}
              <TextField
                fullWidth
                label="Adresse e-mail"
                type="email"
                value={email}
                onChange={(e) => setEmail(e.target.value)}
                margin="normal"
                required
                InputProps={{
                  startAdornment: (
                    <InputAdornment position="start">
                      <Email sx={{ color: '#666' }} />
                    </InputAdornment>
                  ),
                }}
                sx={{
                  '& .MuiOutlinedInput-root': {
                    borderRadius: 2,
                    '&:hover fieldset': {
                      borderColor: '#1e3c72',
                    },
                    '&.Mui-focused fieldset': {
                      borderColor: '#1e3c72',
                    },
                  },
                }}
              />



              {/* Password Field */}
              <TextField
                fullWidth
                label="Mot de passe"
                type={showPassword ? 'text' : 'password'}
                value={password}
                onChange={(e) => setPassword(e.target.value)}
                margin="normal"
                required
                InputProps={{
                  startAdornment: (
                    <InputAdornment position="start">
                      <Lock sx={{ color: '#666' }} />
                    </InputAdornment>
                  ),
                  endAdornment: (
                    <InputAdornment position="end">
                      <IconButton
                        onClick={() => setShowPassword(!showPassword)}
                        edge="end"
                      >
                        {showPassword ? <VisibilityOff /> : <Visibility />}
                      </IconButton>
                    </InputAdornment>
                  ),
                }}
                sx={{
                  '& .MuiOutlinedInput-root': {
                    borderRadius: 2,
                    '&:hover fieldset': {
                      borderColor: '#1e3c72',
                    },
                    '&.Mui-focused fieldset': {
                      borderColor: '#1e3c72',
                    },
                  },
                }}
              />

              {/* Forgot Password Link */}
              <Box sx={{ textAlign: 'right', marginTop: 1, marginBottom: 2 }}>
                <Link
                  href="#"
                  sx={{
                    color: '#1e3c72',
                    textDecoration: 'none',
                    fontSize: '0.875rem',
                    '&:hover': {
                      textDecoration: 'underline',
                    },
                  }}
                >
                  Mot de passe oublié ?
                </Link>
              </Box>

              {/* Submit Button */}
              <Button
                type="submit"
                fullWidth
                variant="contained"
                disabled={isLoading}
                sx={{
                  marginTop: 3,
                  marginBottom: 2,
                  padding: '12px',
                  borderRadius: 2,
                  backgroundColor: '#FF4444',
                  fontSize: '1rem',
                  fontWeight: 'bold',
                  textTransform: 'none',
                  '&:hover': {
                    backgroundColor: '#e63939',
                  },
                  '&:disabled': {
                    backgroundColor: '#ccc',
                  },
                }}
              >
                {isLoading ? (
                  <CircularProgress size={24} color="inherit" />
                ) : (
                  'Connexion'
                )}
              </Button>


            </Box>
          </CardContent>
        </Paper>
      </Box>
    </Box>
  );
};

export default LoginPage;
