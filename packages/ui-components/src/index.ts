import type { App } from "vue";
import * as components from "./components";
import type { InstallOptions } from "./types";

// 导出所有组件
export * from "./components";
export * from "./types";
export * from "./utils";

// 创建一个插件，包含所有组件
const installer = (app: App, options?: InstallOptions) => {
  // 安装所有组件
  Object.keys(components).forEach((key) => {
    const component = (components as any)[key];
    if (component.install) {
      app.use(component, options);
    } else if (component.name) {
      app.component(component.name, component);
    }
  });
};

// 默认导出安装函数
export default installer;

// 支持按需导入
export const install = installer;
