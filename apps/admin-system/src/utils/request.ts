import router from "@/router";
import type {
  AxiosInstance,
  AxiosResponse,
  InternalAxiosRequestConfig,
} from "axios";
import axios from "axios";
import { ElMessage, ElMessageBox } from "element-plus";
import { getToken, removeToken } from "./auth";

// 响应数据接口
export interface ResponseData<T = any> {
  code: number;
  data: T;
  message: string;
  success: boolean;
}

// 创建axios实例
const service: AxiosInstance = axios.create({
  baseURL: "/api",
  timeout: 15000,
  headers: {
    "Content-Type": "application/json;charset=UTF-8",
  },
});

// 请求拦截器
service.interceptors.request.use(
  (config: InternalAxiosRequestConfig) => {
    // 添加token
    const token = getToken();
    if (token && config.headers) {
      config.headers.Authorization = `Bearer ${token}`;
    }

    return config;
  },
  (error) => {
    console.error("请求错误:", error);
    return Promise.reject(error);
  }
);

// 响应拦截器
service.interceptors.response.use(
  (response: AxiosResponse<ResponseData>) => {
    const res = response.data;

    // 如果返回的状态码为200，说明接口请求成功，可以正常拿到数据
    // 否则的话抛出错误
    if (res.code !== 200) {
      ElMessage({
        message: res.message || "请求失败",
        type: "error",
        duration: 5 * 1000,
      });

      // 401: 未授权
      if (res.code === 401) {
        ElMessageBox.confirm(
          "登录状态已过期，您可以继续留在该页面，或者重新登录",
          "系统提示",
          {
            confirmButtonText: "重新登录",
            cancelButtonText: "取消",
            type: "warning",
          }
        ).then(() => {
          removeToken();
          router.push("/login");
        });
      }

      return Promise.reject(new Error(res.message || "请求失败"));
    } else {
      return response;
    }
  },
  (error) => {
    console.error("响应错误:", error);

    let message = "请求失败";
    if (error.response) {
      switch (error.response.status) {
        case 401:
          message = "未授权，请登录";
          removeToken();
          router.push("/login");
          break;
        case 403:
          message = "拒绝访问";
          break;
        case 404:
          message = "请求地址出错";
          break;
        case 408:
          message = "请求超时";
          break;
        case 500:
          message = "服务器内部错误";
          break;
        case 501:
          message = "服务未实现";
          break;
        case 502:
          message = "网关错误";
          break;
        case 503:
          message = "服务不可用";
          break;
        case 504:
          message = "网关超时";
          break;
        case 505:
          message = "HTTP版本不受支持";
          break;
        default:
          message = `连接错误${error.response.status}`;
      }
    } else {
      if (error.message === "Network Error") {
        message = "网络异常";
      } else if (error.message.includes("timeout")) {
        message = "请求超时";
      } else if (error.message.includes("Request failed with status code")) {
        message =
          "系统接口" + error.message.substr(error.message.length - 3) + "异常";
      }
    }

    ElMessage({
      message,
      type: "error",
      duration: 5 * 1000,
    });

    return Promise.reject(error);
  }
);

export { service as request };
export default service;
