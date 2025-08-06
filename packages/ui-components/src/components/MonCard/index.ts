import type { App } from "vue";
import MonCard from "./MonCard.vue";

MonCard.install = (app: App) => {
  app.component("MonCard", MonCard);
};

export default MonCard;
export type { MonCardProps } from "./types";
