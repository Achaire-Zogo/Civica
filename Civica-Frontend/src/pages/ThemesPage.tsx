import React, { useState, useEffect } from 'react';
import {
  Box,
  Paper,
  Table,
  TableBody,
  TableCell,
  TableContainer,
  TableHead,
  TableRow,
  Button,
  Typography,
  IconButton,
  Dialog,
  DialogTitle,
  DialogContent,
  DialogActions,
  TextField,
  Switch,
  FormControlLabel,
  Chip,
  Avatar,
  CircularProgress,
  Alert,
  Snackbar
} from '@mui/material';
import { Edit, Delete, Add, Refresh } from '@mui/icons-material';
import DashboardLayout from '../components/DashboardLayout';
import { Theme } from '../types';
import { apiService } from '../services/api';

const ThemesPage: React.FC = () => {
  const [themes, setThemes] = useState<Theme[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' as 'success' | 'error' });

  const [open, setOpen] = useState(false);
  const [editingTheme, setEditingTheme] = useState<Theme | null>(null);
  const [formData, setFormData] = useState({
    title: '',
    description: '',
    color: '#1976d2',
    isActive: true
  });
  const [submitting, setSubmitting] = useState(false);

  // Load themes from API on component mount
  useEffect(() => {
    loadThemes();
  }, []);

  const loadThemes = async () => {
    try {
      setLoading(true);
      setError(null);
      const themesData = await apiService.getThemes();
      setThemes(themesData);
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erreur lors du chargement des thèmes';
      setError(errorMessage);
      showSnackbar(errorMessage, 'error');
    } finally {
      setLoading(false);
    }
  };

  const showSnackbar = (message: string, severity: 'success' | 'error') => {
    setSnackbar({ open: true, message, severity });
  };

  const closeSnackbar = () => {
    setSnackbar({ ...snackbar, open: false });
  };

  const handleAdd = () => {
    setEditingTheme(null);
    setFormData({
      title: '',
      description: '',
      color: '#1976d2',
      isActive: true
    });
    setOpen(true);
  };

  const handleEdit = (theme: Theme) => {
    setEditingTheme(theme);
    setFormData({
      title: theme.title,
      description: theme.description,
      color: theme.color,
      isActive: theme.isActive
    });
    setOpen(true);
  };

  const handleSave = async () => {
    if (!formData.title.trim() || !formData.description.trim()) {
      showSnackbar('Veuillez remplir tous les champs obligatoires', 'error');
      return;
    }

    try {
      setSubmitting(true);
      
      if (editingTheme) {
        // Update existing theme
        const updatedTheme = await apiService.updateTheme(editingTheme.id, formData);
        setThemes(themes.map(theme => 
          theme.id === editingTheme.id ? updatedTheme : theme
        ));
        showSnackbar('Thème modifié avec succès', 'success');
      } else {
        // Create new theme
        const newTheme = await apiService.createTheme(formData);
        setThemes([...themes, newTheme]);
        showSnackbar('Thème créé avec succès', 'success');
      }
      
      setOpen(false);
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erreur lors de la sauvegarde';
      showSnackbar(errorMessage, 'error');
    } finally {
      setSubmitting(false);
    }
  };

  const handleDelete = async (id: number) => {
    if (!window.confirm('Êtes-vous sûr de vouloir supprimer ce thème ?')) {
      return;
    }

    try {
      await apiService.deleteTheme(id);
      setThemes(themes.filter(theme => theme.id !== id));
      showSnackbar('Thème supprimé avec succès', 'success');
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erreur lors de la suppression';
      showSnackbar(errorMessage, 'error');
    }
  };

  const toggleActive = async (themeId: number) => {
    const theme = themes.find(t => t.id === themeId);
    if (!theme) return;

    try {
      const updatedTheme = await apiService.updateTheme(themeId, {
        isActive: !theme.isActive
      });
      setThemes(themes.map(t => 
        t.id === themeId ? updatedTheme : t
      ));
      showSnackbar(`Thème ${updatedTheme.isActive ? 'activé' : 'désactivé'} avec succès`, 'success');
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erreur lors de la modification';
      showSnackbar(errorMessage, 'error');
    }
  };

  return (
    <DashboardLayout title="Gestion des thèmes">
      <Box>
        <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
          <Typography variant="h4">Thèmes</Typography>
          <Box display="flex" gap={2}>
            <Button
              variant="outlined"
              startIcon={<Refresh />}
              onClick={loadThemes}
              disabled={loading}
            >
              Actualiser
            </Button>
            <Button
              variant="contained"
              startIcon={<Add />}
              onClick={handleAdd}
              disabled={loading}
            >
              Ajouter un thème
            </Button>
          </Box>
        </Box>

        <Typography variant="body2" color="text.secondary" paragraph>
          Organisez vos questions par thèmes pour une meilleure structure du contenu.
        </Typography>

        {error && (
          <Alert severity="error" sx={{ mb: 2 }}>
            {error}
          </Alert>
        )}

        {loading ? (
          <Box display="flex" justifyContent="center" alignItems="center" minHeight={200}>
            <CircularProgress />
          </Box>
        ) : (
          <TableContainer component={Paper}>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>Thème</TableCell>
                <TableCell>Description</TableCell>
                <TableCell>Couleur</TableCell>
                <TableCell>Statut</TableCell>
                <TableCell>Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {themes.map((theme) => {
                // Vérifications de sécurité pour éviter les erreurs
                const safeName = theme?.title || 'Sans nom';
                const safeDescription = theme?.description || 'Aucune description';
                const safeColor = theme?.color || '#1976d2';
                const safeIsActive = theme?.isActive ?? true;
                
                return (
                <TableRow key={theme.id}>
                  <TableCell>
                    <Box display="flex" alignItems="center" gap={2}>
                      <Avatar
                        sx={{ 
                          bgcolor: safeColor, 
                          width: 32, 
                          height: 32,
                          fontSize: '0.875rem'
                        }}
                      >
                        {safeName.charAt(0).toUpperCase()}
                      </Avatar>
                      <Typography variant="subtitle2">{safeName}</Typography>
                    </Box>
                  </TableCell>
                  <TableCell>{safeDescription}</TableCell>
                  <TableCell>
                    <Box display="flex" alignItems="center" gap={1}>
                      <Box
                        sx={{
                          width: 20,
                          height: 20,
                          borderRadius: '50%',
                          backgroundColor: safeColor,
                          border: '1px solid #ccc'
                        }}
                      />
                      <Typography variant="caption" color="text.secondary">
                        {safeColor}
                      </Typography>
                    </Box>
                  </TableCell>
                  <TableCell>
                    <FormControlLabel
                      control={
                        <Switch
                          checked={safeIsActive}
                          onChange={() => toggleActive(theme.id)}
                          size="small"
                        />
                      }
                      label={
                        <Chip 
                          label={safeIsActive ? 'Actif' : 'Inactif'} 
                          color={safeIsActive ? 'success' : 'default'}
                          size="small"
                        />
                      }
                    />
                  </TableCell>
                  <TableCell>
                    <IconButton onClick={() => handleEdit(theme)} size="small">
                      <Edit />
                    </IconButton>
                    <IconButton 
                      onClick={() => handleDelete(theme.id)} 
                      size="small"
                      color="error"
                    >
                      <Delete />
                    </IconButton>
                  </TableCell>
                </TableRow>
                );
              })}
            </TableBody>
          </Table>
        </TableContainer>
        )}

        <Dialog open={open} onClose={() => setOpen(false)} maxWidth="sm" fullWidth>
          <DialogTitle>
            {editingTheme ? 'Modifier le thème' : 'Ajouter un thème'}
          </DialogTitle>
          <DialogContent>
            <TextField
              fullWidth
              label="Nom du thème"
              value={formData.title}
              onChange={(e) => setFormData({...formData, title: e.target.value})}
              margin="normal"
            />
            <TextField
              fullWidth
              label="Description"
              multiline
              rows={3}
              value={formData.description}
              onChange={(e) => setFormData({...formData, description: e.target.value})}
              margin="normal"
            />
            <Box display="flex" alignItems="center" gap={2} mt={2}>
              <TextField
                label="Couleur"
                type="color"
                value={formData.color}
                onChange={(e) => setFormData({...formData, color: e.target.value})}
                sx={{ width: 100 }}
              />
              <Box
                sx={{
                  width: 40,
                  height: 40,
                  borderRadius: '50%',
                  backgroundColor: formData.color,
                  border: '1px solid #ccc'
                }}
              />
            </Box>
            <FormControlLabel
              control={
                <Switch
                  checked={formData.isActive}
                  onChange={(e) => setFormData({...formData, isActive: e.target.checked})}
                />
              }
              label="Thème actif"
              sx={{ mt: 2 }}
            />
          </DialogContent>
          <DialogActions>
            <Button onClick={() => setOpen(false)} disabled={submitting}>
              Annuler
            </Button>
            <Button 
              onClick={handleSave} 
              variant="contained"
              disabled={submitting}
              startIcon={submitting ? <CircularProgress size={20} /> : null}
            >
              {submitting ? 'En cours...' : (editingTheme ? 'Modifier' : 'Ajouter')}
            </Button>
          </DialogActions>
        </Dialog>

        <Snackbar
          open={snackbar.open}
          autoHideDuration={6000}
          onClose={closeSnackbar}
          anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }}
        >
          <Alert onClose={closeSnackbar} severity={snackbar.severity} sx={{ width: '100%' }}>
            {snackbar.message}
          </Alert>
        </Snackbar>
      </Box>
    </DashboardLayout>
  );
};

export default ThemesPage;
