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
  Checkbox,
  RadioGroup,
  Radio,
  Accordion,
  AccordionSummary,
  AccordionDetails
} from '@mui/material';
import { Edit, Delete, Add, Refresh, ExpandMore, CheckCircle, Cancel } from '@mui/icons-material';
import DashboardLayout from '../components/DashboardLayout';
import { Question, Level, Theme } from '../types';
import { apiService } from '../services/api';

const QuestionsPage: React.FC = () => {
  const [questions, setQuestions] = useState<Question[]>([]);
  const [levels, setLevels] = useState<Level[]>([]);
  const [themes, setThemes] = useState<Theme[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [snackbar, setSnackbar] = useState({ open: false, message: '', severity: 'success' as 'success' | 'error' });
  const [selectedLevelId, setSelectedLevelId] = useState<string>('');
  const [selectedThemeId, setSelectedThemeId] = useState<string>('');

  const [open, setOpen] = useState(false);
  const [editingQuestion, setEditingQuestion] = useState<Question | null>(null);
  const [formData, setFormData] = useState({
    level_id: '',
    question_text: '',
    option_a: '',
    option_b: '',
    option_c: '',
    option_d: '',
    correct_answer: 'A' as 'A' | 'B' | 'C' | 'D',
    explanation: '',
    points: 10,
    order_index: 0,
    is_active: true
  });
  const [submitting, setSubmitting] = useState(false);

  // Load data from API on component mount
  useEffect(() => {
    loadInitialData();
  }, []);

  useEffect(() => {
    if (selectedLevelId) {
      loadQuestions(selectedLevelId);
    } else if (selectedThemeId) {
      // Load questions for all levels in the theme
      const themeLevels = levels.filter(level => level.theme_id === selectedThemeId);
      if (themeLevels.length > 0) {
        loadQuestions();
      }
    }
  }, [selectedLevelId, selectedThemeId]);

  const loadInitialData = async () => {
    try {
      setLoading(true);
      setError(null);
      const [themesData, levelsData, questionsData] = await Promise.all([
        apiService.getThemes(),
        apiService.getLevels(),
        apiService.getQuestions()
      ]);
      setThemes(themesData);
      setLevels(levelsData);
      setQuestions(questionsData);
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erreur lors du chargement des données';
      setError(errorMessage);
      showSnackbar(errorMessage, 'error');
    } finally {
      setLoading(false);
    }
  };

  const loadQuestions = async (levelId?: string) => {
    try {
      setLoading(true);
      setError(null);
      const questionsData = await apiService.getQuestions(levelId);
      setQuestions(questionsData);
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erreur lors du chargement des questions';
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
    setEditingQuestion(null);
    setFormData({
      level_id: selectedLevelId || (levels.length > 0 ? levels[0].id : ''),
      question_text: '',
      option_a: '',
      option_b: '',
      option_c: '',
      option_d: '',
      correct_answer: 'A',
      explanation: '',
      points: 10,
      order_index: questions.length,
      is_active: true
    });
    setOpen(true);
  };

  const handleEdit = (question: Question) => {
    setEditingQuestion(question);
    setFormData({
      level_id: question.level_id,
      question_text: question.question_text,
      option_a: question.option_a,
      option_b: question.option_b,
      option_c: question.option_c,
      option_d: question.option_d,
      correct_answer: question.correct_answer,
      explanation: question.explanation || '',
      points: question.points,
      order_index: question.order_index,
      is_active: question.is_active
    });
    setOpen(true);
  };

  const handleSave = async () => {
    if (!formData.question_text.trim()) {
      showSnackbar('Le texte de la question est requis', 'error');
      return;
    }

    if (!formData.option_a.trim() || !formData.option_b.trim() || !formData.option_c.trim() || !formData.option_d.trim()) {
      showSnackbar('Toutes les options sont requises', 'error');
      return;
    }

    try {
      setSubmitting(true);
      
      if (editingQuestion) {
        // Update existing question
        const updatedQuestion = await apiService.updateQuestion(editingQuestion.id, formData);
        setQuestions(questions.map(question => 
          question.id === editingQuestion.id ? updatedQuestion : question
        ));
        showSnackbar('Question mise à jour avec succès', 'success');
      } else {
        // Create new question
        const newQuestion = await apiService.createQuestion(formData);
        setQuestions([...questions, newQuestion]);
        showSnackbar('Question créée avec succès', 'success');
      }
      
      setOpen(false);
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erreur lors de la sauvegarde';
      showSnackbar(errorMessage, 'error');
    } finally {
      setSubmitting(false);
    }
  };

  const handleDelete = async (questionId: string) => {
    if (!window.confirm('Êtes-vous sûr de vouloir supprimer cette question ?')) {
      return;
    }

    try {
      await apiService.deleteQuestion(questionId);
      setQuestions(questions.filter(question => question.id !== questionId));
      showSnackbar('Question supprimée avec succès', 'success');
    } catch (err) {
      const errorMessage = err instanceof Error ? err.message : 'Erreur lors de la suppression';
      showSnackbar(errorMessage, 'error');
    }
  };

  const getFilteredQuestions = () => {
    let filtered = questions;
    
    if (selectedLevelId) {
      filtered = filtered.filter(q => q.level_id === selectedLevelId);
    } else if (selectedThemeId) {
      const themeLevels = levels.filter(level => level.theme_id === selectedThemeId);
      const levelIds = themeLevels.map(level => level.id);
      filtered = filtered.filter(q => levelIds.includes(q.level_id));
    }
    
    return filtered.sort((a, b) => a.order_index - b.order_index);
  };

  const filteredQuestions = getFilteredQuestions();

  return (
    <DashboardLayout title="Gestion des questions">
      <Box>
        <Box display="flex" justifyContent="space-between" alignItems="center" mb={3}>
          <Typography variant="h4">Questions</Typography>
          <Box display="flex" gap={2} alignItems="center">
            <FormControl size="small" sx={{ minWidth: 200 }}>
              <InputLabel>Filtrer par thème</InputLabel>
              <Select
                value={selectedThemeId}
                label="Filtrer par thème"
                onChange={(e) => {
                  setSelectedThemeId(e.target.value);
                  setSelectedLevelId(''); // Reset level filter
                }}
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
            <FormControl size="small" sx={{ minWidth: 200 }}>
              <InputLabel>Filtrer par niveau</InputLabel>
              <Select
                value={selectedLevelId}
                label="Filtrer par niveau"
                onChange={(e) => setSelectedLevelId(e.target.value)}
              >
                <MenuItem value="">
                  <em>Tous les niveaux</em>
                </MenuItem>
                {levels
                  .filter(level => !selectedThemeId || level.theme_id === selectedThemeId)
                  .map((level) => {
                    const theme = themes.find(t => t.id.toString() === level.theme_id);
                    return (
                      <MenuItem key={level.id} value={level.id}>
                        {level.title} ({theme?.title || 'Thème inconnu'})
                      </MenuItem>
                    );
                  })}
              </Select>
            </FormControl>
            <IconButton onClick={() => loadQuestions(selectedLevelId)} disabled={loading}>
              <Refresh />
            </IconButton>
            <Button
              variant="contained"
              startIcon={<Add />}
              onClick={handleAdd}
              disabled={loading}
            >
              Ajouter une question
            </Button>
          </Box>
        </Box>

        <Typography variant="body2" color="text.secondary" paragraph>
          Configurez les questions pour chaque niveau et thème. Chaque question peut avoir 4 options avec une réponse correcte.
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
                  <TableCell>Question</TableCell>
                  <TableCell>Niveau</TableCell>
                  <TableCell>Thème</TableCell>
                  <TableCell>Réponse</TableCell>
                  <TableCell>Points</TableCell>
                  <TableCell>Statut</TableCell>
                  <TableCell>Actions</TableCell>
                </TableRow>
              </TableHead>
              <TableBody>
                {filteredQuestions.length === 0 ? (
                  <TableRow>
                    <TableCell colSpan={8} align="center">
                      <Typography color="text.secondary">
                        {selectedLevelId || selectedThemeId ? 'Aucune question trouvée pour ce filtre' : 'Aucune question trouvée'}
                      </Typography>
                    </TableCell>
                  </TableRow>
                ) : (
                  filteredQuestions.map((question) => {
                    const level = levels.find(l => l.id === question.level_id);
                    const theme = themes.find(t => t.id.toString() === level?.theme_id);
                    return (
                      <TableRow key={question.id}>
                        <TableCell>
                          <Chip label={question.order_index} size="small" />
                        </TableCell>
                        <TableCell>
                          <Accordion>
                            <AccordionSummary expandIcon={<ExpandMore />}>
                              <Typography variant="body2" fontWeight="medium">
                                {question.question_text.length > 50 
                                  ? `${question.question_text.substring(0, 50)}...` 
                                  : question.question_text}
                              </Typography>
                            </AccordionSummary>
                            <AccordionDetails>
                              <Box>
                                <Typography variant="body2" mb={1}>
                                  <strong>Options:</strong>
                                </Typography>
                                <Box ml={2}>
                                  <Typography variant="body2">A. {question.option_a}</Typography>
                                  <Typography variant="body2">B. {question.option_b}</Typography>
                                  <Typography variant="body2">C. {question.option_c}</Typography>
                                  <Typography variant="body2">D. {question.option_d}</Typography>
                                </Box>
                                {question.explanation && (
                                  <Box mt={2}>
                                    <Typography variant="body2">
                                      <strong>Explication:</strong> {question.explanation}
                                    </Typography>
                                  </Box>
                                )}
                              </Box>
                            </AccordionDetails>
                          </Accordion>
                        </TableCell>
                        <TableCell>
                          <Typography variant="body2">
                            {level?.title || 'Niveau inconnu'}
                          </Typography>
                        </TableCell>
                        <TableCell>
                          <Typography variant="body2" color="text.secondary">
                            {theme?.title || 'Thème inconnu'}
                          </Typography>
                        </TableCell>
                        <TableCell>
                          <Chip 
                            label={`Réponse ${question.correct_answer}`} 
                            size="small"
                            color="primary"
                            icon={<CheckCircle />}
                          />
                        </TableCell>
                        <TableCell>{question.points} pts</TableCell>
                        <TableCell>
                          <Chip 
                            label={question.is_active ? 'Actif' : 'Inactif'} 
                            size="small"
                            color={question.is_active ? 'success' : 'default'}
                          />
                        </TableCell>
                        <TableCell>
                          <IconButton onClick={() => handleEdit(question)} size="small">
                            <Edit />
                          </IconButton>
                          <IconButton onClick={() => handleDelete(question.id)} size="small" color="error">
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

        <Dialog open={open} onClose={() => setOpen(false)} maxWidth="md" fullWidth>
          <DialogTitle>
            {editingQuestion ? 'Modifier la question' : 'Ajouter une question'}
          </DialogTitle>
          <DialogContent>
            <FormControl fullWidth margin="normal">
              <InputLabel>Niveau</InputLabel>
              <Select
                value={formData.level_id}
                label="Niveau"
                onChange={(e) => setFormData({...formData, level_id: e.target.value})}
              >
                {levels.map((level) => {
                  const theme = themes.find(t => t.id.toString() === level.theme_id);
                  return (
                    <MenuItem key={level.id} value={level.id}>
                      {level.title} ({theme?.title || 'Thème inconnu'})
                    </MenuItem>
                  );
                })}
              </Select>
            </FormControl>
            
            <TextField
              fullWidth
              label="Texte de la question"
              multiline
              rows={3}
              value={formData.question_text}
              onChange={(e) => setFormData({...formData, question_text: e.target.value})}
              margin="normal"
              required
            />
            
            <Typography variant="h6" sx={{ mt: 2, mb: 1 }}>Options de réponse</Typography>
            
            <TextField
              fullWidth
              label="Option A"
              value={formData.option_a}
              onChange={(e) => setFormData({...formData, option_a: e.target.value})}
              margin="normal"
              required
            />
            
            <TextField
              fullWidth
              label="Option B"
              value={formData.option_b}
              onChange={(e) => setFormData({...formData, option_b: e.target.value})}
              margin="normal"
              required
            />
            
            <TextField
              fullWidth
              label="Option C"
              value={formData.option_c}
              onChange={(e) => setFormData({...formData, option_c: e.target.value})}
              margin="normal"
              required
            />
            
            <TextField
              fullWidth
              label="Option D"
              value={formData.option_d}
              onChange={(e) => setFormData({...formData, option_d: e.target.value})}
              margin="normal"
              required
            />
            
            <FormControl fullWidth margin="normal">
              <InputLabel>Réponse correcte</InputLabel>
              <Select
                value={formData.correct_answer}
                label="Réponse correcte"
                onChange={(e) => setFormData({...formData, correct_answer: e.target.value as 'A' | 'B' | 'C' | 'D'})}
              >
                <MenuItem value="A">A. {formData.option_a || 'Option A'}</MenuItem>
                <MenuItem value="B">B. {formData.option_b || 'Option B'}</MenuItem>
                <MenuItem value="C">C. {formData.option_c || 'Option C'}</MenuItem>
                <MenuItem value="D">D. {formData.option_d || 'Option D'}</MenuItem>
              </Select>
            </FormControl>
            
            <TextField
              fullWidth
              label="Explication (optionnel)"
              multiline
              rows={2}
              value={formData.explanation}
              onChange={(e) => setFormData({...formData, explanation: e.target.value})}
              margin="normal"
            />
            
            <Box display="flex" gap={2} mt={2}>
              <TextField
                label="Points"
                type="number"
                value={formData.points}
                onChange={(e) => setFormData({...formData, points: parseInt(e.target.value) || 10})}
                sx={{ width: 120 }}
              />
              
              <TextField
                label="Ordre d'affichage"
                type="number"
                value={formData.order_index}
                onChange={(e) => setFormData({...formData, order_index: parseInt(e.target.value) || 0})}
                sx={{ width: 150 }}
              />
              
              <FormControlLabel
                control={
                  <Checkbox
                    checked={formData.is_active}
                    onChange={(e) => setFormData({...formData, is_active: e.target.checked})}
                  />
                }
                label="Question active"
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
              {submitting ? 'Sauvegarde...' : (editingQuestion ? 'Modifier' : 'Ajouter')}
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

export default QuestionsPage;
