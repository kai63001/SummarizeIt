import { Service } from 'typedi';
import { OpenAIService } from './openai.service';
import { logger } from '@/utils/logger';
import { YoutubeTranscript } from 'youtube-transcript';
import openaiTokenCounter from 'openai-gpt-token-counter';
import axios from 'axios';
import { SummaryModel } from '@/models/summary.model';
import he from 'he';
import ytdl from 'ytdl-core';
import ffmpegPath from 'ffmpeg-static';
import ffmpeg from 'fluent-ffmpeg';

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
    try {
      await SummaryModel.create({ deviceId, textLength: text.length });
    } catch (error) {
      logger.error(error);
    }

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
    // limit characters to 200000
    if (text.length > 200000) {
      throw new Error('Text input is too long limit to 200,000 characters');
    }
    if (typeof text !== 'string' || text.trim() === '') {
      throw new Error('Invalid text input');
    }
    const summary = await this.openai.textSummary(text);
    logger.info('Summary generated successfully.');

    try {
      // save to db
      await SummaryModel.create({ deviceId, textLength: text.length });
    } catch (error) {
      console.error(error);
    }

    return {
      text,
      summary,
    };
  }

  /**
   * Makes the text shorter or longer based on the specified status.
   * @param fullText - The full text to be summarized.
   * @param summarizeText - The text used for summarization.
   * @param status - The status indicating whether to make the text shorter or longer.
   * @returns A Promise that resolves to an object containing the full text, summarize text, and the generated summary.
   * @throws Error if the text input is too long or invalid.
   */
  public async makeItShorterOrLonger(fullText: string, summarizeText: string, status: 'shorter' | 'longer', deviceId: string): Promise<any> {
    const tokens = await this.countTokens(fullText);
    logger.info(`Token input: ${tokens}`);
    // limit characters to 200000
    if (fullText.length > 200000) {
      throw new Error('Text input is too long limit to 200,000 characters');
    }
    if (typeof fullText !== 'string' || fullText.trim() === '') {
      throw new Error('Invalid text input');
    }
    let summary = '';
    if (status === 'shorter') {
      summary = await this.openai.makeItShortter(fullText, summarizeText);
    } else {
      summary = await this.openai.makeItLonger(fullText, summarizeText);
    }
    logger.info('Summary generated successfully.');

    try {
      // save to db
      await SummaryModel.create({ deviceId, textLength: summary.length });
    } catch (error) {
      console.error(error);
    }

    return {
      fullText,
      summarizeText,
      summary,
    };
  }

  private convertToTime(seconds: number) {
    // 00:00:00
    const hours = Math.floor(seconds / 3600) < 1 ? '' : `${Math.floor(seconds / 3600)}:`;
    const minutes = Math.floor((seconds % 3600) / 60) < 10 ? `0${Math.floor((seconds % 3600) / 60)}` : Math.floor((seconds % 3600) / 60);
    // should have 0 in front of single digit
    const sec = Math.floor(seconds % 60) < 10 ? `0${Math.floor(seconds % 60)}` : Math.floor(seconds % 60);
    return `${hours}${minutes}:${sec}`;
  }

  /**
   * Retrieves the language support for a given URL.
   *
   * @param url - The URL of the video for which to fetch the language support.
   * @returns A promise that resolves to the language support.
   * @throws If an error occurs while fetching the language support.
   */
  public async getLanguageSupport(url: string) {
    return await YoutubeTranscript.fetchTranscript(url, {
      lang: 'ttt',
    }).catch((err: any) => {
      const error = err.message.toString();
      console.log(error);
      if (error.includes('Transcript is disabled on this video')) return ['en'];
      const langee = error
        .substr(error.indexOf('ges:'))
        .replaceAll('ges:', '')
        .trim()
        .split(', ')
        .map((lang: string) => lang.trim());
      const duplicateFilter = langee.filter((item, index) => langee.indexOf(item) === index);
      return duplicateFilter;
    });
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
  public async youtubeSummary(url: string, title: string, deviceId: string, lang: string): Promise<any> {
    console.log('lang', lang);
    const subtitles = await YoutubeTranscript.fetchTranscript(url, {
      lang: lang || 'en',
    }).catch((err: any) => {
      console.error(err);
      throw new Error(err.message);
      // throw new Error('Error fetching transcript');
    });
    // sum all time of this video via offset and duration and return
    const sum = subtitles.reduce((acc, subtitle) => acc + subtitle.duration, 0);

    const textAndOffset = () => {
      const convertd = subtitles.map((subtitle: any) => {
        return {
          text: he.decode(subtitle.text.toString().trim()),
          offset: this.convertToTime(subtitle.offset),
        };
      });
      let textNew = '';
      convertd.forEach(element => {
        textNew += `${element.offset} \n${he.decode(element.text)} \n\n`;
      });
      return textNew;
    };
    const transcript = textAndOffset();

    // check if the video is more than 6 hours
    if (sum > 21600) {
      throw new Error('Video is too long, limit to 6 hours');
    }

    const text = subtitles.map((subtitle: any) => subtitle.text).join(' ');
    const tokens = await this.countTokens(text);
    logger.info(`Token input: ${tokens}`);
    const { summary } = await this.openai.youtubeSummary(text);

    logger.info(`Summary generated successfully. ${sum}`);

    // convert sum to mins
    const time = Math.ceil(sum / 60);

    try {
      // save to db
      await SummaryModel.create({ deviceId, textLength: text.length });
    } catch (error) {
      console.error(error);
    }

    return {
      text: he.decode(text),
      transcript: transcript,
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
    const lang = await this.getLanguageSupport(url);

    return {
      title: data.title,
      thumbnail: data.thumbnail_url,
      lang,
    };
  }

  public async youtubeSummaryWithDownload(url: string, title: string, deviceId: string): Promise<any> {
    if (!title) {
      throw new Error('Title is required');
    }
    //check title is not a song
    const checkSong = await this.openai.checkTitleVideoIsASong(title);
    if (checkSong) {
      throw new Error('This video is a song, not allowed to summarize');
    }

    const { time, buffer } = await this.downloadAndConvertYoutubeToBuffer(url);
    //convert time 00:03:29.40 to mins
    const convertTimer = () => {
      const timeArr = time.split(':');
      const hours = parseInt(timeArr[0]) * 60;
      const mins = parseInt(timeArr[1]);
      const sec = parseInt(timeArr[2]) / 60;
      return hours + mins + sec;
    };

    // check if the video is more than 4 hours
    if (convertTimer() > 240) {
      throw new Error('Video is too long, limit to 4 hours');
    }

    const { text } = await this.openai.getAudioTranscription(buffer);

    const { summary } = await this.openai.youtubeSummary(text);

    try {
      // save to db
      await SummaryModel.create({ deviceId, textLength: text.length });
    } catch (error) {
      console.error(error);
    }

    return {
      text: he.decode(text),
      summary,
      time: convertTimer(),
      title,
    };
  }

  public async downloadAndConvertYoutubeToBuffer(youtubeUrl: string): Promise<{
    buffer: Buffer;
    time: string;
  }> {
    return new Promise((resolve, reject) => {
      ffmpeg.setFfmpegPath(ffmpegPath);

      const audioStream = ytdl(youtubeUrl, { quality: 'highestaudio' });

      const chunks: Buffer[] = [];
      let time: string;
      const ffmpegProcess = ffmpeg(audioStream)
        .format('mp3')
        .on('error', reject)
        .on('codecData', function (data) {
          time = data.duration;
        })
        .on('end', () => {
          const buffer = Buffer.concat(chunks);
          resolve({
            buffer,
            time,
          });
        })
        .pipe();

      ffmpegProcess.on('data', chunk => chunks.push(chunk));
    });
  }
}
