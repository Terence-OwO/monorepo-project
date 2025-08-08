import Cookies from "js-cookie";

const TOKEN_KEY = "admin-token";

/**
 * 获取token
 */
export const getToken = (): string | undefined => {
  return Cookies.get(TOKEN_KEY);
};

/**
 * 设置token
 */
export const setToken = (token: string): void => {
  Cookies.set(TOKEN_KEY, token, { expires: 7 }); // 7天过期
};

/**
 * 移除token
 */
export const removeToken = (): void => {
  Cookies.remove(TOKEN_KEY);
};

/**
 * 检查是否已登录
 */
export const isLoggedIn = (): boolean => {
  return !!getToken();
};
