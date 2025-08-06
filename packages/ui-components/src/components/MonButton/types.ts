import type { Component } from "vue";
import type { Size, Status } from "../../types";

export interface MonButtonProps {
  /**
   * 按钮类型
   */
  type?: Status | "default" | "primary" | "text";

  /**
   * 按钮尺寸
   */
  size?: Size;

  /**
   * 是否为朴素按钮
   */
  plain?: boolean;

  /**
   * 是否为圆角按钮
   */
  round?: boolean;

  /**
   * 是否为圆形按钮
   */
  circle?: boolean;

  /**
   * 是否为加载中状态
   */
  loading?: boolean;

  /**
   * 是否禁用状态
   */
  disabled?: boolean;

  /**
   * 图标组件
   */
  icon?: string | Component;

  /**
   * 是否默认聚焦
   */
  autofocus?: boolean;

  /**
   * 原生 type 属性
   */
  nativeType?: "button" | "submit" | "reset";

  /**
   * 自动在两个中文字符之间插入空格
   */
  autoInsertSpace?: boolean;

  /**
   * 自定义按钮颜色
   */
  color?: string;

  /**
   * 是否为暗色模式
   */
  dark?: boolean;

  /**
   * 是否为链接按钮
   */
  link?: boolean;

  /**
   * 是否为文字按钮
   */
  text?: boolean;

  /**
   * 是否显示背景色
   */
  bg?: boolean;

  /**
   * 自定义元素标签
   */
  tag?: string | Component;
}

export interface MonButtonEmits {
  /**
   * 点击事件
   */
  click: [event: MouseEvent];
}
