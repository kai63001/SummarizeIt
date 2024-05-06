import { IsString, IsNotEmpty } from 'class-validator';

export class TextSummaryDto {
  @IsString()
  @IsNotEmpty()
  public text: string;
}

export class YoutubeSummaryDto {
  @IsString()
  @IsNotEmpty()
  public url: string;
}
