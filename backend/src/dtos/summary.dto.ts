import { IsString, IsNotEmpty } from 'class-validator';

export class TextSummaryDto {
  @IsString()
  @IsNotEmpty()
  public text: string;
}
