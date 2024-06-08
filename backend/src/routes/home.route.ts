import { Router } from 'express';
import { Routes } from '@interfaces/routes.interface';

export class HomeRoute implements Routes {
  public path = '/';
  public router = Router();

  constructor() {
    this.initializeRoutes();
  }

  private initializeRoutes() {
    this.router.get(`${this.path}home`, (req, res) => res.send('Hello World!'));
  }
}
