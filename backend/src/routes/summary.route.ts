import { Router } from 'express';
import { Routes } from '@interfaces/routes.interface';
import { ValidationMiddleware } from '@middlewares/validation.middleware';
import { TextSummaryDto } from '@/dtos/summary.dto';
import { SummaryController } from '@/controllers/summary.controller';

export class SummaryRoute implements Routes {
  public path = '/summary';
  public router = Router();
  public summary = new SummaryController();

  constructor() {
    this.initializeRoutes();
  }

  private initializeRoutes() {
    this.router.post(`${this.path}/text-summary`, ValidationMiddleware(TextSummaryDto), this.summary.getTextSummary);
  }
}
