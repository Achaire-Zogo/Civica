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
  Chip,
  List,
  ListItem,
  ListItemText,
  ListItemSecondaryAction
} from '@mui/material';
import { Edit, Delete, Add, Remove } from '@mui/icons-material';
import DashboardLayout from '../components/DashboardLayout';
import { Question } from '../types';

const QuestionsPage: React.FC = () => {
  const [questions, setQuestions] = useState<Question[]>([
    {
      id: '1',
      text: 'Quelle est la capitale de la France ?',
      options: ['Paris', 'Lyon', 'Marseille', 'Toulouse'],
      correctAnswer: 0,
      points: 10,
      themeId: '2',
      levelId: '1',
      difficulty: 'easy'
    },
    {
      id: '2',
      text: 'En quelle année a eu lieu la Révolution française ?',
      options: ['1789', '1792', '1799', '1804'],
      correctAnswer: 0,
      points: 15,
      themeId: '1',
      levelId: '2',
      difficulty: 'medium'
    }
  ]);

  const [open, setOpen] = useState(false);
  const [editingQuestion, setEditingQuestion] = useState<Question | null>(null);
  const [formData, setFormData] = useState({
    text: '',
    options: ['', '', '', ''],
    correctAnswer: 0,
    points: 10,
    themeId: '1',
    levelId: '1',
    difficulty: 'easy' as 'easy' | 'medium' | 'hard'
  });

  // Mock data for themes and levels
  const themes = [
    { id: '1', name: 'Histoire de France' },
    { id: '2', name: 'Géographie' },
    { id: '3', name: 'Institutions' }
  ];

  const levels = [
    { id: '1', name: 'Débutant' },
    { id: '2', name: 'Intermédiaire' },
    { id: '3', name: 'Avancé' }
  ];

  const handleAdd = () => {
    setEditingQuestion(null);
    setFormData({
      text: '',
      options: ['', '', '', ''],
      correctAnswer: 0,
      points: 10,
      themeId: '1',
      levelId: '1',
      difficulty: 'easy'
    });
    setOpen(true);
  };

  const handleEdit = (question: Question) => {
    setEditingQuestion(question);
    setFormData({
      text: question.text,
      options: [...question.options],
      correctAnswer: question.correctAnswer,
      points: question.points,
      themeId: question.themeId,
      levelId: question.levelId,
      difficulty: question.difficulty
    });
    setOpen(true);
  };

  const handleSave = () => {
    if (editingQuestion) {
      setQuestions(questions.map(question => 
        question.id === editingQuestion.id 
          ? { ...question, ...formData }
          : question
      ));
    } else {
      const newQuestion: Question = {
        id: Date.now().toString(),
        ...formData
      };
      setQuestions([...questions, newQuestion]);
    }
    setOpen(false);
  };

  const handleDelete = (questionId: string) => {
    setQuestions(questions.filter(question => question.id !== questionId));
  };

  const updateOption = (index: number, value: string) => {
    const newOptions = [...formData.options];
    newOptions[index] = value;
    setFormData({ ...formData, options: newOptions });
  };

  const addOption = () => {
    if (formData.options.length < 6) {
      setFormData({ ...formData, options: [...formData.options, ''] });
    }
  };

  const removeOption = (index: number) => {
    if (formData.options.length > 2) {
      const newOptions = formData.options.filter((_, i) => i !== index);
      setFormData({ 
        ...formData, 
        options: newOptions,
        correctAnswer: formData.correctAnswer >= newOptions.length ? 0 : formData.correctAnswer
      });
    }
  };

  const getDifficultyColor = (difficulty: string) => {
    switch (difficulty) {
      case 'easy': return 'success';
      case 'medium': return 'warning';
      case 'hard': return 'error';
      default: return 'default';
    }
  };

  const getThemeName = (themeId: string) => {
    return themes.find(t => t.id === themeId)?.name || 'Inconnu';
  };

  const getLevelName = (levelId: string) => {
    return levels.find(l => l.id === levelId)?.name || 'Inconnu';
  };

  return (
    <DashboardLayout title="Gestion des questions">
      <Box>
        <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
          <Typography variant="h4">Questions</Typography>
          <Button
            variant="contained"
            startIcon={<Add />}
            onClick={handleAdd}
          >
            Ajouter une question
          </Button>
        </Box>

        <Typography variant="body2" color="text.secondary" paragraph>
          Créez et gérez les questions pour vos quiz par thème et niveau.
        </Typography>

        <TableContainer component={Paper}>
          <Table>
            <TableHead>
              <TableRow>
                <TableCell>Question</TableCell>
                <TableCell>Thème</TableCell>
                <TableCell>Niveau</TableCell>
                <TableCell>Difficulté</TableCell>
                <TableCell>Points</TableCell>
                <TableCell>Actions</TableCell>
              </TableRow>
            </TableHead>
            <TableBody>
              {questions.map((question) => (
                <TableRow key={question.id}>
                  <TableCell>
                    <Typography variant="body2" sx={{ maxWidth: 300 }}>
                      {question.text.length > 50 
                        ? `${question.text.substring(0, 50)}...` 
                        : question.text}
                    </Typography>
                    <Typography variant="caption" color="text.secondary">
                      {question.options.length} options
                    </Typography>
                  </TableCell>
                  <TableCell>{getThemeName(question.themeId)}</TableCell>
                  <TableCell>{getLevelName(question.levelId)}</TableCell>
                  <TableCell>
                    <Chip 
                      label={question.difficulty} 
                      color={getDifficultyColor(question.difficulty) as any}
                      size="small"
                    />
                  </TableCell>
                  <TableCell>
                    <Chip 
                      label={`${question.points} pts`} 
                      variant="outlined"
                      size="small"
                    />
                  </TableCell>
                  <TableCell>
                    <IconButton onClick={() => handleEdit(question)} size="small">
                      <Edit />
                    </IconButton>
                    <IconButton 
                      onClick={() => handleDelete(question.id)} 
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

        <Dialog open={open} onClose={() => setOpen(false)} maxWidth="md" fullWidth>
          <DialogTitle>
            {editingQuestion ? 'Modifier la question' : 'Ajouter une question'}
          </DialogTitle>
          <DialogContent>
            <TextField
              fullWidth
              label="Texte de la question"
              multiline
              rows={3}
              value={formData.text}
              onChange={(e) => setFormData({...formData, text: e.target.value})}
              margin="normal"
            />

            <Typography variant="h6" sx={{ mt: 3, mb: 2 }}>
              Options de réponse
            </Typography>
            
            <List>
              {formData.options.map((option, index) => (
                <ListItem key={index} sx={{ pl: 0 }}>
                  <TextField
                    fullWidth
                    label={`Option ${index + 1}`}
                    value={option}
                    onChange={(e) => updateOption(index, e.target.value)}
                    error={formData.correctAnswer === index}
                    helperText={formData.correctAnswer === index ? 'Réponse correcte' : ''}
                  />
                  <ListItemSecondaryAction>
                    <IconButton 
                      onClick={() => setFormData({...formData, correctAnswer: index})}
                      color={formData.correctAnswer === index ? 'primary' : 'default'}
                    >
                      ✓
                    </IconButton>
                    {formData.options.length > 2 && (
                      <IconButton onClick={() => removeOption(index)} size="small">
                        <Remove />
                      </IconButton>
                    )}
                  </ListItemSecondaryAction>
                </ListItem>
              ))}
            </List>

            {formData.options.length < 6 && (
              <Button onClick={addOption} startIcon={<Add />} sx={{ mb: 2 }}>
                Ajouter une option
              </Button>
            )}

            <Box display="flex" gap={2} mt={2}>
              <FormControl fullWidth>
                <InputLabel>Thème</InputLabel>
                <Select
                  value={formData.themeId}
                  onChange={(e) => setFormData({...formData, themeId: e.target.value})}
                >
                  {themes.map(theme => (
                    <MenuItem key={theme.id} value={theme.id}>
                      {theme.name}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>

              <FormControl fullWidth>
                <InputLabel>Niveau</InputLabel>
                <Select
                  value={formData.levelId}
                  onChange={(e) => setFormData({...formData, levelId: e.target.value})}
                >
                  {levels.map(level => (
                    <MenuItem key={level.id} value={level.id}>
                      {level.name}
                    </MenuItem>
                  ))}
                </Select>
              </FormControl>
            </Box>

            <Box display="flex" gap={2} mt={2}>
              <FormControl fullWidth>
                <InputLabel>Difficulté</InputLabel>
                <Select
                  value={formData.difficulty}
                  onChange={(e) => setFormData({...formData, difficulty: e.target.value as any})}
                >
                  <MenuItem value="easy">Facile</MenuItem>
                  <MenuItem value="medium">Moyen</MenuItem>
                  <MenuItem value="hard">Difficile</MenuItem>
                </Select>
              </FormControl>

              <TextField
                fullWidth
                label="Points"
                type="number"
                value={formData.points}
                onChange={(e) => setFormData({...formData, points: parseInt(e.target.value) || 0})}
              />
            </Box>
          </DialogContent>
          <DialogActions>
            <Button onClick={() => setOpen(false)}>Annuler</Button>
            <Button onClick={handleSave} variant="contained">
              {editingQuestion ? 'Modifier' : 'Ajouter'}
            </Button>
          </DialogActions>
        </Dialog>
      </Box>
    </DashboardLayout>
  );
};

export default QuestionsPage;
