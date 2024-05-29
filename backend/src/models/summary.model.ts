import { model, Schema, Document } from 'mongoose';
import { Summary } from '@/interfaces/summary.interface';

const SummarySchema: Schema = new Schema({
  deviceId: { type: String, required: true },
  textLength: { type: Number, required: true },
  createdAt: { type: Date, default: Date.now },
});

export const SummaryModel = model<Summary & Document>('Summary', SummarySchema);
