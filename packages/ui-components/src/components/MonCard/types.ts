import type { CSSProperties } from "vue";

export interface MonCardProps {
  /**
   * 卡片标题
   */
  header?: string;

  /**
   * 卡片体样式
   */
  bodyStyle?: CSSProperties;

  /**
   * 卡片体类名
   */
  bodyClass?: string;

  /**
   * 卡片阴影显示时机
   */
  shadow?: "always" | "hover" | "never";

  /**
   * 是否显示边框
   */
  bordered?: boolean;

  /**
   * 是否可悬停
   */
  hoverable?: boolean;

  /**
   * 是否加载中
   */
  loading?: boolean;

  /**
   * 自定义类名
   */
  class?: string | string[] | Record<string, boolean>;
}
