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
  Chip
} from '@mui/material';
import { Edit, Delete, Add, ArrowUpward, ArrowDownward } from '@mui/icons-material';
import DashboardLayout from '../components/DashboardLayout';
import { Level } from '../types';

const LevelsPage: React.FC = () => {
  const [levels, setLevels] = useState<Level[]>([
    {
      id: '1',
      name: 'Débutant',
      requiredPoints: 0,
      description: 'Niveau de base pour commencer',
      order: 1
    },
    {
      id: '2',
      name: 'Intermédiaire',
      requiredPoints: 100,
      description: 'Niveau pour utilisateurs avec quelques connaissances',
      order: 2
    },
    {
      id: '3',
      name: 'Avancé',
      requiredPoints: 250,
      description: 'Niveau pour utilisateurs expérimentés',
      order: 3
    },
    {
      id: '4',
      name: 'Expert',
      requiredPoints: 500,
      description: 'Niveau le plus élevé',
      order: 4
    }
  ]);

  const [open, setOpen] = useState(false);
  const [editingLevel, setEditingLevel] = useState<Level | null>(null);
  const [formData, setFormData] = useState({
    name: '',
    requiredPoints: 0,
    description: '',
    order: 1
  });

  const handleAdd = () => {
    setEditingLevel(null);
    setFormData({
      name: '',
      requiredPoints: 0,
      description: '',
      order: levels.length + 1
    });
    setOpen(true);
  };

  const handleEdit = (level: Level) => {
    setEditingLevel(level);
    setFormData({
      name: level.name,
      requiredPoints: level.requiredPoints,
      description: level.description,
      order: level.order
    });
    setOpen(true);
  };

  const handleSave = () => {
    if (editingLevel) {
      setLevels(levels.map(level => 
        level.id === editingLevel.id 
          ? { ...level, ...formData }
          : level
      ));
    } else {
      const newLevel: Level = {
        id: Date.now().toString(),
        ...formData
      };
      setLevels([...levels, newLevel]);
    }
    setOpen(false);
  };

  const handleDelete = (levelId: string) => {
    setLevels(levels.filter(level => level.id !== levelId));
  };

  const moveLevel = (levelId: string, direction: 'up' | 'down') => {
    const levelIndex = levels.findIndex(l => l.id === levelId);
    if (levelIndex === -1) return;

    const newLevels = [...levels];
    const targetIndex = direction === 'up' ? levelIndex - 1 : levelIndex + 1;

    if (targetIndex >= 0 && targetIndex < levels.length) {
      [newLevels[levelIndex], newLevels[targetIndex]] = [newLevels[targetIndex], newLevels[levelIndex]];
      
      // Update order numbers
      newLevels[levelIndex].order = levelIndex + 1;
      newLevels[targetIndex].order = targetIndex + 1;
      
      setLevels(newLevels);
    }
  };

  const sortedLevels = [...levels].sort((a, b) => a.order - b.order);

  return (
    <DashboardLayout title="Gestion des niveaux">
      <Box>
        <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
          <Typography variant="h4">Niveaux</Typography>
          <Button
            variant="contained"
            startIcon={<Add />}
            onClick={handleAdd}
          >
            Ajouter un niveau
          </Button>
        </Box>

        <Typography variant="body2" color="text.secondary" paragraph>
          Configurez les niveaux et les points requis pour que les utilisateurs puissent progresser.
        </Typography>

        <TableContainer component={Paper}>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>Ordre</TableCell>
                <TableCell>Nom</TableCell>
                <TableCell>Points requis</TableCell>
                <TableCell>Description</TableCell>
                <TableCell>Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {sortedLevels.map((level, index) => (
                <TableRow key={level.id}>
                  <TableCell>
                    <Box display="flex" alignItems="center" gap={1}>
                      <Chip label={level.order} size="small" />
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
                    <Typography variant="subtitle2">{level.name}</Typography>
                  </TableCell>
                  <TableCell>
                    <Chip 
                      label={`${level.requiredPoints} pts`} 
                      color="primary" 
                      variant="outlined"
                      size="small"
                    />
                  </TableCell>
                  <TableCell>{level.description}</TableCell>
                  <TableCell>
                    <IconButton onClick={() => handleEdit(level)} size="small">
                      <Edit />
                    </IconButton>
                    <IconButton 
                      onClick={() => handleDelete(level.id)} 
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
            {editingLevel ? 'Modifier le niveau' : 'Ajouter un niveau'}
          </DialogTitle>
          <DialogContent>
            <TextField
              fullWidth
              label="Nom du niveau"
              value={formData.name}
              onChange={(e) => setFormData({...formData, name: e.target.value})}
              margin="normal"
            />
            <TextField
              fullWidth
              label="Points requis"
              type="number"
              value={formData.requiredPoints}
              onChange={(e) => setFormData({...formData, requiredPoints: parseInt(e.target.value) || 0})}
              margin="normal"
              helperText="Nombre de points nécessaires pour atteindre ce niveau"
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
            <TextField
              fullWidth
              label="Ordre"
              type="number"
              value={formData.order}
              onChange={(e) => setFormData({...formData, order: parseInt(e.target.value) || 1})}
              margin="normal"
              helperText="Position du niveau dans la hiérarchie"
            />
          </DialogContent>
          <DialogActions>
            <Button onClick={() => setOpen(false)}>Annuler</Button>
            <Button onClick={handleSave} variant="contained">
              {editingLevel ? 'Modifier' : 'Ajouter'}
            </Button>
          </DialogActions>
        </Dialog>
      </Box>
    </DashboardLayout>
  );
};

export default LevelsPage;
