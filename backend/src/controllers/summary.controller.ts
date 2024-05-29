import { SummaryService } from '@/services/summary.service';
import { NextFunction, Request, Response } from 'express';
import { Container } from 'typedi';
import { SummaryModel } from '@/models/summary.model';

declare module 'express-serve-static-core' {
  interface Request {
    file: any;
  }
}

export class SummaryController {
  public summary = Container.get(SummaryService);

  public getTextSummary = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { text, deviceId }: { text: string; deviceId: string } = req.body;
      if (!text) {
        throw new Error('Text is required');
      }
      if (!deviceId) {
        throw new Error('Device ID is required');
      }
      const summary: string = await this.summary.textSummary(text, deviceId);

      res.status(200).json({ data: summary, message: 'summary' });
    } catch (error) {
      next(error);
    }
  };

  public getYoutubeSummary = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { url, title, deviceId }: { url: string; title: string; deviceId: string } = req.body;
      if (!url) {
        throw new Error('URL is required');
      }
      if (!deviceId) {
        throw new Error('Device ID is required');
      }
      const summary: string = await this.summary.youtubeSummary(url, title, deviceId);

      res.status(200).json({ data: summary, message: 'summary' });
    } catch (error) {
      next(error);
    }
  };

  private async addDeviceId(deviceId: string) {
    const summary = new SummaryModel({ deviceId });
    await summary.save();
  }

  private async countDeviceId(deviceId: string) {
    const summary = await SummaryModel.find({ deviceId }).countDocuments();
    return summary;
  }

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

  public audioSummary = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const file = req.file;

      if (!file) {
        throw new Error('Audio file is required');
      }

      const summary = await this.summary.audioSummary(file.buffer, 'device-id');

      res.status(200).json({ data: summary, message: 'summary' });
    } catch (error) {
      next(error);
    }
  };
}
