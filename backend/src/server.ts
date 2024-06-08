import { App } from '@/app';
import { AuthRoute } from '@routes/auth.route';
import { UserRoute } from '@routes/users.route';
import { SummaryRoute } from '@routes/summary.route';
import { HomeRoute } from './routes/home.route';
import { ValidateEnv } from '@utils/validateEnv';

ValidateEnv();

const app = new App([new UserRoute(), new AuthRoute(), new SummaryRoute(), new HomeRoute()]);

app.listen();
