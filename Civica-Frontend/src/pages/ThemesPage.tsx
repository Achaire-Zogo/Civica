import React, { useState } from 'react';
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
  Avatar
} from '@mui/material';
import { Edit, Delete, Add } from '@mui/icons-material';
import DashboardLayout from '../components/DashboardLayout';
import { Theme } from '../types';

const ThemesPage: React.FC = () => {
  const [themes, setThemes] = useState<Theme[]>([
    {
      id: '1',
      name: 'Histoire de France',
      description: 'Questions sur l\'histoire française',
      color: '#1976d2',
      isActive: true
    },
    {
      id: '2',
      name: 'Géographie',
      description: 'Connaissances géographiques générales',
      color: '#388e3c',
      isActive: true
    },
    {
      id: '3',
      name: 'Institutions',
      description: 'Fonctionnement des institutions françaises',
      color: '#f57c00',
      isActive: true
    },
    {
      id: '4',
      name: 'Culture générale',
      description: 'Questions de culture générale',
      color: '#7b1fa2',
      isActive: false
    }
  ]);

  const [open, setOpen] = useState(false);
  const [editingTheme, setEditingTheme] = useState<Theme | null>(null);
  const [formData, setFormData] = useState({
    name: '',
    description: '',
    color: '#1976d2',
    isActive: true
  });

  const handleAdd = () => {
    setEditingTheme(null);
    setFormData({
      name: '',
      description: '',
      color: '#1976d2',
      isActive: true
    });
    setOpen(true);
  };

  const handleEdit = (theme: Theme) => {
    setEditingTheme(theme);
    setFormData({
      name: theme.name,
      description: theme.description,
      color: theme.color,
      isActive: theme.isActive
    });
    setOpen(true);
  };

  const handleSave = () => {
    if (editingTheme) {
      setThemes(themes.map(theme => 
        theme.id === editingTheme.id 
          ? { ...theme, ...formData }
          : theme
      ));
    } else {
      const newTheme: Theme = {
        id: Date.now().toString(),
        ...formData
      };
      setThemes([...themes, newTheme]);
    }
    setOpen(false);
  };

  const handleDelete = (themeId: string) => {
    setThemes(themes.filter(theme => theme.id !== themeId));
  };

  const toggleActive = (themeId: string) => {
    setThemes(themes.map(theme =>
      theme.id === themeId
        ? { ...theme, isActive: !theme.isActive }
        : theme
    ));
  };

  return (
    <DashboardLayout title="Gestion des thèmes">
      <Box>
        <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
          <Typography variant="h4">Thèmes</Typography>
          <Button
            variant="contained"
            startIcon={<Add />}
            onClick={handleAdd}
          >
            Ajouter un thème
          </Button>
        </Box>

        <Typography variant="body2" color="text.secondary" paragraph>
          Organisez vos questions par thèmes pour une meilleure structure du contenu.
        </Typography>

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
              {themes.map((theme) => (
                <TableRow key={theme.id}>
                  <TableCell>
                    <Box display="flex" alignItems="center" gap={2}>
                      <Avatar
                        sx={{ 
                          bgcolor: theme.color, 
                          width: 32, 
                          height: 32,
                          fontSize: '0.875rem'
                        }}
                      >
                        {theme.name.charAt(0).toUpperCase()}
                      </Avatar>
                      <Typography variant="subtitle2">{theme.name}</Typography>
                    </Box>
                  </TableCell>
                  <TableCell>{theme.description}</TableCell>
                  <TableCell>
                    <Box display="flex" alignItems="center" gap={1}>
                      <Box
                        sx={{
                          width: 20,
                          height: 20,
                          borderRadius: '50%',
                          backgroundColor: theme.color,
                          border: '1px solid #ccc'
                        }}
                      />
                      <Typography variant="caption" color="text.secondary">
                        {theme.color}
                      </Typography>
                    </Box>
                  </TableCell>
                  <TableCell>
                    <FormControlLabel
                      control={
                        <Switch
                          checked={theme.isActive}
                          onChange={() => toggleActive(theme.id)}
                          size="small"
                        />
                      }
                      label={
                        <Chip 
                          label={theme.isActive ? 'Actif' : 'Inactif'} 
                          color={theme.isActive ? 'success' : 'default'}
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
              ))}
            </TableBody>
          </Table>
        </TableContainer>

        <Dialog open={open} onClose={() => setOpen(false)} maxWidth="sm" fullWidth>
          <DialogTitle>
            {editingTheme ? 'Modifier le thème' : 'Ajouter un thème'}
          </DialogTitle>
          <DialogContent>
            <TextField
              fullWidth
              label="Nom du thème"
              value={formData.name}
              onChange={(e) => setFormData({...formData, name: e.target.value})}
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
            <Button onClick={() => setOpen(false)}>Annuler</Button>
            <Button onClick={handleSave} variant="contained">
              {editingTheme ? 'Modifier' : 'Ajouter'}
            </Button>
          </DialogActions>
        </Dialog>
      </Box>
    </DashboardLayout>
  );
};

export default ThemesPage;
