// src/routes/health.routes.ts
import express from 'express';
import { healthCheck, checkComponents } from '../controllers/health.controller.js';

const router = express.Router();

router.get('/health', healthCheck);
router.get('/health/components', checkComponents);

export default router;