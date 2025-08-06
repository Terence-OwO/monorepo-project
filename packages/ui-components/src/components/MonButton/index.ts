import type { App } from "vue";
import MonButton from "./MonButton.vue";

MonButton.install = (app: App) => {
  app.component("MonButton", MonButton);
};

export default MonButton;
export type { MonButtonProps } from "./types";
