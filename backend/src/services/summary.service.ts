import { Service } from 'typedi';
import { OpenAIService } from './openai.service';
import { logger } from '@/utils/logger';
import { YoutubeTranscript } from 'youtube-transcript';
import openaiTokenCounter from 'openai-gpt-token-counter';
import axios from 'axios';
import { SummaryModel } from '@/models/summary.model';

@Service()
export class SummaryService {
  private openai: OpenAIService;

  constructor() {
    this.openai = new OpenAIService();
  }

  /**
   * Counts the number of tokens in the given text using the OpenAI token counter.
   * @param text - The text to count tokens for.
   * @returns A Promise that resolves to the number of tokens in the text.
   */
  private async countTokens(text: string): Promise<number> {
    const tokens = await openaiTokenCounter.text(text, 'gpt-3.5-turbo');
    return tokens;
  }

  /**
   * Generates a summary of the audio file.
   *
   * @param file - The audio file to generate the summary from.
   * @param deviceId - The ID of the device used to record the audio.
   * @returns A Promise that resolves to the generated summary as a string.
   */
  public async audioSummary(file: Buffer, deviceId: string): Promise<any> {
    const { text } = await this.openai.getAudioTranscription(file);

    const summary = await this.openai.textSummary(text);

    // save to db
    await SummaryModel.create({ deviceId, textLength: text.length });

    return {
      text,
      summary,
    };
  }

  /**
   * Generates a summary of the given text using OpenAI.
   * @param text - The input text to be summarized.
   * @param deviceId - The ID of the device used for the summary.
   * @returns A Promise that resolves to the generated summary as a string.
   * @throws Error if the text input is too long or invalid.
   */
  public async textSummary(text: string, deviceId: string): Promise<any> {
    const tokens = await this.countTokens(text);
    logger.info(`Token input: ${tokens}`);
    // limit characters to 10000
    if (text.length > 30000) {
      throw new Error('Text input is too long limit to 30000 characters');
    }
    if (typeof text !== 'string' || text.trim() === '') {
      throw new Error('Invalid text input');
    }
    const summary = await this.openai.textSummary(text);
    logger.info('Summary generated successfully.');

    // save to db
    await SummaryModel.create({ deviceId, textLength: text.length });

    return {
      text,
      summary,
    };
  }

  /**
   * Fetches the transcript of a YouTube video, generates a summary of the transcript,
   * and returns the summary along with other relevant information.
   *
   * @param url - The URL of the YouTube video.
   * @param title - The title of the YouTube video.
   * @param deviceId - The ID of the device.
   * @returns A Promise that resolves to an object containing the text, summary, time, and title of the video.
   * @throws An error if the video is longer than 35 minutes.
   */
  public async youtubeSummary(url: string, title: string, deviceId: string): Promise<any> {
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

    logger.info(`Summary generated successfully. ${sum}`);

    // convert sum to mins
    const time = Math.ceil(sum / 60);

    // save to db
    await SummaryModel.create({ deviceId, textLength: text.length });

    return {
      text,
      summary,
      time,
      title,
    };
  }

  /**
   * Retrieves YouTube data for a given URL.
   * @param url - The YouTube URL.
   * @returns A promise that resolves to an object containing the title and thumbnail URL.
   */
  public async getYoutubeData(url: string): Promise<any> {
    const response = await axios.get(`https://noembed.com/embed?url=${url}`);
    const data = response.data;

    return {
      title: data.title,
      thumbnail: data.thumbnail_url,
    };
  }
}
