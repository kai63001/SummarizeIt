import { Service } from 'typedi';
import OpenAI from 'openai';
import { OPENAI_API_KEY } from '@/config';

@Service()
export class OpenAIService {
  private openai: OpenAI;

  constructor() {
    this.openai = new OpenAI({
      apiKey: OPENAI_API_KEY,
    });
  }

  public async textSummary(text: string): Promise<string> {
    if (typeof text !== 'string' || text.trim() === '') {
      throw new Error('Invalid text input');
    }
    const completion = await this.openai.chat.completions.create({
      messages: [
        {
          role: 'system',
          content: `Create a concise summary of the provided text, focusing on its key points and main ideas. Include relevant details and examples to support these main ideas. Ensure the summary is clear and easy to understand, capturing all essential information without any unnecessary repetition. The length of the summary should be appropriate to the original text's complexity, offering a thorough overview without omitting crucial details.`,
        },
        {
          role: 'user',
          content: text,
        },
      ],
      model: 'gpt-3.5-turbo',
    });

    console.log(completion.choices[0]);
    return completion.choices[0].message.content;
  }
}
