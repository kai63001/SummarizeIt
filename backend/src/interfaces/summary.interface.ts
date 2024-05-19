export interface OutputTextSummary {
  summary: string;
  time: string;
}

export interface YoutubeCaption {
  text: string;
  duration: number;
  offset: number;
  lang: string;
}

export interface Summary {
  _id?: string;
  deviceId: string;
  createdAt: Date;
}
