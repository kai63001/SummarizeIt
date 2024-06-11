import { Service } from 'typedi';
import OpenAI, { toFile } from 'openai';
import { OPENAI_API_KEY, TOKEN_RESIZE_API } from '@/config';
import { jsonrepair } from 'jsonrepair';
import { logger } from '@/utils/logger';
import axios from 'axios';

@Service()
export class OpenAIService {
  private openai: OpenAI;

  constructor() {
    this.openai = new OpenAI({
      apiKey: OPENAI_API_KEY,
    });
  }

  public splitText(text: string): string[] {
    const maxChunkSize = 2048;
    const chunks: string[] = [];
    let currentChunk = '';

    for (const sentence of text.split('.')) {
      if (currentChunk.length + sentence.length < maxChunkSize) {
        currentChunk += sentence + '.';
      } else {
        chunks.push(currentChunk.trim());
        currentChunk = sentence + '.';
      }
    }

    if (currentChunk) {
      chunks.push(currentChunk.trim());
    }

    return chunks;
  }

  public async resizeTokenUsage(text: string) {
    try {
      const result = await axios.post(`${TOKEN_RESIZE_API}/gpt`, {
        data: text,
      });
      return result.data;
    } catch (error) {
      logger.error(error);
      return text;
    }
  }

  public async generateSummary(text: string): Promise<string> {
    const inputChunks = this.splitText(text);
    const outputChunks: string[] = [];
    for (const chunk of inputChunks) {
      const response = await this.openai.chat.completions.create({
        messages: [
          {
            role: 'system',
            content: `Create a concise summary of the provided text, focusing on its key points and main ideas. Include relevant details and examples to support these main ideas. Ensure the summary is clear and easy to understand, capturing all essential information without any unnecessary repetition. The length of the summary should be appropriate to the original text's complexity, offering a thorough overview without omitting crucial details.`,
          },
          {
            role: 'user',
            content: chunk,
          },
        ],
        model: 'gpt-3.5-turbo',
      });

      const summary = response.choices[0].message.content;
      console.log(`Token usage: ${response.usage.total_tokens}`);
      console.log(`Summary: ${summary}`);
      outputChunks.push(summary);
    }
    return outputChunks.join(' ');
  }

  public async textSummary(text: string): Promise<string> {
    const data = await this.resizeTokenUsage(text);
    const message = data['compressed_prompt_list'].join(' ');
    const compressed_tokens = data['compressed_tokens'];
    const origin_tokens = data['origin_tokens'];
    logger.info(`Compressed tokens: ${compressed_tokens}, Origin tokens: ${origin_tokens}`);
    // return this.generateSummary(text);
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
            content: message,
          },
        ],
        model: 'gpt-3.5-turbo',
      });

      const summary = completion.choices[0].message.content;
      const output = JSON.parse(jsonrepair(summary));
      logger.info(`Token usage: ${completion.usage.total_tokens}`);
      if (output.title === undefined || output.title === '' || output.title == 'Error') {
        logger.error('Error in text summary', output);
        throw new Error('Error in text summary');
      }
      return output;
    } catch (error) {
      logger.error('error', error);
      throw Error('Error in text summary');
    }
  }

  public async makeItShortter(fullText: string, summary: string): Promise<string> {
    const completion = await this.openai.chat.completions.create({
      messages: [
        {
          role: 'system',
          content: `Create a concise summary of the provided text, highlighting key points and main ideas. Include relevant details and examples for support. Ensure the summary is clear, capturing all essential information without repetition. The length should be appropriate to the text's complexity, providing a thorough overview without omitting crucial details. make it shorter`,
        },
        {
          role: 'user',
          content: summary,
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
          content: `Write a detailed summary of the provided text, emphasizing key points and main ideas. Include relevant details and examples to support these ideas. Ensure the summary is clear and comprehensive, capturing all essential information. The length should be sufficient to cover the text's complexity, offering a thorough overview without leaving out any crucial details.`,
        },
        {
          role: 'user',
          content: summary,
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
    const data = await this.resizeTokenUsage(text);
    const message = data['compressed_prompt_list'].join(' ');
    const compressed_tokens = data['compressed_tokens'];
    const origin_tokens = data['origin_tokens'];
    logger.info(`Compressed tokens: ${compressed_tokens}, Origin tokens: ${origin_tokens}`);

    const completion = await this.openai.chat.completions.create({
      messages: [
        {
          role: 'system',
          content: `To create a concise summary of the provided text that focuses on key points and main ideas, it's essential to extract and emphasize the most relevant details and examples that support the main ideas. The summary should be clear and understandable, ensuring that all essential information is captured without unnecessary repetition. The length should be proportionate to the complexity of the original text, offering a thorough overview without omitting crucial details. When handling ... language input, the summary will be returned in the original ... language to maintain consistency with the input. This summary process will be efficient, aiming to complete within a second, and the result will be returned in a JSON format like this: {summary: 'summary'}.`,
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
          content: message,
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
