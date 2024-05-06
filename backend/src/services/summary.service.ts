import { Service } from 'typedi';
import { OpenAIService } from './openai.service';
import { logger } from '@/utils/logger';

@Service()
export class SummaryService {
  private openai: OpenAIService;

  constructor() {
    this.openai = new OpenAIService();
  }

  public async textSummary(text: string): Promise<string> {
    const summary = await this.openai.textSummary(text);
    logger.info('Summary generated successfully.');
    return summary;
  }
}
