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
  Select,
  MenuItem,
  FormControl,
  InputLabel,
  Chip,
  CircularProgress,
  Alert,
  Snackbar,
  Switch,
  FormControlLabel,
  InputAdornment
} from '@mui/material';
import { Edit, Delete, Add, Search, Clear, Refresh } from '@mui/icons-material';
import DashboardLayout from '../components/DashboardLayout';
import { User } from '../types';
import { apiService } from '../services/api';

// Type for form data (subset of User for editing)
type UserFormData = {
  spseudo?: string;
  email: string;
  role: 'USER' | 'ADMIN';
  status: 'ACTIVE' | 'INACTIVE';
  is_verified: 'YES' | 'NO';
  connexion_type: 'EMAIL' | 'PHONE' | 'GOOGLE' | 'FACEBOOK';
  point: number;
  niveaux: number;
  vies: number;
  is_deleted: boolean;
};

const UsersPage: React.FC = () => {
  const [users, setUsers] = useState<User[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [searchEmail, setSearchEmail] = useState('');
  const [snackbar, setSnackbar] = useState<{
    open: boolean;
    message: string;
    severity: 'success' | 'error' | 'info' | 'warning';
  }>({ open: false, message: '', severity: 'info' });
  const [submitting, setSubmitting] = useState(false);

  const [open, setOpen] = useState(false);
  const [editingUser, setEditingUser] = useState<User | null>(null);
  const [formData, setFormData] = useState<UserFormData>({
    spseudo: '',
    email: '',
    role: 'USER',
    status: 'ACTIVE',
    is_verified: 'NO',
    connexion_type: 'EMAIL',
    point: 0,
    niveaux: 1,
    vies: 3,
    is_deleted: false
  });

  // Utility functions
  const showSnackbar = (message: string, severity: 'success' | 'error' | 'info' | 'warning') => {
    setSnackbar({ open: true, message, severity });
  };

  const handleCloseSnackbar = () => {
    setSnackbar({ ...snackbar, open: false });
  };

  // Load users from API
  const loadUsers = async (email?: string) => {
    try {
      setLoading(true);
      setError(null);
      const data = await apiService.getUsers(email);
      // Ensure data is always an array
      const usersArray = Array.isArray(data) ? data : [];
      setUsers(usersArray);
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erreur lors du chargement des utilisateurs';
      setError(errorMessage);
      showSnackbar(errorMessage, 'error');
      // Set empty array on error to prevent map errors
      setUsers([]);
    } finally {
      setLoading(false);
    }
  };

  // Load users on component mount
  useEffect(() => {
    loadUsers();
  }, []);

  // Search users by email
  const handleSearch = () => {
    loadUsers(searchEmail || undefined);
  };

  const handleClearSearch = () => {
    setSearchEmail('');
    loadUsers();
  };

  const handleRefresh = () => {
    loadUsers(searchEmail || undefined);
  };

  const handleAdd = () => {
    setEditingUser(null);
    const newFormData: UserFormData = {
      spseudo: '',
      email: '',
      role: 'USER',
      status: 'ACTIVE',
      is_verified: 'NO',
      connexion_type: 'EMAIL',
      point: 0,
      niveaux: 1,
      vies: 3,
      is_deleted: false
    };
    setFormData(newFormData);
    setOpen(true);
  };

  const handleEdit = (user: User) => {
    setEditingUser(user);
    const editFormData: UserFormData = {
      spseudo: user.spseudo || '',
      email: user.email,
      role: user.role,
      status: user.status,
      is_verified: user.is_verified,
      connexion_type: user.connexion_type,
      point: user.point,
      niveaux: user.niveaux,
      vies: user.vies,
      is_deleted: user.is_deleted
    };
    setFormData(editFormData);
    setOpen(true);
  };

  const handleSave = async () => {
    if (!formData.email.trim()) {
      showSnackbar('L\'email est requis', 'error');
      return;
    }

    try {
      setSubmitting(true);
      
      if (editingUser) {
        // Update existing user
        const updatedUser = await apiService.updateUser(editingUser.id, formData);
        setUsers(users.map(user => 
          user.id === editingUser.id ? updatedUser : user
        ));
        showSnackbar('Utilisateur mis à jour avec succès', 'success');
      } else {
        // Note: User creation is typically done through registration endpoint
        showSnackbar('La création d\'utilisateurs se fait via l\'inscription', 'info');
      }
      
      setOpen(false);
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erreur lors de la sauvegarde';
      showSnackbar(errorMessage, 'error');
    } finally {
      setSubmitting(false);
    }
  };

  const handleDelete = async (userId: string) => {
    if (!window.confirm('Êtes-vous sûr de vouloir supprimer cet utilisateur ?')) {
      return;
    }

    try {
      await apiService.deleteUser(userId);
      setUsers(users.filter(user => user.id !== userId));
      showSnackbar('Utilisateur supprimé avec succès', 'success');
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erreur lors de la suppression';
      showSnackbar(errorMessage, 'error');
    }
  };

  const getRoleColor = (role: string) => {
    return role === 'ADMIN' ? 'error' : 'default';
  };

  const getStatusColor = (status: string) => {
    return status === 'ACTIVE' ? 'success' : 'default';
  };

  const getVerificationColor = (isVerified: string) => {
    return isVerified === 'YES' ? 'success' : 'warning';
  };

  if (loading) {
    return (
      <DashboardLayout title="Gestion des Utilisateurs">
        <Box sx={{ display: 'flex', justifyContent: 'center', alignItems: 'center', height: '50vh' }}>
          <CircularProgress />
        </Box>
      </DashboardLayout>
    );
  }

  return (
    <DashboardLayout title="Gestion des Utilisateurs">
      <Box sx={{ p: 3 }}>
        <Typography variant="h4" gutterBottom>
          Gestion des Utilisateurs
        </Typography>

        {error && (
          <Alert severity="error" sx={{ mb: 2 }}>
            {error}
          </Alert>
        )}

        <Box sx={{ mb: 3, display: 'flex', gap: 2, alignItems: 'center', flexWrap: 'wrap' }}>
          <TextField
            label="Rechercher par email"
            value={searchEmail}
            onChange={(e) => setSearchEmail(e.target.value)}
            size="small"
            sx={{ minWidth: 250 }}
            InputProps={{
              endAdornment: (
                <InputAdornment position="end">
                  <IconButton onClick={handleSearch} size="small">
                    <Search />
                  </IconButton>
                  {searchEmail && (
                    <IconButton onClick={handleClearSearch} size="small">
                      <Clear />
                    </IconButton>
                  )}
                </InputAdornment>
              ),
            }}
            onKeyPress={(e) => e.key === 'Enter' && handleSearch()}
          />
          <Button
            variant="outlined"
            startIcon={<Refresh />}
            onClick={handleRefresh}
          >
            Actualiser
          </Button>
          <Button
            variant="contained"
            startIcon={<Add />}
            onClick={handleAdd}
            color="primary"
          >
            Ajouter un utilisateur
          </Button>
        </Box>

        <Paper>
          <TableContainer>
            <Table>
              <TableHead>
                <TableRow>
                  <TableCell>Pseudo</TableCell>
                  <TableCell>Email</TableCell>
                  <TableCell>Rôle</TableCell>
                  <TableCell>Statut</TableCell>
                  <TableCell>Vérifié</TableCell>
                  <TableCell>Points</TableCell>
                  <TableCell>Niveau</TableCell>
                  <TableCell>Vies</TableCell>
                  <TableCell>Date de création</TableCell>
                  <TableCell align="center">Actions</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {!Array.isArray(users) || users.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={10} align="center">
                      <Typography variant="body2" color="text.secondary">
                        Aucun utilisateur trouvé
                      </Typography>
                    </TableCell>
                  </TableRow>
                ) : (
                  users.map((user) => (
                    <TableRow key={user.id}>
                      <TableCell>{user.spseudo || 'N/A'}</TableCell>
                      <TableCell>{user.email}</TableCell>
                      <TableCell>
                        <Chip 
                          label={user.role} 
                          color={getRoleColor(user.role) as any}
                          size="small"
                        />
                      </TableCell>
                      <TableCell>
                        <Chip 
                          label={user.status} 
                          color={getStatusColor(user.status) as any}
                          size="small"
                        />
                      </TableCell>
                      <TableCell>
                        <Chip 
                          label={user.is_verified} 
                          color={getVerificationColor(user.is_verified) as any}
                          size="small"
                        />
                      </TableCell>
                      <TableCell>{user.point}</TableCell>
                      <TableCell>{user.niveaux}</TableCell>
                      <TableCell>{user.vies}</TableCell>
                      <TableCell>
                        {new Date(user.created_at).toLocaleDateString('fr-FR')}
                      </TableCell>
                      <TableCell align="center">
                        <IconButton
                          onClick={() => handleEdit(user)}
                          color="primary"
                          size="small"
                        >
                          <Edit />
                        </IconButton>
                        <IconButton
                          onClick={() => handleDelete(user.id)}
                          color="error"
                          size="small"
                        >
                          <Delete />
                        </IconButton>
                      </TableCell>
                    </TableRow>
                  ))
                )}
              </TableBody>
            </Table>
          </TableContainer>
        </Paper>

        {/* Dialog for Edit User */}
        <Dialog open={open} onClose={() => setOpen(false)} maxWidth="sm" fullWidth>
          <DialogTitle>
            {editingUser ? 'Modifier l\'utilisateur' : 'Ajouter un utilisateur'}
          </DialogTitle>
          <DialogContent>
            <Box sx={{ display: 'flex', flexDirection: 'column', gap: 2, pt: 1 }}>
              <TextField
                label="Pseudo"
                value={formData.spseudo}
                onChange={(e) => setFormData({ ...formData, spseudo: e.target.value })}
                fullWidth
              />
              <TextField
                label="Email"
                type="email"
                value={formData.email}
                onChange={(e) => setFormData({ ...formData, email: e.target.value })}
                fullWidth
                required
              />
              <FormControl fullWidth>
                <InputLabel>Rôle</InputLabel>
                <Select
                  value={formData.role}
                  label="Rôle"
                  onChange={(e) => setFormData({ ...formData, role: e.target.value as 'USER' | 'ADMIN' })}
                >
                  <MenuItem value="USER">Utilisateur</MenuItem>
                  <MenuItem value="ADMIN">Administrateur</MenuItem>
                </Select>
              </FormControl>
              <FormControl fullWidth>
                <InputLabel>Statut</InputLabel>
                <Select
                  value={formData.status}
                  label="Statut"
                  onChange={(e) => setFormData({ ...formData, status: e.target.value as 'ACTIVE' | 'INACTIVE' })}
                >
                  <MenuItem value="ACTIVE">Actif</MenuItem>
                  <MenuItem value="INACTIVE">Inactif</MenuItem>
                </Select>
              </FormControl>
              <FormControl fullWidth>
                <InputLabel>Vérifié</InputLabel>
                <Select
                  value={formData.is_verified}
                  label="Vérifié"
                  onChange={(e) => setFormData({ ...formData, is_verified: e.target.value as 'YES' | 'NO' })}
                >
                  <MenuItem value="YES">Oui</MenuItem>
                  <MenuItem value="NO">Non</MenuItem>
                </Select>
              </FormControl>
              <TextField
                label="Points"
                type="number"
                value={formData.point}
                onChange={(e) => setFormData({ ...formData, point: parseInt(e.target.value) || 0 })}
                fullWidth
              />
              <TextField
                label="Niveau"
                type="number"
                value={formData.niveaux}
                onChange={(e) => setFormData({ ...formData, niveaux: parseInt(e.target.value) || 1 })}
                fullWidth
              />
              <TextField
                label="Vies"
                type="number"
                value={formData.vies}
                onChange={(e) => setFormData({ ...formData, vies: parseInt(e.target.value) || 3 })}
                fullWidth
              />
              <FormControlLabel
                control={
                  <Switch
                    checked={!formData.is_deleted}
                    onChange={(e) => setFormData({ ...formData, is_deleted: !e.target.checked })}
                  />
                }
                label="Utilisateur actif"
              />
            </Box>
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
              {submitting ? <CircularProgress size={20} /> : (editingUser ? 'Modifier' : 'Ajouter')}
            </Button>
          </DialogActions>
        </Dialog>

        {/* Snackbar for notifications */}
        <Snackbar
          open={snackbar.open}
          autoHideDuration={6000}
          onClose={handleCloseSnackbar}
          anchorOrigin={{ vertical: 'bottom', horizontal: 'right' }}
        >
          <Alert onClose={handleCloseSnackbar} severity={snackbar.severity}>
            {snackbar.message}
          </Alert>
        </Snackbar>
      </Box>
    </DashboardLayout>
  );
};

export default UsersPage;
