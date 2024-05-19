import { model, Schema, Document } from 'mongoose';
import { User } from '@interfaces/users.interface';

const UserSchema: Schema = new Schema({
  deviceId: { type: String, required: true },
  //type enum free, premium
  type: { type: String, required: true, enum: ['free', 'premium'], default: 'free' },
  createdAt: { type: Date, default: Date.now },
});

export const UserModel = model<User & Document>('User', UserSchema);
