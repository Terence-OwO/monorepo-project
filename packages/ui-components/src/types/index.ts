import type { App } from "vue";

export interface InstallOptions {
  // 全局配置选项
  prefix?: string;
  locale?: string;
  size?: "large" | "default" | "small";
  zIndex?: number;
}

export interface ComponentInstaller {
  install: (app: App, options?: InstallOptions) => void;
}

// 通用组件 Props 类型
export interface BaseComponentProps {
  id?: string;
  class?: string | string[] | Record<string, boolean>;
  style?: string | Record<string, string>;
}

// 尺寸类型
export type Size = "large" | "default" | "small";

// 状态类型
export type Status = "success" | "warning" | "info" | "danger";

// 通用事件类型
export interface BaseEvents {
  click?: (event: MouseEvent) => void;
  focus?: (event: FocusEvent) => void;
  blur?: (event: FocusEvent) => void;
}

// 表单相关类型
export interface FormItemContext {
  validate: (trigger: string, callback?: (valid: boolean) => void) => void;
  clearValidate: () => void;
}

export interface FormContext {
  model: Record<string, any>;
  rules?: Record<string, any>;
  validateField: (prop: string, callback?: (valid: boolean) => void) => void;
  clearValidate: (props?: string | string[]) => void;
}
