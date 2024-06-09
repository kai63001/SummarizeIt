import { Router } from 'express';
import { Routes } from '@interfaces/routes.interface';
import { ValidationMiddleware } from '@middlewares/validation.middleware';
import { TextSummaryDto, YoutubeSummaryDto } from '@/dtos/summary.dto';
import { SummaryController } from '@/controllers/summary.controller';
import multer from 'multer';

const upload = multer({ storage: multer.memoryStorage() });
export class SummaryRoute implements Routes {
  public path = '/summary';
  public router = Router();
  public summary = new SummaryController();

  constructor() {
    this.initializeRoutes();
  }

  private initializeRoutes() {
    this.router.post(`${this.path}/text-summary`, ValidationMiddleware(TextSummaryDto), this.summary.getTextSummary);
    this.router.post(`${this.path}/youtube-summary`, ValidationMiddleware(YoutubeSummaryDto), this.summary.getYoutubeSummary);
    this.router.post(`${this.path}/youtube-summary-download`, ValidationMiddleware(YoutubeSummaryDto), this.summary.getYoutubeDownload);
    this.router.get(`${this.path}/get-youtube-data`, this.summary.getYoutubeData);
    this.router.post(`${this.path}/audio-summary`, upload.single('audio'), this.summary.audioSummary);
    this.router.post(`${this.path}/shorter-longer`, this.summary.shorterOrLongerSummary);
    this.router.post(`${this.path}/lang`, this.summary.getLanguageSupport);
  }
}
