import * as ElementPlusIconsVue from "@element-plus/icons-vue";
import ElementPlus from "element-plus";
import zhCn from "element-plus/dist/locale/zh-cn.mjs";
import { createPinia } from "pinia";
import piniaPluginPersistedstate from "pinia-plugin-persistedstate";
import { createApp } from "vue";

// 导入UI组件库
import UIComponents from "@monorepo-project/ui-components";
import "@monorepo-project/ui-components/dist/ui-components.css";

import App from "./App.vue";
import router from "./router";

// 导入样式
import "element-plus/dist/index.css";
import "./styles/index.scss";

// 创建应用实例
const app = createApp(App);

// 创建Pinia实例并配置持久化
const pinia = createPinia();
pinia.use(piniaPluginPersistedstate);

// 注册Element Plus图标
for (const [key, component] of Object.entries(ElementPlusIconsVue)) {
  app.component(key, component);
}

// 使用插件
app.use(pinia);
app.use(router);
app.use(ElementPlus, {
  locale: zhCn,
  size: "default",
});
app.use(UIComponents);

// 挂载应用
app.mount("#app");
