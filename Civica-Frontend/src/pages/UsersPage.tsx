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
  Select,
  MenuItem,
  FormControl,
  InputLabel,
  Chip
} from '@mui/material';
import { Edit, Delete, Add } from '@mui/icons-material';
import DashboardLayout from '../components/DashboardLayout';
import { User } from '../types';

const UsersPage: React.FC = () => {
  const [users, setUsers] = useState<User[]>([
    {
      id: '1',
      username: 'admin',
      email: 'admin@civica.com',
      role: 'admin',
      points: 0,
      currentLevel: 1,
      createdAt: '2024-01-01'
    },
    {
      id: '2',
      username: 'user1',
      email: 'user1@example.com',
      role: 'user',
      points: 150,
      currentLevel: 2,
      createdAt: '2024-01-15'
    },
    {
      id: '3',
      username: 'user2',
      email: 'user2@example.com',
      role: 'user',
      points: 75,
      currentLevel: 1,
      createdAt: '2024-02-01'
    }
  ]);

  const [open, setOpen] = useState(false);
  const [editingUser, setEditingUser] = useState<User | null>(null);
  const [formData, setFormData] = useState({
    username: '',
    email: '',
    role: 'user' as 'admin' | 'user',
    points: 0,
    currentLevel: 1
  });

  const handleAdd = () => {
    setEditingUser(null);
    setFormData({
      username: '',
      email: '',
      role: 'user',
      points: 0,
      currentLevel: 1
    });
    setOpen(true);
  };

  const handleEdit = (user: User) => {
    setEditingUser(user);
    setFormData({
      username: user.username,
      email: user.email,
      role: user.role,
      points: user.points,
      currentLevel: user.currentLevel
    });
    setOpen(true);
  };

  const handleSave = () => {
    if (editingUser) {
      // Update existing user
      setUsers(users.map(user => 
        user.id === editingUser.id 
          ? { ...user, ...formData }
          : user
      ));
    } else {
      // Add new user
      const newUser: User = {
        id: Date.now().toString(),
        ...formData,
        createdAt: new Date().toISOString().split('T')[0]
      };
      setUsers([...users, newUser]);
    }
    setOpen(false);
  };

  const handleDelete = (userId: string) => {
    setUsers(users.filter(user => user.id !== userId));
  };

  return (
    <DashboardLayout title="Gestion des utilisateurs">
      <Box>
        <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
          <Typography variant="h4">Utilisateurs</Typography>
          <Button
            variant="contained"
            startIcon={<Add />}
            onClick={handleAdd}
          >
            Ajouter un utilisateur
          </Button>
        </Box>

        <TableContainer component={Paper}>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>Nom d'utilisateur</TableCell>
                <TableCell>Email</TableCell>
                <TableCell>Rôle</TableCell>
                <TableCell>Points</TableCell>
                <TableCell>Niveau</TableCell>
                <TableCell>Date de création</TableCell>
                <TableCell>Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {users.map((user) => (
                <TableRow key={user.id}>
                  <TableCell>{user.username}</TableCell>
                  <TableCell>{user.email}</TableCell>
                  <TableCell>
                    <Chip 
                      label={user.role} 
                      color={user.role === 'admin' ? 'primary' : 'default'}
                      size="small"
                    />
                  </TableCell>
                  <TableCell>{user.points}</TableCell>
                  <TableCell>{user.currentLevel}</TableCell>
                  <TableCell>{user.createdAt}</TableCell>
                  <TableCell>
                    <IconButton onClick={() => handleEdit(user)} size="small">
                      <Edit />
                    </IconButton>
                    <IconButton 
                      onClick={() => handleDelete(user.id)} 
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
            {editingUser ? 'Modifier l\'utilisateur' : 'Ajouter un utilisateur'}
          </DialogTitle>
          <DialogContent>
            <TextField
              fullWidth
              label="Nom d'utilisateur"
              value={formData.username}
              onChange={(e) => setFormData({...formData, username: e.target.value})}
              margin="normal"
            />
            <TextField
              fullWidth
              label="Email"
              type="email"
              value={formData.email}
              onChange={(e) => setFormData({...formData, email: e.target.value})}
              margin="normal"
            />
            <FormControl fullWidth margin="normal">
              <InputLabel>Rôle</InputLabel>
              <Select
                value={formData.role}
                onChange={(e) => setFormData({...formData, role: e.target.value as 'admin' | 'user'})}
              >
                <MenuItem value="user">Utilisateur</MenuItem>
                <MenuItem value="admin">Administrateur</MenuItem>
              </Select>
            </FormControl>
            <TextField
              fullWidth
              label="Points"
              type="number"
              value={formData.points}
              onChange={(e) => setFormData({...formData, points: parseInt(e.target.value) || 0})}
              margin="normal"
            />
            <TextField
              fullWidth
              label="Niveau actuel"
              type="number"
              value={formData.currentLevel}
              onChange={(e) => setFormData({...formData, currentLevel: parseInt(e.target.value) || 1})}
              margin="normal"
            />
          </DialogContent>
          <DialogActions>
            <Button onClick={() => setOpen(false)}>Annuler</Button>
            <Button onClick={handleSave} variant="contained">
              {editingUser ? 'Modifier' : 'Ajouter'}
            </Button>
          </DialogActions>
        </Dialog>
      </Box>
    </DashboardLayout>
  );
};

export default UsersPage;
