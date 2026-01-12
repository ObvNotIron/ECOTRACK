import { supabase } from '../supabase.js';

export const requireAuth = async (req, res, next) => {
  const authHeader = req.headers.authorization;

  if (!authHeader) {
    return res.status(401).json({ error: 'Missing token' });
  }

  const token = authHeader.replace('Bearer ', '');

  const { data, error } = await supabase.auth.getUser(token);

  if (error) {
    return res.status(401).json({ error: 'Invalid token' });
  }

  req.user = data.user;
  next();
};
