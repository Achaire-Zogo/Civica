import axios from 'axios';

// Base URL for your Python backend
const API_BASE_URL = 'http://192.168.1.143:5002';

export interface LoginCredentials {
  email: string;
  password: string;
}

export interface RegisterData {
  email: string;
  password: string;
  spseudo: string;
}

export interface AuthResponse {
  success: boolean;
  message: string;
  data?: {
    token: string;
    user?: any;
  };
}

class AuthService {
  private token: string | null = null;

  constructor() {
    // Load token from localStorage on initialization
    this.token = localStorage.getItem('auth_token');
  }

  // Login method
  async login(credentials: LoginCredentials): Promise<AuthResponse> {
    try {
      const response = await axios.post(`${API_BASE_URL}/api/user/login`, {
        email: credentials.email,
        password: credentials.password
      });

      if (response.status === 200 && response.data.data?.token) {
        const token = response.data.data.token;
        this.token = token;
        localStorage.setItem('auth_token', token);
        
        // Store user data if available
        if (response.data.data.user) {
          localStorage.setItem('user_data', JSON.stringify(response.data.data.user));
        }

        return {
          success: true,
          message: response.data.message || 'Login successful',
          data: response.data.data
        };
      }

      return {
        success: false,
        message: response.data.message || 'Login failed'
      };
    } catch (error: any) {
      console.error('Login error:', error);
      
      if (error.response?.data?.message) {
        return {
          success: false,
          message: error.response.data.message
        };
      }

      return {
        success: false,
        message: 'Erreur de connexion au serveur'
      };
    }
  }

  // Register method
  async register(data: RegisterData): Promise<AuthResponse> {
    try {
      const response = await axios.post(`${API_BASE_URL}/api/user/register`, {
        email: data.email,
        password: data.password,
        spseudo: data.spseudo
      });

      if (response.status === 201) {
        return {
          success: true,
          message: response.data.message || 'Registration successful'
        };
      }

      return {
        success: false,
        message: response.data.message || 'Registration failed'
      };
    } catch (error: any) {
      console.error('Registration error:', error);
      
      if (error.response?.data?.message) {
        return {
          success: false,
          message: error.response.data.message
        };
      }

      return {
        success: false,
        message: 'Erreur de connexion au serveur'
      };
    }
  }

  // Logout method
  logout(): void {
    this.token = null;
    localStorage.removeItem('auth_token');
    localStorage.removeItem('user_data');
  }

  // Check if user is authenticated
  isAuthenticated(): boolean {
    return !!this.token;
  }

  // Get current token
  getToken(): string | null {
    return this.token;
  }

  // Get user data
  getUserData(): any | null {
    const userData = localStorage.getItem('user_data');
    return userData ? JSON.parse(userData) : null;
  }

  // Get authorization headers for API calls
  getAuthHeaders(): Record<string, string> {
    const headers: Record<string, string> = {
      'Content-Type': 'application/json'
    };

    if (this.token) {
      headers['Authorization'] = `Bearer ${this.token}`;
    }

    return headers;
  }
}

export default new AuthService();
