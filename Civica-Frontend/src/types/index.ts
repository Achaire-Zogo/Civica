export interface User {
  id: string;
  spseudo?: string;
  email: string;
  role: 'USER' | 'ADMIN';
  is_verified: 'YES' | 'NO';
  status: 'ACTIVE' | 'INACTIVE';
  connexion_type: 'EMAIL' | 'PHONE' | 'GOOGLE' | 'FACEBOOK';
  point: number;
  niveaux: number;
  vies: number;
  is_deleted: boolean;
  fcm_token?: string;
  last_life_refresh?: string;
  created_at: string;
  updated_at: string;
}

export interface Level {
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

export interface Question {
  id: string;
  level_id: string;
  question_text: string;
  option_a: string;
  option_b: string;
  option_c: string;
  option_d: string;
  correct_answer: 'A' | 'B' | 'C' | 'D';
  explanation?: string;
  points: number;
  order_index: number;
  is_active: boolean;
  created_at?: string;
  updated_at?: string;
}

export interface Theme {
  id: number;
  title: string;
  description: string;
  color: string;
  isActive: boolean;
  created_at?: string;
  updated_at?: string;
}



export interface AuthContextType {
  user: User | null;
  login: (email: string, password: string) => Promise<boolean>;
  logout: () => void;
  isAuthenticated: boolean;
  isLoading: boolean;
}
