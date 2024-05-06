import { connect, set } from 'mongoose';
import { NODE_ENV, DB_MONGO_URI } from '@config';

export const dbConnection = async () => {
  const dbConfig = {
    url: DB_MONGO_URI,
    options: {
      useNewUrlParser: true,
      useUnifiedTopology: true,
    },
  };

  if (NODE_ENV !== 'production') {
    set('debug', true);
  }

  set('strictQuery', false);

  await connect(dbConfig.url, dbConfig.options as any);
};
