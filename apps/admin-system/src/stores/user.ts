import router from "@/router";
import { getToken, removeToken, setToken } from "@/utils/auth";
import { defineStore } from "pinia";
import { ref } from "vue";

export interface UserInfo {
  id: number;
  username: string;
  nickname: string;
  email: string;
  avatar?: string;
  roles: string[];
  permissions: string[];
}

export interface LoginParams {
  username: string;
  password: string;
}

export const useUserStore = defineStore(
  "user",
  () => {
    const token = ref<string>(getToken() || "");
    const userInfo = ref<UserInfo | null>(null);
    const roles = ref<string[]>([]);
    const permissions = ref<string[]>([]);

    // 登录
    const login = async (loginParams: LoginParams) => {
      try {
        // 模拟登录请求
        const response = {
          data: {
            token: "mock-token-" + Date.now(),
            user: {
              id: 1,
              username: loginParams.username,
              nickname: "管理员",
              email: "admin@example.com",
              avatar: "/default-avatar.png",
              roles: ["admin"],
              permissions: ["*"],
            },
          },
        };

        const { token: accessToken, user } = response.data;

        token.value = accessToken;
        userInfo.value = user;
        roles.value = user.roles;
        permissions.value = user.permissions;

        setToken(accessToken);

        return response;
      } catch (error) {
        console.error("登录失败:", error);
        throw error;
      }
    };

    // 获取用户信息
    const getUserInfo = async () => {
      try {
        // 模拟获取用户信息
        const response = {
          data: {
            id: 1,
            username: "admin",
            nickname: "管理员",
            email: "admin@example.com",
            avatar: "/default-avatar.png",
            roles: ["admin"],
            permissions: ["*"],
          },
        };

        userInfo.value = response.data;
        roles.value = response.data.roles;
        permissions.value = response.data.permissions;

        return response.data;
      } catch (error) {
        console.error("获取用户信息失败:", error);
        throw error;
      }
    };

    // 更新用户信息
    const updateUserInfo = async (data: Partial<UserInfo>) => {
      try {
        // 模拟更新用户信息
        if (userInfo.value) {
          userInfo.value = { ...userInfo.value, ...data };
        }
        return userInfo.value;
      } catch (error) {
        console.error("更新用户信息失败:", error);
        throw error;
      }
    };

    // 登出
    const logout = async () => {
      try {
        // 清除本地存储
        token.value = "";
        userInfo.value = null;
        roles.value = [];
        permissions.value = [];

        removeToken();

        // 跳转到登录页
        router.push("/login");
      } catch (error) {
        console.error("登出失败:", error);
        throw error;
      }
    };

    // 检查权限
    const hasPermission = (permission: string) => {
      return (
        permissions.value.includes("*") ||
        permissions.value.includes(permission)
      );
    };

    // 检查角色
    const hasRole = (role: string) => {
      return roles.value.includes(role);
    };

    return {
      // 状态
      token,
      userInfo,
      roles,
      permissions,

      // 方法
      login,
      logout,
      getUserInfo,
      updateUserInfo,
      hasPermission,
      hasRole,
    };
  },
  {
    persist: {
      key: "user-store",
      storage: localStorage,
      pick: ["userInfo", "roles", "permissions"],
    },
  }
);
