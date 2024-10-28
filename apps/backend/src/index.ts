// src/index.ts
import express from 'express';
import cors from 'cors';
import { PrismaClient } from '@prisma/client';
import healthRoutes from './routes/health.routes.js';

const app = express();
const prisma = new PrismaClient();
const port = process.env.PORT || 8000;

app.use(cors());
app.use(express.json());

// Health routes
app.use('/api', healthRoutes);

// Base route
app.get('/', (req, res) => {
  res.json({
    message: 'Platform One IDP',
    version: '1.0.0',
    environment: process.env.NODE_ENV,
  });
});

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
  console.log(`Health check available at http://localhost:${port}/api/health`);
});