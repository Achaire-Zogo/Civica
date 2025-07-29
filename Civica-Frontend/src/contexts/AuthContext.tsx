import React, { createContext, useContext, useState, useEffect, ReactNode } from 'react';
import { User, AuthContextType } from '../types';
import authService from '../services/authService';

const AuthContext = createContext<AuthContextType | undefined>(undefined);

interface AuthProviderProps {
  children: ReactNode;
}

export const AuthProvider: React.FC<AuthProviderProps> = ({ children }) => {
  const [user, setUser] = useState<User | null>(null);
  const [isLoading, setIsLoading] = useState(true);

  useEffect(() => {
    // Check if user is already logged in using authService
    if (authService.isAuthenticated()) {
      const userData = authService.getUserData();
      if (userData) {
        setUser(userData);
      } else {
        // If we have a token but no user data, create a minimal user object
        setUser({
          id: 'unknown',
          username: 'User',
          email: 'user@example.com',
          role: 'user',
          points: 0,
          currentLevel: 1,
          createdAt: new Date().toISOString()
        });
      }
    }
    setIsLoading(false);
  }, []);

  const login = async (email: string, password: string): Promise<boolean> => {
    setIsLoading(true);
    
    try {
      const result = await authService.login({ email, password });
      console.log(result);
      if (result.success) {
        const userData = authService.getUserData();
        if (userData) {
          setUser(userData);
        } else {
          // If we have a token but no user data, create a minimal user object
          setUser({
            id: 'unknown',
            username: 'User',
            email: email, // Use the email from login
            role: 'user',
            points: 0,
            currentLevel: 1,
            createdAt: new Date().toISOString()
          });
        }
        setIsLoading(false);
        return true;
      }
      
      setIsLoading(false);
      return false;
    } catch (error) {
      setIsLoading(false);
      return false;
    }
  };

  const logout = (): void => {
    authService.logout();
    setUser(null);
  };

  const value: AuthContextType = {
    user,
    login,
    logout,
    isAuthenticated: !!user,
    isLoading
  };

  return (
    <AuthContext.Provider value={value}>
      {children}
    </AuthContext.Provider>
  );
};

export const useAuth = (): AuthContextType => {
  const context = useContext(AuthContext);
  if (context === undefined) {
    throw new Error('useAuth must be used within an AuthProvider');
  }
  return context;
};
