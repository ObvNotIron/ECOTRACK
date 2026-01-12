import express from 'express';
import { supabase } from '../supabase.js';

const router = express.Router();

/**
 * INSCRIPTION
 */
router.post('/signup', async (req, res) => {
  const { email, password, firstname, lastname } = req.body;

  const { data, error } = await supabase.auth.signUp({
    email,
    password,
    options: {
      data: { firstname, lastname } // user_metadata
    }
  });

  if (error) {
    return res.status(400).json({ error: error.message });
  }

  return res.status(201).json({
    message: 'User created. Please check your email to confirm your account.',
    user: data.user
  });
});


/**
 * LOGIN
 */
router.post('/login', async (req, res) => {
  const { email, password } = req.body;

  if (!email || !password) {
    return res.status(400).json({ error: 'Email and password are required' });
  }

  try {
    const { data, error } = await supabase.auth.signInWithPassword({
      email,
      password
    });

    if (error) {
      return res.status(401).json({ error: error.message });
    }

    // Retour des tokens et info utilisateur
    return res.json({
      access_token: data.session.access_token,
      refresh_token: data.session.refresh_token,
      expires_in: data.session.expires_in,
      user: data.user
    });
  } catch (err) {
    console.error(err);
    return res.status(500).json({ error: 'Internal server error' });
  }
});

export default router;
