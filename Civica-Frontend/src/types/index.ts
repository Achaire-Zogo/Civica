export interface User {
  id: string;
  username: string;
  email: string;
  role: 'admin' | 'user';
  points: number;
  currentLevel: number;
  createdAt: string;
}

export interface Level {
  id: string;
  name: string;
  requiredPoints: number;
  description: string;
  order: number;
}

export interface Theme {
  id: string;
  name: string;
  description: string;
  color: string;
  isActive: boolean;
}

export interface Question {
  id: string;
  text: string;
  options: string[];
  correctAnswer: number;
  points: number;
  themeId: string;
  levelId: string;
  difficulty: 'easy' | 'medium' | 'hard';
}

export interface AuthContextType {
  user: User | null;
  login: (email: string, password: string) => Promise<boolean>;
  logout: () => void;
  isAuthenticated: boolean;
  isLoading: boolean;
}
