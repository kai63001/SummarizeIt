import { Service } from 'typedi';
import OpenAI, { toFile } from 'openai';
import { OPENAI_API_KEY } from '@/config';
import { jsonrepair } from 'jsonrepair';
import { logger } from '@/utils/logger';

@Service()
export class OpenAIService {
  private openai: OpenAI;

  constructor() {
    this.openai = new OpenAI({
      apiKey: OPENAI_API_KEY,
    });
  }

  public async textSummary(text: string): Promise<string> {
    try {
      if (typeof text !== 'string' || text.trim() === '') {
        throw new Error('Invalid text input');
      }
      const completion = await this.openai.chat.completions.create({
        messages: [
          {
            role: 'system',
            content: `Create a concise summary of the provided text, focusing on its key points and main ideas. Include relevant details and examples to support these main ideas. Ensure the summary is clear and easy to understand, capturing all essential information without any unnecessary repetition. The length of the summary should be appropriate to the original text's complexity, offering a thorough overview without omitting crucial details and I want time that this summary save in a sec. and return me json like this {summary: 'summary',title: 'title', time: 5} time is in mins. time base on your text complexity. that mean if your text is complex then time is more and if your text is simple then time is less.`,
          },
          {
            role: 'user',
            content:
              'What is a large language model (LLM)? A large language model (LLM) is a type of artificial intelligence (AI) program that can recognize and generate text, among other tasks. LLMs are trained on huge sets of data',
          },
          {
            role: 'assistant',
            content: JSON.stringify({
              title: 'Large Language Model',
              summary:
                'A large language model (LLM) is a type of artificial intelligence (AI) program that can recognize and generate text, among other tasks. LLMs are trained on huge sets of data',
              time: 5,
            }),
          },
          {
            role: 'user',
            content: text,
          },
        ],
        model: 'gpt-3.5-turbo',
      });

      const summary = completion.choices[0].message.content;
      const output = JSON.parse(jsonrepair(summary));
      logger.info(`Token usage: ${completion.usage.total_tokens}`);
      if (output.title === undefined || output.title === '' || output.title == 'Error') {
        throw new Error('Error in text summary');
      }
      return output;
    } catch (error) {
      logger.error(error);
      throw Error('Error in text summary');
    }
  }

  public async makeItShortter(fullText: string, summary: string): Promise<string> {
    const completion = await this.openai.chat.completions.create({
      messages: [
        {
          role: 'system',
          content: `Create a concise summary of the provided text, focusing on its key points and main ideas. Include relevant details and examples to support these main ideas. Ensure the summary is clear and easy to understand, capturing all essential information without any unnecessary repetition. The length of the summary should be appropriate to the original text's complexity, offering a thorough overview without omitting crucial details and I want time that this summary save in a sec.`,
        },
        {
          role: 'user',
          content:
            'What is a large language model (LLM)? A large language model (LLM) is a type of artificial intelligence (AI) program that can recognize and generate text, among other tasks. LLMs are trained on huge sets of data',
        },
        {
          role: 'assistant',
          content:
            'A large language model (LLM) is a type of artificial intelligence (AI) program that can recognize and generate text, among other tasks. LLMs are trained on huge sets of data',
        },
        {
          role: 'user',
          content: 'make it shorter return only text',
        },
        {
          role: 'assistant',
          content: 'A large language model (LLM) is an AI program trained on vast data sets to recognize and generate text.',
        },
        {
          role: 'user',
          content: fullText,
        },
        {
          role: 'assistant',
          content: summary,
        },
        {
          role: 'user',
          content: 'make it shorter return only text',
        },
      ],
      model: 'gpt-3.5-turbo',
    });

    const response = completion.choices[0].message.content;
    //log token usage
    logger.info(`Token usage: ${completion.usage.total_tokens}`);
    return response;
  }

  public async makeItLonger(fullText: string, summary: string): Promise<string> {
    const completion = await this.openai.chat.completions.create({
      messages: [
        {
          role: 'system',
          content: `Create a concise summary of the provided text, focusing on its key points and main ideas. Include relevant details and examples to support these main ideas. Ensure the summary is clear and easy to understand, capturing all essential information without any unnecessary repetition. The length of the summary should be appropriate to the original text's complexity, offering a thorough overview without omitting crucial details and I want time that this summary save in a sec.`,
        },
        {
          role: 'user',
          content:
            'What is a large language model (LLM)? A large language model (LLM) is a type of artificial intelligence (AI) program that can recognize and generate text, among other tasks. LLMs are trained on huge sets of data',
        },
        {
          role: 'assistant',
          content:
            'A large language model (LLM) is a type of artificial intelligence (AI) program that can recognize and generate text, among other tasks. LLMs are trained on huge sets of data',
        },
        {
          role: 'user',
          content: 'make it longer',
        },
        {
          role: 'assistant',
          content:
            'A large language model (LLM) is a sophisticated artificial intelligence (AI) program designed to understand and produce human language. These models are capable of recognizing and generating text, performing various language-related tasks, and responding to different contexts',
        },
        {
          role: 'user',
          content: fullText,
        },
        {
          role: 'assistant',
          content: summary,
        },
        {
          role: 'user',
          content: 'make it longer',
        },
      ],
      model: 'gpt-3.5-turbo',
    });

    const response = completion.choices[0].message.content;
    //log token usage
    logger.info(`Token usage: ${completion.usage.total_tokens}`);
    return response;
  }

  public async youtubeSummary(text: string): Promise<any> {
    const completion = await this.openai.chat.completions.create({
      messages: [
        {
          role: 'system',
          content: `Create a concise summary of the provided text, focusing on its key points and main ideas. Include relevant details and examples to support these main ideas. Ensure the summary is clear and easy to understand, capturing all essential information without any unnecessary repetition. The length of the summary should be appropriate to the original text's complexity, offering a thorough overview without omitting crucial details and I want time that this summary save in a sec. and return me json like this {summary: 'summary'}`,
        },
        {
          role: 'user',
          content:
            'What is a large language model (LLM)? A large language model (LLM) is a type of artificial intelligence (AI) program that can recognize and generate text, among other tasks. LLMs are trained on huge sets of data',
        },
        {
          role: 'assistant',
          content: JSON.stringify({
            summary:
              'A large language model (LLM) is a type of artificial intelligence (AI) program that can recognize and generate text, among other tasks. LLMs are trained on huge sets of data',
          }),
        },
        {
          role: 'user',
          content: text,
        },
      ],
      model: 'gpt-3.5-turbo',
    });

    const summary = completion.choices[0].message.content;
    const output = JSON.parse(jsonrepair(summary));
    //log token usage
    logger.info(`Token usage: ${completion.usage.total_tokens}`);
    return output;
  }

  public async checkTitleVideoIsASong(title: string): Promise<boolean> {
    const completion = await this.openai.chat.completions.create({
      messages: [
        {
          role: 'system',
          content: `Check if the title of the video is a song or not. If the title is a song, return true; otherwise, return false. for example, if the title is "Alan Walker - Faded", the output should be true. or lofi chill beats to study/relax to`,
        },
        {
          role: 'user',
          content: 'Daily work space 📚 Lofi deep focus study work concentration [chill lo-fi hiphop beats]',
        },
        {
          role: 'assistant',
          content: 'true',
        },
        {
          role: 'user',
          content: 'Relax with my cat - beats to sleep/study x Fall In Luv',
        },
        {
          role: 'assistant',
          content: 'true',
        },
        {
          role: 'user',
          content: 'My Quest to Cure Prion Disease — Before It’s Too Late | Sonia Vallabh | TED',
        },
        {
          role: 'assistant',
          content: 'false',
        },
        {
          role: 'user',
          content: title,
        },
      ],
      model: 'gpt-3.5-turbo',
    });

    const output = completion.choices[0].message.content;
    const response = JSON.parse(jsonrepair(output));
    //log token usage
    logger.info(`Token usage: ${completion.usage.total_tokens}`);
    return response;
  }

  public async getAudioTranscription(audio: Buffer): Promise<any> {
    const file = await toFile(Buffer.from(audio), 'audio.m4a');
    const transcription = await this.openai.audio.transcriptions.create({
      file: file,
      model: 'whisper-1',
    });

    return transcription;
  }
}
