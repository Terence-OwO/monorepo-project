/// <reference types="vite/client" />

declare module "*.vue" {
  import type { DefineComponent } from "vue";
  const component: DefineComponent<{}, {}, any>;
  export default component;
}

// Element Plus 组件类型声明
declare module "element-plus/dist/locale/zh-cn.mjs";
declare module "element-plus/dist/locale/en.mjs";
