const API_BASE_URL = 'http://192.168.1.143:5002/api';

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
}

export const apiService = new ApiService();
export type { Theme };
