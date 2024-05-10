import { Service } from 'typedi';
import { OpenAIService } from './openai.service';
import { logger } from '@/utils/logger';
import { YoutubeTranscript } from 'youtube-transcript';
import openaiTokenCounter from 'openai-gpt-token-counter';
import axios from 'axios';

@Service()
export class SummaryService {
  private openai: OpenAIService;

  constructor() {
    this.openai = new OpenAIService();
  }

  private async countTokens(text: string): Promise<number> {
    const tokens = await openaiTokenCounter.text(text, 'gpt-3.5-turbo');
    return tokens;
  }

  public async textSummary(text: string): Promise<string> {
    const tokens = await this.countTokens(text);
    logger.info(`Token input: ${tokens}`);
    // limit characters to 10000
    if (text.length > 10000) {
      throw new Error('Text input is too long limit to 10000 characters');
    }
    if (typeof text !== 'string' || text.trim() === '') {
      throw new Error('Invalid text input');
    }
    const summary = await this.openai.textSummary(text);
    logger.info('Summary generated successfully.');
    return summary;
  }

  public async youtubeSummary(url: string): Promise<any> {
    const subtitles = await YoutubeTranscript.fetchTranscript(url, {
      lang: 'en',
    });
    // sum all time of this video via offset and duration and return
    const sum = subtitles.reduce((acc, subtitle) => acc + subtitle.duration, 0);
    // check if the video is more than 35 minutes
    if (sum > 2100) {
      throw new Error('Video is too long, limit to 35 minutes');
    }

    const text = subtitles.map((subtitle: any) => subtitle.text).join(' ');
    const tokens = await this.countTokens(text);
    logger.info(`Token input: ${tokens}`);
    const { summary } = await this.openai.youtubeSummary(text);

    logger.info('Summary generated successfully.');

    return {
      text,
      summary,
      time: sum,
    };
  }

  public async getYoutubeData(url: string): Promise<any> {
    const response = await axios.get(`https://noembed.com/embed?url=${url}`);
    const data = response.data;

    return {
      title: data.title,
      thumbnail: data.thumbnail_url,
    };
  }
}
