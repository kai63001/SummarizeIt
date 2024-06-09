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
      const { url, title, deviceId, lang = 'en' }: { url: string; title: string; deviceId: string; lang: string } = req.body;
      if (!url) {
        throw new Error('URL is required');
      }
      if (!deviceId) {
        throw new Error('Device ID is required');
      }
      const summary: string = await this.summary.youtubeSummary(url, title, deviceId, lang);

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

  public getYoutubeDownload = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { url, title, deviceId }: { url: string; title: string; deviceId: string } = req.body;
      if (!url) {
        throw new Error('URL is required');
      }
      if (!deviceId) {
        throw new Error('Device ID is required');
      }

      const data = await this.summary.youtubeSummaryWithDownload(url, title, deviceId);

      res.status(200).json({ data, message: 'summary' });
    } catch (error) {
      next(error);
    }
  };

  public audioSummary = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const file = req.file;
      const deviceId = req.body.deviceId;

      if (!file) {
        throw new Error('Audio file is required');
      }

      const summary = await this.summary.audioSummary(file.buffer, deviceId);

      res.status(200).json({ data: summary, message: 'summary' });
    } catch (error) {
      next(error);
    }
  };

  public getLanguageSupport = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { url } = req.body;
      const languages = await this.summary.getLanguageSupport(url);

      res.status(200).json({ data: languages, message: 'summary' });
    } catch (error) {
      next(error);
    }
  };

  public shorterOrLongerSummary = async (req: Request, res: Response, next: NextFunction) => {
    try {
      const { original, text, type, deviceId }: { original: string; text: string; type: 'shorter' | 'longer'; deviceId: string } = req.body;
      if (!type) {
        throw new Error('Type is required');
      }
      if (!original) {
        throw new Error('Original text is required');
      }
      if (!text) {
        throw new Error('Text is required');
      }
      if (!deviceId) {
        throw new Error('Device ID is required');
      }
      const summary: string = await this.summary.makeItShorterOrLonger(original, text, type, deviceId);

      res.status(200).json({ data: summary, message: 'summary' });
    } catch (error) {
      next(error);
    }
  };
}
