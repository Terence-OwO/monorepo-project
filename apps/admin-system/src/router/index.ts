import { useUserStore } from "@/stores/user";
import { getToken } from "@/utils/auth";
import NProgress from "nprogress";
import "nprogress/nprogress.css";
import type { RouteRecordRaw } from "vue-router";
import { createRouter, createWebHistory } from "vue-router";

// 配置进度条
NProgress.configure({ showSpinner: false });

// 路由配置
const routes: RouteRecordRaw[] = [
  {
    path: "/login",
    name: "Login",
    component: () => import("@/views/login/index.vue"),
    meta: {
      title: "登录",
      requiresAuth: false,
    },
  },
  {
    path: "/",
    component: () => import("@/layout/index.vue"),
    redirect: "/dashboard",
    meta: {
      requiresAuth: true,
    },
    children: [
      {
        path: "dashboard",
        name: "Dashboard",
        component: () => import("@/views/dashboard/index.vue"),
        meta: {
          title: "仪表板",
          icon: "Dashboard",
        },
      },
      {
        path: "users",
        name: "Users",
        component: () => import("@/views/users/index.vue"),
        meta: {
          title: "用户管理",
          icon: "User",
        },
      },
      {
        path: "components/card",
        name: "Card",
        component: () => import("@/views/components/card.vue"),
        meta: {
          title: "卡片组件",
          icon: "Document",
        },
      },
    ],
  },
  {
    path: "/:pathMatch(.*)*",
    name: "NotFound",
    component: () => import("@/views/error/404.vue"),
    meta: {
      title: "页面不存在",
    },
  },
];

// 创建路由实例
const router = createRouter({
  history: createWebHistory(),
  routes,
  scrollBehavior: () => ({ top: 0 }),
});

// 路由守卫
router.beforeEach(async (to, from, next) => {
  NProgress.start();

  const userStore = useUserStore();
  const token = getToken();

  // 设置页面标题
  if (to.meta?.title) {
    document.title = `${to.meta.title} - Admin System`;
  }

  // 如果要去登录页面且已经登录，重定向到首页
  if (to.path === "/login" && token && userStore.userInfo) {
    next("/");
    return;
  }

  // 需要认证的页面
  if (to.meta?.requiresAuth !== false) {
    if (!token) {
      next("/login");
      return;
    }

    // 如果没有用户信息，获取用户信息
    if (!userStore.userInfo) {
      try {
        await userStore.getUserInfo();
      } catch (error) {
        console.error("获取用户信息失败:", error);
        userStore.logout();
        next("/login");
        return;
      }
    }
  }

  next();
});

router.afterEach(() => {
  NProgress.done();
});

export default router;
