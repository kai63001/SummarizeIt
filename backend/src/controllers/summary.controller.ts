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
}
