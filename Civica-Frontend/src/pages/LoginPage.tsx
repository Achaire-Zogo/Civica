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
  Paper
} from '@mui/material';
import { useAuth } from '../contexts/AuthContext';
import { useNavigate } from 'react-router-dom';

const LoginPage: React.FC = () => {
  const [username, setUsername] = useState('');
  const [password, setPassword] = useState('');
  const [error, setError] = useState('');
  const { login, isLoading } = useAuth();
  const navigate = useNavigate();

  const handleSubmit = async (e: React.FormEvent) => {
    e.preventDefault();
    setError('');

    if (!username || !password) {
      setError('Veuillez remplir tous les champs');
      return;
    }

    const success = await login(username, password);
    if (success) {
      navigate('/dashboard');
    } else {
      setError('Nom d\'utilisateur ou mot de passe incorrect');
    }
  };

  return (
    <Container maxWidth="sm">
      <Box
        sx={{
          minHeight: '100vh',
          display: 'flex',
          alignItems: 'center',
          justifyContent: 'center',
          background: 'linear-gradient(135deg, #667eea 0%, #764ba2 100%)'
        }}
      >
        <Paper elevation={10} sx={{ width: '100%', maxWidth: 400 }}>
          <Card>
            <CardContent sx={{ p: 4 }}>
              <Box textAlign="center" mb={3}>
                <Typography variant="h4" component="h1" gutterBottom color="primary">
                  Civica Admin
                </Typography>
                <Typography variant="body2" color="text.secondary">
                  Connectez-vous pour accéder au panneau d'administration
                </Typography>
              </Box>

              <form onSubmit={handleSubmit}>
                <TextField
                  fullWidth
                  label="Nom d'utilisateur"
                  variant="outlined"
                  margin="normal"
                  value={username}
                  onChange={(e) => setUsername(e.target.value)}
                  disabled={isLoading}
                />
                
                <TextField
                  fullWidth
                  label="Mot de passe"
                  type="password"
                  variant="outlined"
                  margin="normal"
                  value={password}
                  onChange={(e) => setPassword(e.target.value)}
                  disabled={isLoading}
                />

                {error && (
                  <Alert severity="error" sx={{ mt: 2 }}>
                    {error}
                  </Alert>
                )}

                <Button
                  type="submit"
                  fullWidth
                  variant="contained"
                  size="large"
                  disabled={isLoading}
                  sx={{ mt: 3, mb: 2 }}
                >
                  {isLoading ? 'Connexion...' : 'Se connecter'}
                </Button>
              </form>

              <Box textAlign="center" mt={2}>
                <Typography variant="caption" color="text.secondary">
                  Utilisez admin/admin pour vous connecter
                </Typography>
              </Box>
            </CardContent>
          </Card>
        </Paper>
      </Box>
    </Container>
  );
};

export default LoginPage;
