import React from 'react';
import { describe, it, expect, beforeEach } from 'vitest';
import { render, screen, waitFor } from '@testing-library/react';
import userEvent from '@testing-library/user-event';
import { BrowserRouter } from 'react-router-dom';

import UV_Login from '@/components/views/UV_Login';
import { useAppStore } from '@/store/main';

const Wrapper: React.FC<{ children: React.ReactNode }> = ({ children }) => (
  <BrowserRouter>{children}</BrowserRouter>
);

describe('Auth E2E Flow (Real API)', () => {
  beforeEach(() => {
    localStorage.clear();
    useAppStore.setState((state) => ({
      authentication_state: {
        ...state.authentication_state,
        auth_token: null,
        current_user: null,
        authentication_status: {
          is_authenticated: false,
          is_loading: false,
        },
        error_message: null,
      },
    }));
  });

  it('completes full auth flow: register → logout → login', async () => {
    const user = userEvent.setup();
    
    const uniqueEmail = `testuser${Date.now()}@example.com`;
    const testPassword = 'testpass123';
    const testName = 'Test User';

    const { unmount } = render(<UV_Login />, { wrapper: Wrapper });

    const emailInput = await screen.findByPlaceholderText(/email address/i);
    const passwordInput = await screen.findByPlaceholderText(/password/i);

    await waitFor(() => {
      expect(emailInput).not.toBeDisabled();
      expect(passwordInput).not.toBeDisabled();
    });

    const toggleButton = screen.getByRole('button', { name: /don't have an account/i });
    await user.click(toggleButton);

    await waitFor(() => {
      expect(screen.getByPlaceholderText(/full name/i)).toBeInTheDocument();
    });

    const nameInput = screen.getByPlaceholderText(/full name/i);
    const registerButton = screen.getByRole('button', { name: /create account/i });

    await user.type(nameInput, testName);
    await user.type(emailInput, uniqueEmail);
    await user.type(passwordInput, testPassword);

    await waitFor(() => expect(registerButton).not.toBeDisabled());
    await user.click(registerButton);

    await waitFor(() => {
      expect(screen.getByText(/creating account/i)).toBeInTheDocument();
    });

    await waitFor(
      () => {
        const state = useAppStore.getState();
        expect(state.authentication_state.authentication_status.is_authenticated).toBe(true);
        expect(state.authentication_state.auth_token).toBeTruthy();
        expect(state.authentication_state.current_user?.email).toBe(uniqueEmail.toLowerCase());
        expect(state.authentication_state.current_user?.name).toBe(testName);
      },
      { timeout: 20000 }
    );

    const logoutAction = useAppStore.getState().logout_user;
    logoutAction();

    await waitFor(() => {
      const state = useAppStore.getState();
      expect(state.authentication_state.authentication_status.is_authenticated).toBe(false);
      expect(state.authentication_state.auth_token).toBeNull();
      expect(state.authentication_state.current_user).toBeNull();
    });

    unmount();

    render(<UV_Login />, { wrapper: Wrapper });

    const emailInputLogin = await screen.findByPlaceholderText(/email address/i);
    const passwordInputLogin = await screen.findByPlaceholderText(/password/i);
    const signInButton = screen.getByRole('button', { name: /^sign in$/i });

    await waitFor(() => {
      expect(emailInputLogin).not.toBeDisabled();
      expect(passwordInputLogin).not.toBeDisabled();
    });

    await user.type(emailInputLogin, uniqueEmail);
    await user.type(passwordInputLogin, testPassword);

    await waitFor(() => expect(signInButton).not.toBeDisabled());
    await user.click(signInButton);

    await waitFor(() => {
      expect(screen.getByText(/signing in/i)).toBeInTheDocument();
    });

    await waitFor(
      () => {
        const state = useAppStore.getState();
        expect(state.authentication_state.authentication_status.is_authenticated).toBe(true);
        expect(state.authentication_state.auth_token).toBeTruthy();
        expect(state.authentication_state.current_user?.email).toBe(uniqueEmail.toLowerCase());
      },
      { timeout: 20000 }
    );
  }, 60000);

  it('handles registration with duplicate email', async () => {
    const user = userEvent.setup();
    
    const duplicateEmail = `duplicate${Date.now()}@example.com`;
    const testPassword = 'testpass123';
    const testName = 'First User';

    render(<UV_Login />, { wrapper: Wrapper });

    const toggleButton = screen.getByRole('button', { name: /don't have an account/i });
    await user.click(toggleButton);

    await waitFor(() => {
      expect(screen.getByPlaceholderText(/full name/i)).toBeInTheDocument();
    });

    const nameInput = screen.getByPlaceholderText(/full name/i);
    const emailInput = screen.getByPlaceholderText(/email address/i);
    const passwordInput = screen.getByPlaceholderText(/password/i);
    const registerButton = screen.getByRole('button', { name: /create account/i });

    await user.type(nameInput, testName);
    await user.type(emailInput, duplicateEmail);
    await user.type(passwordInput, testPassword);
    await user.click(registerButton);

    await waitFor(
      () => {
        const state = useAppStore.getState();
        expect(state.authentication_state.authentication_status.is_authenticated).toBe(true);
      },
      { timeout: 20000 }
    );

    const logoutAction = useAppStore.getState().logout_user;
    logoutAction();

    await user.clear(nameInput);
    await user.clear(emailInput);
    await user.clear(passwordInput);

    await user.type(nameInput, 'Second User');
    await user.type(emailInput, duplicateEmail);
    await user.type(passwordInput, testPassword);
    await user.click(registerButton);

    await waitFor(
      () => {
        const state = useAppStore.getState();
        expect(state.authentication_state.error_message).toMatch(/already exists/i);
        expect(state.authentication_state.authentication_status.is_authenticated).toBe(false);
      },
      { timeout: 10000 }
    );
  }, 60000);

  it('handles invalid login credentials', async () => {
    const user = userEvent.setup();
    
    render(<UV_Login />, { wrapper: Wrapper });

    const emailInput = await screen.findByPlaceholderText(/email address/i);
    const passwordInput = await screen.findByPlaceholderText(/password/i);
    const signInButton = screen.getByRole('button', { name: /^sign in$/i });

    await user.type(emailInput, 'nonexistent@example.com');
    await user.type(passwordInput, 'wrongpassword');
    await user.click(signInButton);

    await waitFor(
      () => {
        const state = useAppStore.getState();
        expect(state.authentication_state.error_message).toMatch(/invalid/i);
        expect(state.authentication_state.authentication_status.is_authenticated).toBe(false);
      },
      { timeout: 10000 }
    );
  }, 30000);
});
