import { defineStore } from "pinia";
import { computed, ref } from "vue";

export interface AppState {
  sidebar: {
    opened: boolean;
    withoutAnimation: boolean;
  };
  device: "desktop" | "tablet" | "mobile";
  theme: "light" | "dark";
  language: "zh-cn" | "en";
  size: "large" | "default" | "small";
}

export const useAppStore = defineStore(
  "app",
  () => {
    // 侧边栏状态
    const sidebar = ref({
      opened: true,
      withoutAnimation: false,
    });

    // 设备类型
    const device = ref<"desktop" | "tablet" | "mobile">("desktop");

    // 主题模式
    const theme = ref<"light" | "dark">("light");

    // 语言设置
    const language = ref<"zh-cn" | "en">("zh-cn");

    // 组件尺寸
    const size = ref<"large" | "default" | "small">("default");

    // 计算属性
    const isMobile = computed(() => device.value === "mobile");
    const isTablet = computed(() => device.value === "tablet");
    const isDesktop = computed(() => device.value === "desktop");

    // 切换侧边栏
    const toggleSideBar = () => {
      sidebar.value.opened = !sidebar.value.opened;
      sidebar.value.withoutAnimation = false;
    };

    const toggleSidebar = () => {
      toggleSideBar();
    };

    // 关闭侧边栏
    const closeSideBar = (withoutAnimation: { withoutAnimation: boolean }) => {
      sidebar.value.opened = false;
      sidebar.value.withoutAnimation = withoutAnimation.withoutAnimation;
    };

    const closeSidebar = (withoutAnimation: { withoutAnimation: boolean }) => {
      closeSideBar(withoutAnimation);
    };

    // 打开侧边栏
    const openSideBar = () => {
      sidebar.value.opened = true;
      sidebar.value.withoutAnimation = false;
    };

    // 设置设备类型
    const setDevice = (deviceType: "desktop" | "tablet" | "mobile") => {
      device.value = deviceType;
    };

    // 设置主题
    const setTheme = (themeMode: "light" | "dark") => {
      theme.value = themeMode;
    };

    // 设置语言
    const setLanguage = (lang: "zh-cn" | "en") => {
      language.value = lang;
    };

    // 设置尺寸
    const setSize = (componentSize: "large" | "default" | "small") => {
      size.value = componentSize;
    };

    // 初始化应用
    const initializeApp = () => {
      // 检测设备类型
      const width = window.innerWidth;
      if (width < 768) {
        setDevice("mobile");
      } else if (width < 1024) {
        setDevice("tablet");
      } else {
        setDevice("desktop");
      }
    };

    return {
      // 状态
      sidebar,
      device,
      theme,
      language,
      size,

      // 计算属性
      isMobile,
      isTablet,
      isDesktop,

      // 方法
      toggleSideBar,
      toggleSidebar,
      closeSideBar,
      closeSidebar,
      openSideBar,
      setDevice,
      setTheme,
      setLanguage,
      setSize,
      initializeApp,
    };
  },
  {
    persist: {
      key: "app-store",
      storage: localStorage,
      pick: ["theme", "language", "size", "sidebar.opened"],
    },
  }
);
