import { SummaryService } from '@/services/summary.service';
import { NextFunction, Request, Response } from 'express';
import { Container } from 'typedi';

export class SummaryController {
  public summary = Container.get(SummaryService);

  public getTextSummary = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { text }: { text: string } = req.body;
      const summary: string = await this.summary.textSummary(text);

      res.status(200).json({ data: summary, message: 'summary' });
    } catch (error) {
      next(error);
    }
  };

  public getYoutubeSummary = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { url, title }: { url: string; title: string } = req.body;
      const summary: string = await this.summary.youtubeSummary(url, title);

      res.status(200).json({ data: summary, message: 'summary' });
    } catch (error) {
      next(error);
    }
  };

  public getYoutubeData = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { url }: { url: string } = req.query as { url: string };
      if (!url) {
        throw new Error('URL is required');
      }

      const data = await this.summary.getYoutubeData(url);

      res.status(200).json({ data, message: 'summary' });
    } catch (error) {
      next(error);
    }
  };
}
