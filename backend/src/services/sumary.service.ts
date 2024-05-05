import { Service } from 'typedi';

@Service()
export class SumaryService {
  public async textSumary(text: string): Promise<string> {
    return text.split(' ').slice(0, 5).join(' ');
  }
}
