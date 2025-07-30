import React, { useState } from 'react';
import {
  Box,
  Paper,
  Typography,
  TextField,
  Button,
  Avatar,
  Grid,
  Card,
  CardContent,
  Divider
} from '@mui/material';
import { Person, Email, AdminPanelSettings } from '@mui/icons-material';
import DashboardLayout from '../components/DashboardLayout';
import { useAuth } from '../contexts/AuthContext';

const ProfilePage: React.FC = () => {
  const { user } = useAuth();
  const [isEditing, setIsEditing] = useState(false);
  const [formData, setFormData] = useState({
    spseudo: user?.spseudo || '',
    email: user?.email || '',
  });

  const handleSave = () => {
    // Here you would typically update the user profile via API
    console.log('Saving profile:', formData);
    setIsEditing(false);
  };

  const handleCancel = () => {
    setFormData({
      spseudo: user?.spseudo || '',
      email: user?.email || '',
    });
    setIsEditing(false);
  };

  return (
    <DashboardLayout title="Profil utilisateur">
      <Box>
        <Typography variant="h4" gutterBottom>
          Mon Profil
        </Typography>

        <Grid container spacing={3}>
          <Grid item xs={12} md={4}>
            <Card>
              <CardContent sx={{ textAlign: 'center', p: 4 }}>
                <Avatar
                  sx={{
                    width: 120,
                    height: 120,
                    mx: 'auto',
                    mb: 2,
                    bgcolor: 'primary.main',
                    fontSize: '3rem'
                  }}
                >
                  {user?.spseudo?.charAt(0).toUpperCase() || 'A'}
                </Avatar>
                <Typography variant="h5" gutterBottom>
                  {user?.spseudo || 'Admin'}
                </Typography>
                <Typography variant="body2" color="text.secondary" gutterBottom>
                  {user?.email || 'admin@civica.com'}
                </Typography>
                <Typography 
                  variant="caption" 
                  sx={{ 
                    bgcolor: user?.role === 'ADMIN' ? 'primary.main' : 'grey.300',
                    color: user?.role === 'ADMIN' ? 'white' : 'black',
                    px: 2,
                    py: 0.5,
                    borderRadius: 1,
                    display: 'inline-block'
                  }}
                >
                  {user?.role === 'ADMIN' ? 'Administrateur' : 'Utilisateur'}
                </Typography>
              </CardContent>
            </Card>
          </Grid>

          <Grid item xs={12} md={8}>
            <Card>
              <CardContent>
                <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
                  <Typography variant="h6">
                    Informations personnelles
                  </Typography>
                  {!isEditing ? (
                    <Button
                      variant="outlined"
                      onClick={() => setIsEditing(true)}
                    >
                      Modifier
                    </Button>
                  ) : (
                    <Box>
                      <Button
                        variant="outlined"
                        onClick={handleCancel}
                        sx={{ mr: 1 }}
                      >
                        Annuler
                      </Button>
                      <Button
                        variant="contained"
                        onClick={handleSave}
                      >
                        Sauvegarder
                      </Button>
                    </Box>
                  )}
                </Box>

                <Divider sx={{ mb: 3 }} />

                <Grid container spacing={3}>
                  <Grid item xs={12} sm={6}>
                    <TextField
                      fullWidth
                      label="Pseudo"
                      value={formData.spseudo}
                      onChange={(e) => setFormData({...formData, spseudo: e.target.value})}
                      disabled={!isEditing}
                      InputProps={{
                        startAdornment: <Person sx={{ mr: 1, color: 'text.secondary' }} />
                      }}
                    />
                  </Grid>
                  <Grid item xs={12} sm={6}>
                    <TextField
                      fullWidth
                      label="Email"
                      type="email"
                      value={formData.email}
                      onChange={(e) => setFormData({...formData, email: e.target.value})}
                      disabled={!isEditing}
                      InputProps={{
                        startAdornment: <Email sx={{ mr: 1, color: 'text.secondary' }} />
                      }}
                    />
                  </Grid>
                </Grid>

                <Box mt={4}>
                  <Typography variant="h6" gutterBottom>
                    Statistiques
                  </Typography>
                  <Divider sx={{ mb: 2 }} />
                  <Grid container spacing={2}>
                    <Grid item xs={12} sm={4}>
                      <Paper sx={{ p: 2, textAlign: 'center' }}>
                        <Typography variant="h4" color="primary">
                          {user?.point || 0}
                        </Typography>
                        <Typography variant="body2" color="text.secondary">
                          Points totaux
                        </Typography>
                      </Paper>
                    </Grid>
                    <Grid item xs={12} sm={4}>
                      <Paper sx={{ p: 2, textAlign: 'center' }}>
                        <Typography variant="h4" color="success.main">
                          {user?.niveaux || 1}
                        </Typography>
                        <Typography variant="body2" color="text.secondary">
                          Niveau actuel
                        </Typography>
                      </Paper>
                    </Grid>
                    <Grid item xs={12} sm={4}>
                      <Paper sx={{ p: 2, textAlign: 'center' }}>
                        <Typography variant="h4" color="info.main">
                          {user?.role === 'ADMIN' ? '∞' : '0'}
                        </Typography>
                        <Typography variant="body2" color="text.secondary">
                          Quiz complétés
                        </Typography>
                      </Paper>
                    </Grid>
                  </Grid>
                </Box>
              </CardContent>
            </Card>
          </Grid>
        </Grid>
      </Box>
    </DashboardLayout>
  );
};

export default ProfilePage;
