import React, { useState, useEffect } from 'react';
import {
  Grid,
  Card,
  CardContent,
  Typography,
  Box,
  Paper,
  CircularProgress,
  Alert
} from '@mui/material';
import {
  People,
  School,
  Palette,
  Quiz
} from '@mui/icons-material';
import DashboardLayout from '../components/DashboardLayout';
import { apiService } from '../services/api';

interface DashboardStats {
  users_count: number;
  themes_count: number;
  levels_count: number;
  questions_count: number;
  last_updated: string;
}

const DashboardPage: React.FC = () => {
  const [stats, setStats] = useState<DashboardStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const fetchStats = async () => {
      try {
        setLoading(true);
        const data = await apiService.getDashboardStats();
        setStats(data);
        setError(null);
      } catch (err) {
        console.error('Erreur lors du chargement des statistiques:', err);
        setError('Impossible de charger les statistiques');
      } finally {
        setLoading(false);
      }
    };

    fetchStats();
  }, []);

  const getStatsCards = () => {
    if (!stats) return [];
    
    return [
      { title: 'Utilisateurs', value: stats.users_count.toString(), icon: <People />, color: '#1976d2' },
      { title: 'Thèmes', value: stats.themes_count.toString(), icon: <Palette />, color: '#f57c00' },
      { title: 'Niveaux', value: stats.levels_count.toString(), icon: <School />, color: '#388e3c' },
      { title: 'Questions', value: stats.questions_count.toString(), icon: <Quiz />, color: '#7b1fa2' },
    ];
  };

  return (
    <DashboardLayout title="Tableau de bord">
      <Box>
        <Typography variant="h4" gutterBottom>
          Bienvenue dans le panneau d'administration
        </Typography>
        <Typography variant="body1" color="text.secondary" paragraph>
          Gérez votre plateforme Civica depuis ce tableau de bord.
        </Typography>

        {loading && (
          <Box display="flex" justifyContent="center" my={4}>
            <CircularProgress />
          </Box>
        )}
        
        {error && (
          <Alert severity="error" sx={{ mb: 2 }}>
            {error}
          </Alert>
        )}
        
        {!loading && !error && stats && (
          <>
            <Grid container spacing={3} sx={{ mt: 2 }}>
              {getStatsCards().map((stat, index) => (
                <Grid item xs={12} sm={6} md={3} key={index}>
                  <Card>
                    <CardContent>
                      <Box display="flex" alignItems="center" justifyContent="space-between">
                        <Box>
                          <Typography color="text.secondary" gutterBottom>
                            {stat.title}
                          </Typography>
                          <Typography variant="h4" component="div">
                            {stat.value}
                          </Typography>
                        </Box>
                        <Box
                          sx={{
                            backgroundColor: stat.color,
                            borderRadius: '50%',
                            width: 56,
                            height: 56,
                            display: 'flex',
                            alignItems: 'center',
                            justifyContent: 'center',
                            color: 'white'
                          }}
                        >
                          {stat.icon}
                        </Box>
                      </Box>
                    </CardContent>
                  </Card>
                </Grid>
              ))}
            </Grid>

            <Grid container spacing={3} sx={{ mt: 3 }}>
              <Grid item xs={12} md={8}>
                <Paper sx={{ p: 3 }}>
                  <Typography variant="h6" gutterBottom>
                    Activité récente
                  </Typography>
                  <Typography color="text.secondary">
                    Aucune activité récente à afficher.
                  </Typography>
                </Paper>
              </Grid>
              <Grid item xs={12} md={4}>
                <Paper sx={{ p: 3 }}>
                  <Typography variant="h6" gutterBottom>
                    Actions rapides
                  </Typography>
                  <Typography color="text.secondary">
                    Utilisez le menu latéral pour naviguer vers les différentes sections.
                  </Typography>
                </Paper>
              </Grid>
            </Grid>
          </>
        )}
      </Box>
    </DashboardLayout>
  );
};

export default DashboardPage;
