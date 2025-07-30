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
  Chip,
  CircularProgress,
  Alert,
  Snackbar,
  Select,
  MenuItem,
  FormControl,
  InputLabel,
  Switch,
  FormControlLabel,
  Checkbox
} from '@mui/material';
import { Edit, Delete, Add, ArrowUpward, ArrowDownward, Refresh } from '@mui/icons-material';
import DashboardLayout from '../components/DashboardLayout';
import { Level, Theme } from '../types';
import { apiService } from '../services/api';

const LevelsPage: React.FC = () => {
  const [levels, setLevels] = useState<Level[]>([]);
  const [themes, setThemes] = useState<Theme[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' as 'success' | 'error' });
  const [selectedThemeId, setSelectedThemeId] = useState<string>('');

  const [open, setOpen] = useState(false);
  const [editingLevel, setEditingLevel] = useState<Level | null>(null);
  const [formData, setFormData] = useState({
    theme_id: '',
    title: '',
    description: '',
    difficulty: 'easy' as 'easy' | 'medium' | 'hard',
    order_index: 0,
    is_active: true,
    min_score_to_unlock: 0
  });
  const [submitting, setSubmitting] = useState(false);

  // Load data from API on component mount
  useEffect(() => {
    loadInitialData();
  }, []);

  useEffect(() => {
    if (selectedThemeId) {
      loadLevels(selectedThemeId);
    }
  }, [selectedThemeId]);

  const loadInitialData = async () => {
    try {
      setLoading(true);
      setError(null);
      const themesData = await apiService.getThemes();
      setThemes(themesData);
      
      // Load all levels initially
      const levelsData = await apiService.getLevels();
      setLevels(levelsData);
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erreur lors du chargement des données';
      setError(errorMessage);
      showSnackbar(errorMessage, 'error');
    } finally {
      setLoading(false);
    }
  };

  const loadLevels = async (themeId?: string) => {
    try {
      setLoading(true);
      setError(null);
      const levelsData = await apiService.getLevels(themeId);
      setLevels(levelsData);
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erreur lors du chargement des niveaux';
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
    setEditingLevel(null);
    setFormData({
      theme_id: selectedThemeId || (themes.length > 0 ? themes[0].id.toString() : ''),
      title: '',
      description: '',
      difficulty: 'easy',
      order_index: levels.length,
      is_active: true,
      min_score_to_unlock: 0
    });
    setOpen(true);
  };

  const handleEdit = (level: Level) => {
    setEditingLevel(level);
    setFormData({
      theme_id: level.theme_id,
      title: level.title,
      description: level.description || '',
      difficulty: level.difficulty,
      order_index: level.order_index,
      is_active: level.is_active,
      min_score_to_unlock: level.min_score_to_unlock
    });
    setOpen(true);
  };

  const handleSave = async () => {
    if (!formData.title.trim()) {
      showSnackbar('Le titre est requis', 'error');
      return;
    }

    try {
      setSubmitting(true);
      
      if (editingLevel) {
        // Update existing level
        const updatedLevel = await apiService.updateLevel(editingLevel.id, formData);
        setLevels(levels.map(level => 
          level.id === editingLevel.id ? updatedLevel : level
        ));
        showSnackbar('Niveau mis à jour avec succès', 'success');
      } else {
        // Create new level
        const newLevel = await apiService.createLevel(formData);
        setLevels([...levels, newLevel]);
        showSnackbar('Niveau créé avec succès', 'success');
      }
      
      setOpen(false);
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erreur lors de la sauvegarde';
      showSnackbar(errorMessage, 'error');
    } finally {
      setSubmitting(false);
    }
  };

  const handleDelete = async (levelId: string) => {
    if (!window.confirm('Êtes-vous sûr de vouloir supprimer ce niveau ?')) {
      return;
    }

    try {
      await apiService.deleteLevel(levelId);
      setLevels(levels.filter(level => level.id !== levelId));
      showSnackbar('Niveau supprimé avec succès', 'success');
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erreur lors de la suppression';
      showSnackbar(errorMessage, 'error');
    }
  };

  const moveLevel = (levelId: string, direction: 'up' | 'down') => {
    const levelIndex = levels.findIndex(l => l.id === levelId);
    if (levelIndex === -1) return;

    const newLevels = [...levels];
    const targetIndex = direction === 'up' ? levelIndex - 1 : levelIndex + 1;

    if (targetIndex >= 0 && targetIndex < levels.length) {
      [newLevels[levelIndex], newLevels[targetIndex]] = [newLevels[targetIndex], newLevels[levelIndex]];
      
      // Update order numbers
      newLevels[levelIndex].order_index = levelIndex + 1;
      newLevels[targetIndex].order_index = targetIndex + 1;
      
      setLevels(newLevels);
    }
  };

  const sortedLevels = [...levels].sort((a, b) => a.order_index - b.order_index);

  return (
    <DashboardLayout title="Gestion des niveaux">
      <Box>
        <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
          <Typography variant="h4">Niveaux</Typography>
          <Box display="flex" gap={2} alignItems="center">
            <FormControl size="small" sx={{ minWidth: 200 }}>
              <InputLabel>Filtrer par thème</InputLabel>
              <Select
                value={selectedThemeId}
                label="Filtrer par thème"
                onChange={(e) => setSelectedThemeId(e.target.value)}
              >
                <MenuItem value="">
                  <em>Tous les thèmes</em>
                </MenuItem>
                {themes.map((theme) => (
                  <MenuItem key={theme.id} value={theme.id.toString()}>
                    {theme.title}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>
            <IconButton onClick={() => loadLevels(selectedThemeId)} disabled={loading}>
              <Refresh />
            </IconButton>
            <Button
              variant="contained"
              startIcon={<Add />}
              onClick={handleAdd}
              disabled={loading}
            >
              Ajouter un niveau
            </Button>
          </Box>
        </Box>

        <Typography variant="body2" color="text.secondary" paragraph>
          Configurez les niveaux et les scores requis pour que les utilisateurs puissent progresser dans chaque thème.
        </Typography>

        {error && (
          <Alert severity="error" sx={{ mb: 2 }}>
            {error}
          </Alert>
        )}

        {loading && (
          <Box display="flex" justifyContent="center" my={4}>
            <CircularProgress />
          </Box>
        )}

        {!loading && (
          <TableContainer component={Paper}>
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell>Ordre</TableCell>
                  <TableCell>Titre</TableCell>
                  <TableCell>Thème</TableCell>
                  <TableCell>Difficulté</TableCell>
                  <TableCell>Score min</TableCell>
                  <TableCell>Statut</TableCell>
                  <TableCell>Description</TableCell>
                  <TableCell>Actions</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {sortedLevels.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={8} align="center">
                      <Typography color="text.secondary">
                        {selectedThemeId ? 'Aucun niveau trouvé pour ce thème' : 'Aucun niveau trouvé'}
                      </Typography>
                    </TableCell>
                  </TableRow>
                ) : (
                  sortedLevels.map((level, index) => {
                    const theme = themes.find(t => t.id.toString() === level.theme_id);
                    return (
                      <TableRow key={level.id}>
                        <TableCell>
                          <Box display="flex" alignItems="center" gap={1}>
                            <Chip label={level.order_index} size="small" />
                            <IconButton 
                              size="small" 
                              onClick={() => moveLevel(level.id, 'up')}
                              disabled={index === 0}
                            >
                              <ArrowUpward fontSize="small" />
                            </IconButton>
                            <IconButton 
                              size="small" 
                              onClick={() => moveLevel(level.id, 'down')}
                              disabled={index === sortedLevels.length - 1}
                            >
                              <ArrowDownward fontSize="small" />
                            </IconButton>
                          </Box>
                        </TableCell>
                        <TableCell>
                          <Typography variant="body2" fontWeight="medium">
                            {level.title}
                          </Typography>
                        </TableCell>
                        <TableCell>
                          <Typography variant="body2" color="text.secondary">
                            {theme?.title || 'Thème inconnu'}
                          </Typography>
                        </TableCell>
                        <TableCell>
                          <Chip 
                            label={level.difficulty} 
                            size="small"
                            color={level.difficulty === 'easy' ? 'success' : level.difficulty === 'medium' ? 'warning' : 'error'}
                          />
                        </TableCell>
                        <TableCell>{level.min_score_to_unlock}</TableCell>
                        <TableCell>
                          <Chip 
                            label={level.is_active ? 'Actif' : 'Inactif'} 
                            size="small"
                            color={level.is_active ? 'success' : 'default'}
                          />
                        </TableCell>
                        <TableCell>
                          <Typography variant="body2" color="text.secondary">
                            {level.description || 'Aucune description'}
                          </Typography>
                        </TableCell>
                        <TableCell>
                          <IconButton onClick={() => handleEdit(level)} size="small">
                            <Edit />
                          </IconButton>
                          <IconButton onClick={() => handleDelete(level.id)} size="small" color="error">
                            <Delete />
                          </IconButton>
                        </TableCell>
                      </TableRow>
                    );
                  })
                )}
              </TableBody>
            </Table>
          </TableContainer>
        )}

        <Dialog open={open} onClose={() => setOpen(false)} maxWidth="sm" fullWidth>
          <DialogTitle>
            {editingLevel ? 'Modifier le niveau' : 'Ajouter un niveau'}
          </DialogTitle>
          <DialogContent>
            <FormControl fullWidth margin="normal">
              <InputLabel>Thème</InputLabel>
              <Select
                value={formData.theme_id}
                label="Thème"
                onChange={(e) => setFormData({...formData, theme_id: e.target.value})}
              >
                {themes.map((theme) => (
                  <MenuItem key={theme.id} value={theme.id.toString()}>
                    {theme.title}
                  </MenuItem>
                ))}
              </Select>
            </FormControl>
            <TextField
              fullWidth
              label="Titre du niveau"
              value={formData.title}
              onChange={(e) => setFormData({...formData, title: e.target.value})}
              margin="normal"
              required
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
            <FormControl fullWidth margin="normal">
              <InputLabel>Difficulté</InputLabel>
              <Select
                value={formData.difficulty}
                label="Difficulté"
                onChange={(e) => setFormData({...formData, difficulty: e.target.value as 'easy' | 'medium' | 'hard'})}
              >
                <MenuItem value="easy">Facile</MenuItem>
                <MenuItem value="medium">Moyen</MenuItem>
                <MenuItem value="hard">Difficile</MenuItem>
              </Select>
            </FormControl>
            <TextField
              fullWidth
              label="Ordre d'affichage"
              type="number"
              value={formData.order_index}
              onChange={(e) => setFormData({...formData, order_index: parseInt(e.target.value) || 0})}
              margin="normal"
            />
            <TextField
              fullWidth
              label="Score minimum pour débloquer"
              type="number"
              value={formData.min_score_to_unlock}
              onChange={(e) => setFormData({...formData, min_score_to_unlock: parseInt(e.target.value) || 0})}
              margin="normal"
            />
            <FormControlLabel
              control={
                <Checkbox
                  checked={formData.is_active}
                  onChange={(e) => setFormData({...formData, is_active: e.target.checked})}
                />
              }
              label="Niveau actif"
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
            >
              {submitting ? 'Sauvegarde...' : (editingLevel ? 'Modifier' : 'Ajouter')}
            </Button>
          </DialogActions>
        </Dialog>

        <Snackbar
          open={snackbar.open}
          autoHideDuration={6000}
          onClose={closeSnackbar}
        >
          <Alert onClose={closeSnackbar} severity={snackbar.severity}>
            {snackbar.message}
          </Alert>
        </Snackbar>
      </Box>
    </DashboardLayout>
  );
};

export default LevelsPage;
