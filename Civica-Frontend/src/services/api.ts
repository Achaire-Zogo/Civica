// Import types from shared types file
import type { Question, User } from '../types';

const API_BASE_URL = 'http://192.168.185.19:5002/api';

interface ApiResponse<T> {
  success: boolean;
  data: T;
  message?: string;
}

interface Theme {
  id: number;
  title: string;
  description: string;
  color: string;
  isActive: boolean;
  created_at: string;
  updated_at: string;
}

interface Level {
  id: string;
  theme_id: string;
  title: string;
  description?: string;
  difficulty: 'easy' | 'medium' | 'hard';
  order_index: number;
  is_active: boolean;
  min_score_to_unlock: number;
  created_at?: string;
  updated_at?: string;
}



class ApiService {
  private getAuthHeaders(): HeadersInit {
    const token = localStorage.getItem('auth_token');
    return {
      'Content-Type': 'application/json',
      ...(token && { 'Authorization': `Bearer ${token}` }),
    };
  }

  private async handleResponse<T>(response: Response): Promise<T> {
    if (!response.ok) {
      const errorData = await response.json().catch(() => ({}));
      throw new Error(errorData.message || `HTTP error! status: ${response.status}`);
    }
    return response.json();
  }

  // Theme API methods
  async getThemes(): Promise<Theme[]> {
    const response = await fetch(`${API_BASE_URL}/theme/`, {
      method: 'GET',
      headers: this.getAuthHeaders(),
    });
    
    const data = await this.handleResponse<ApiResponse<Theme[]>>(response);
    return data.data;
  }

  async createTheme(theme: Omit<Theme, 'id' | 'created_at' | 'updated_at'>): Promise<Theme> {
    const response = await fetch(`${API_BASE_URL}/theme/`, {
      method: 'POST',
      headers: this.getAuthHeaders(),
      body: JSON.stringify(theme),
    });
    
    const data = await this.handleResponse<ApiResponse<Theme>>(response);
    return data.data;
  }

  async updateTheme(id: number, theme: Partial<Omit<Theme, 'id' | 'created_at' | 'updated_at'>>): Promise<Theme> {
    const response = await fetch(`${API_BASE_URL}/theme/${id}`, {
      method: 'PUT',
      headers: this.getAuthHeaders(),
      body: JSON.stringify(theme),
    });
    
    const data = await this.handleResponse<ApiResponse<Theme>>(response);
    return data.data;
  }

  async deleteTheme(id: number): Promise<void> {
    const response = await fetch(`${API_BASE_URL}/theme/${id}`, {
      method: 'DELETE',
      headers: this.getAuthHeaders(),
    });
    
    await this.handleResponse<ApiResponse<null>>(response);
  }

  // Level API methods
  async getLevels(themeId?: string): Promise<Level[]> {
    const url = themeId 
      ? `${API_BASE_URL}/theme/${themeId}/levels`
      : `${API_BASE_URL}/level/`;
    
    const response = await fetch(url, {
      method: 'GET',
      headers: this.getAuthHeaders(),
    });
    
    const data = await this.handleResponse<ApiResponse<Level[]>>(response);
    return data.data;
  }

  async getLevel(id: string): Promise<Level> {
    const response = await fetch(`${API_BASE_URL}/level/${id}`, {
      method: 'GET',
      headers: this.getAuthHeaders(),
    });
    
    const data = await this.handleResponse<ApiResponse<Level>>(response);
    return data.data;
  }

  async createLevel(level: Omit<Level, 'id' | 'created_at' | 'updated_at'>): Promise<Level> {
    const response = await fetch(`${API_BASE_URL}/level`, {
      method: 'POST',
      headers: this.getAuthHeaders(),
      body: JSON.stringify(level),
    });
    
    const data = await this.handleResponse<ApiResponse<Level>>(response);
    return data.data;
  }

  async updateLevel(id: string, level: Partial<Omit<Level, 'id' | 'created_at' | 'updated_at'>>): Promise<Level> {
    const response = await fetch(`${API_BASE_URL}/level/${id}`, {
      method: 'PUT',
      headers: this.getAuthHeaders(),
      body: JSON.stringify(level),
    });
    
    const data = await this.handleResponse<ApiResponse<Level>>(response);
    return data.data;
  }

  async deleteLevel(id: string): Promise<void> {
    const response = await fetch(`${API_BASE_URL}/level/${id}`, {
      method: 'DELETE',
      headers: this.getAuthHeaders(),
    });
    
    await this.handleResponse<ApiResponse<null>>(response);
  }

  // Question API methods
  async getQuestions(levelId?: string): Promise<Question[]> {
    const url = levelId 
      ? `${API_BASE_URL}/level/${levelId}/questions`
      : `${API_BASE_URL}/question/`;
    
    const response = await fetch(url, {
      method: 'GET',
      headers: this.getAuthHeaders(),
    });
    
    const data = await this.handleResponse<ApiResponse<Question[]>>(response);
    return data.data;
  }

  async getQuestion(id: string): Promise<Question> {
    const response = await fetch(`${API_BASE_URL}/question/${id}`, {
      method: 'GET',
      headers: this.getAuthHeaders(),
    });
    
    const data = await this.handleResponse<ApiResponse<Question>>(response);
    return data.data;
  }

  async createQuestion(question: Omit<Question, 'id' | 'created_at' | 'updated_at'>): Promise<Question> {
    const response = await fetch(`${API_BASE_URL}/question/question`, {
      method: 'POST',
      headers: this.getAuthHeaders(),
      body: JSON.stringify(question),
    });
    
    const data = await this.handleResponse<ApiResponse<Question>>(response);
    return data.data;
  }

  async updateQuestion(id: string, question: Partial<Omit<Question, 'id' | 'created_at' | 'updated_at'>>): Promise<Question> {
    const response = await fetch(`${API_BASE_URL}/question/${id}`, {
      method: 'PUT',
      headers: this.getAuthHeaders(),
      body: JSON.stringify(question),
    });
    
    const data = await this.handleResponse<ApiResponse<Question>>(response);
    return data.data;
  }

  async deleteQuestion(id: string): Promise<void> {
    const response = await fetch(`${API_BASE_URL}/question/${id}`, {
      method: 'DELETE',
      headers: this.getAuthHeaders(),
    });
    
    await this.handleResponse<ApiResponse<null>>(response);
  }

  async checkAnswer(questionId: string, answer: string): Promise<{ correct: boolean; explanation?: string }> {
    const response = await fetch(`${API_BASE_URL}/question/${questionId}/check`, {
      method: 'POST',
      headers: this.getAuthHeaders(),
      body: JSON.stringify({ answer }),
    });
    
    const data = await this.handleResponse<ApiResponse<{ correct: boolean; explanation?: string }>>(response);
    return data.data;
  }

  // Authentication methods
  async login(email: string, password: string): Promise<{ token: string; user: any }> {
    const response = await fetch(`${API_BASE_URL}/user/login`, {
      method: 'POST',
      headers: { 'Content-Type': 'application/json' },
      body: JSON.stringify({ email, password }),
    });
    
    const data = await this.handleResponse<ApiResponse<{ token: string; user: any }>>(response);
    
    // Store token in localStorage
    localStorage.setItem('auth_token', data.data.token);
    localStorage.setItem('user_data', JSON.stringify(data.data.user));
    
    return data.data;
  }

  async logout(): Promise<void> {
    localStorage.removeItem('auth_token');
    localStorage.removeItem('user_data');
  }

  isAuthenticated(): boolean {
    return !!localStorage.getItem('auth_token');
  }

  getCurrentUser(): any {
    const userData = localStorage.getItem('user_data');
    return userData ? JSON.parse(userData) : null;
  }

  // User CRUD operations
  async getUsers(email?: string): Promise<User[]> {
    const url = email ? `${API_BASE_URL}/user/?email=${encodeURIComponent(email)}` : `${API_BASE_URL}/user/`;
    const response = await fetch(url, {
      method: 'GET',
      headers: this.getAuthHeaders(),
    });
    const data = await this.handleResponse<ApiResponse<User[]>>(response);
    return data.data;
  }

  async getUser(userId: string): Promise<User> {
    const response = await fetch(`${API_BASE_URL}/user/${userId}`, {
      method: 'GET',
      headers: this.getAuthHeaders(),
    });
    const data = await this.handleResponse<ApiResponse<User>>(response);
    return data.data;
  }

  async updateUser(userId: string, userData: Partial<Omit<User, 'id' | 'created_at' | 'updated_at'>>): Promise<User> {
    const response = await fetch(`${API_BASE_URL}/user/${userId}`, {
      method: 'PUT',
      headers: this.getAuthHeaders(),
      body: JSON.stringify(userData),
    });
    const data = await this.handleResponse<ApiResponse<User>>(response);
    return data.data;
  }

  async deleteUser(userId: string): Promise<void> {
    const response = await fetch(`${API_BASE_URL}/user/${userId}`, {
      method: 'DELETE',
      headers: this.getAuthHeaders(),
    });
    await this.handleResponse<ApiResponse<any>>(response);
  }

  async updateUserScore(userId: string, pointsEarned: number): Promise<User> {
    const response = await fetch(`${API_BASE_URL}/user/${userId}/score`, {
      method: 'PUT',
      headers: this.getAuthHeaders(),
      body: JSON.stringify({ points_earned: pointsEarned }),
    });
    const data = await this.handleResponse<ApiResponse<User>>(response);
    return data.data;
  }

  async getUserStats(userId: string): Promise<any> {
    const response = await fetch(`${API_BASE_URL}/user/${userId}/stats`, {
      method: 'GET',
      headers: this.getAuthHeaders(),
    });
    const data = await this.handleResponse<ApiResponse<any>>(response);
    return data.data;
  }

  async getDashboardStats(): Promise<{
    users_count: number;
    themes_count: number;
    levels_count: number;
    questions_count: number;
    last_updated: string;
  }> {
    const response = await fetch(`${API_BASE_URL}/user/dashboard/stats`, {
      method: 'GET',
      headers: this.getAuthHeaders(),
    });
    const data = await this.handleResponse<ApiResponse<{
      users_count: number;
      themes_count: number;
      levels_count: number;
      questions_count: number;
      last_updated: string;
    }>>(response);
    return data.data;
  }
}

export const apiService = new ApiService();
export type { Theme, Level };
