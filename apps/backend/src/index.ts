// src/index.ts
import express from 'express';
import cors from 'cors';
import { PrismaClient } from '@prisma/client';
import dotenv from 'dotenv';

dotenv.config();

const app = express();
const prisma = new PrismaClient();
const port = process.env.PORT || 8000;

app.use(cors());
app.use(express.json());

// Health check endpoint
app.get('/health', (req, res) => {
  res.json({ status: 'ok' });
});

// Service endpoints
app.get('/api/services', async (req, res) => {
  try {
    const services = await prisma.service.findMany();
    res.json(services);
  } catch (error) {
    console.error('Error fetching services:', error);
    res.status(500).json({ error: 'Error fetching services' });
  }
});

app.post('/api/services', async (req, res) => {
  try {
    const service = await prisma.service.create({
      data: {
        name: req.body.name,
        description: req.body.description,
        repository: req.body.repository,
        status: req.body.status || 'healthy'
      }
    });
    res.status(201).json(service);
  } catch (error) {
    console.error('Error creating service:', error);
    res.status(500).json({ error: 'Error creating service' });
  }
});

app.listen(port, () => {
  console.log(`Server running on http://localhost:${port}`);
});

// Handle graceful shutdown
process.on('SIGTERM', async () => {
  console.log('SIGTERM received. Closing HTTP server and Prisma Client');
  await prisma.$disconnect();
  process.exit(0);
});