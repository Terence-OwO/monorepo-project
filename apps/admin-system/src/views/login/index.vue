<template>
  <div class="login-container">
    <!-- 背景动态元素 -->
    <div class="background-shapes">
      <div class="shape shape-1"></div>
      <div class="shape shape-2"></div>
      <div class="shape shape-3"></div>
    </div>

    <!-- 登录卡片 -->
    <div class="login-card">
      <!-- 品牌标识 -->
      <div class="brand-section">
        <div class="logo">
          <svg width="48" height="48" viewBox="0 0 48 48" fill="none">
            <rect width="48" height="48" rx="12" fill="url(#gradient)" />
            <path
              d="M16 24L22 30L32 18"
              stroke="white"
              stroke-width="3"
              stroke-linecap="round"
              stroke-linejoin="round"
            />
            <defs>
              <linearGradient id="gradient" x1="0%" y1="0%" x2="100%" y2="100%">
                <stop offset="0%" style="stop-color: #007aff" />
                <stop offset="100%" style="stop-color: #5856d6" />
              </linearGradient>
            </defs>
          </svg>
        </div>
        <h1 class="title">欢迎回来</h1>
        <p class="subtitle">请登录您的账户以继续</p>
      </div>

      <!-- 登录表单 -->
      <el-form
        ref="loginFormRef"
        :model="loginForm"
        :rules="loginRules"
        class="login-form"
        autocomplete="on"
        label-position="top"
      >
        <el-form-item prop="username" class="form-item">
          <label class="form-label">用户名</label>
          <div class="input-wrapper">
            <el-icon class="input-icon"><User /></el-icon>
            <el-input
              ref="username"
              v-model="loginForm.username"
              placeholder="请输入用户名"
              name="username"
              type="text"
              tabindex="1"
              autocomplete="on"
              class="modern-input"
            />
          </div>
        </el-form-item>

        <el-tooltip
          v-model:visible="capsTooltip"
          content="Caps Lock 已开启"
          placement="top"
          manual
        >
          <el-form-item prop="password" class="form-item">
            <label class="form-label">密码</label>
            <div class="input-wrapper">
              <el-icon class="input-icon"><Lock /></el-icon>
              <el-input
                :key="passwordType"
                ref="password"
                v-model="loginForm.password"
                :type="passwordType"
                placeholder="请输入密码"
                name="password"
                tabindex="2"
                autocomplete="on"
                class="modern-input"
                @keyup="checkCapslock"
                @blur="capsTooltip = false"
                @keyup.enter="handleLogin"
              />
              <button type="button" class="password-toggle" @click="showPwd">
                <el-icon>
                  <View v-if="passwordType === 'password'" />
                  <Hide v-else />
                </el-icon>
              </button>
            </div>
          </el-form-item>
        </el-tooltip>

        <el-button
          :loading="loading"
          type="primary"
          class="login-button"
          @click.prevent="handleLogin"
        >
          <span v-if="!loading">登录</span>
          <span v-else>正在登录...</span>
        </el-button>
      </el-form>

      <!-- 演示信息 -->
      <div class="demo-info">
        <div class="demo-card">
          <h4>演示账户</h4>
          <div class="demo-credentials">
            <div class="credential-item">
              <span class="label">用户名:</span>
              <span class="value">admin</span>
            </div>
            <div class="credential-item">
              <span class="label">密码:</span>
              <span class="value">任意密码</span>
            </div>
          </div>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useUserStore } from "@/stores/user";
import { Hide, Lock, User, View } from "@element-plus/icons-vue";
import type { FormInstance } from "element-plus";
import { nextTick, reactive, ref } from "vue";
import { useRoute, useRouter } from "vue-router";

const userStore = useUserStore();
const router = useRouter();
const route = useRoute();

const loginFormRef = ref<FormInstance>();
const passwordType = ref("password");
const capsTooltip = ref(false);
const loading = ref(false);

const loginForm = reactive({
  username: "admin",
  password: "123456",
});

const validateUsername = (rule: any, value: any, callback: any) => {
  if (!value) {
    callback(new Error("请输入用户名"));
  } else {
    callback();
  }
};

const validatePassword = (rule: any, value: any, callback: any) => {
  if (value.length < 6) {
    callback(new Error("密码不能少于6位"));
  } else {
    callback();
  }
};

const loginRules = {
  username: [{ required: true, trigger: "blur", validator: validateUsername }],
  password: [{ required: true, trigger: "blur", validator: validatePassword }],
};

const showPwd = () => {
  if (passwordType.value === "password") {
    passwordType.value = "";
  } else {
    passwordType.value = "password";
  }
  nextTick(() => {
    // focus
  });
};

const checkCapslock = (e: KeyboardEvent) => {
  const { key } = e;
  capsTooltip.value = !!(key && key.length === 1 && key >= "A" && key <= "Z");
};

const handleLogin = () => {
  loginFormRef.value?.validate(async (valid: boolean) => {
    if (valid) {
      loading.value = true;
      try {
        await userStore.login(loginForm);
        const redirect = (route.query.redirect as string) || "/";
        router.push({ path: redirect });
      } catch (error) {
        console.error("登录失败:", error);
      } finally {
        loading.value = false;
      }
    }
  });
};
</script>

<style lang="scss" scoped>
// 苹果风格配色方案
$primary-blue: #007aff;
$primary-purple: #5856d6;
$background-light: #f2f2f7;
$background-dark: #000000;
$surface-light: rgba(255, 255, 255, 0.95);
$surface-dark: rgba(28, 28, 30, 0.95);
$text-primary: #1d1d1f;
$text-secondary: #86868b;
$text-tertiary: #c7c7cc;
$border-light: rgba(0, 0, 0, 0.1);
$shadow-light: rgba(0, 0, 0, 0.1);
$shadow-dark: rgba(0, 0, 0, 0.3);

.login-container {
  min-height: 100vh;
  width: 100%;
  display: flex;
  align-items: center;
  justify-content: center;
  position: relative;
  overflow: hidden;

  // 动态渐变背景
  background: linear-gradient(
    135deg,
    #667eea 0%,
    #764ba2 25%,
    #f093fb 50%,
    #f5576c 75%,
    #4facfe 100%
  );
  background-size: 400% 400%;
  animation: gradientShift 15s ease infinite;

  // 背景动态形状
  .background-shapes {
    position: absolute;
    top: 0;
    left: 0;
    width: 100%;
    height: 100%;
    overflow: hidden;
    z-index: 1;

    .shape {
      position: absolute;
      border-radius: 50%;
      background: rgba(255, 255, 255, 0.1);
      backdrop-filter: blur(20px);
      animation: float 20s infinite linear;

      &.shape-1 {
        width: 300px;
        height: 300px;
        top: 10%;
        left: 10%;
        animation-delay: 0s;
      }

      &.shape-2 {
        width: 200px;
        height: 200px;
        top: 60%;
        right: 15%;
        animation-delay: -7s;
      }

      &.shape-3 {
        width: 150px;
        height: 150px;
        bottom: 20%;
        left: 20%;
        animation-delay: -14s;
      }
    }
  }

  // 登录卡片
  .login-card {
    position: relative;
    z-index: 2;
    width: 100%;
    max-width: 480px;
    margin: 0 20px;
    background: rgba(255, 255, 255, 0.95);
    backdrop-filter: blur(20px) saturate(180%);
    border-radius: 24px;
    border: 1px solid rgba(255, 255, 255, 0.2);
    box-shadow:
      0 32px 64px rgba(0, 0, 0, 0.15),
      0 0 0 1px rgba(255, 255, 255, 0.05);
    padding: 48px 48px;
    transform: translateY(0);
    transition: all 0.6s cubic-bezier(0.23, 1, 0.32, 1);
    animation: cardSlideIn 0.8s cubic-bezier(0.23, 1, 0.32, 1);

    &:hover {
      transform: translateY(-8px);
      box-shadow:
        0 48px 80px rgba(0, 0, 0, 0.2),
        0 0 0 1px rgba(255, 255, 255, 0.1);
    }
  }

  // 品牌区域
  .brand-section {
    text-align: center;
    margin-bottom: 40px;

    .logo {
      margin-bottom: 24px;
      display: flex;
      justify-content: center;

      svg {
        filter: drop-shadow(0 8px 16px rgba(0, 122, 255, 0.3));
        transition: transform 0.3s ease;

        &:hover {
          transform: scale(1.05);
        }
      }
    }

    .title {
      font-size: 32px;
      font-weight: 700;
      color: $text-primary;
      margin: 0 0 8px 0;
      letter-spacing: -0.5px;
      line-height: 1.2;
    }

    .subtitle {
      font-size: 16px;
      color: $text-secondary;
      margin: 0;
      font-weight: 400;
      line-height: 1.4;
    }
  }

  // 表单样式
  .login-form {
    .form-item {
      margin-bottom: 24px;

      .form-label {
        display: block;
        font-size: 14px;
        font-weight: 600;
        color: $text-primary;
        margin-bottom: 8px;
        letter-spacing: 0.1px;
        width: 60px; // 固定标签宽度确保对齐
        text-align: left;
      }

      .input-wrapper {
        position: relative;
        width: 100%; // 确保输入框容器占满宽度
        display: flex;
        align-items: center;

        .input-icon {
          position: absolute;
          left: 16px;
          z-index: 3;
          color: $text-secondary;
          font-size: 18px;
          transition: color 0.3s ease;
        }

        .password-toggle {
          position: absolute;
          right: 16px;
          z-index: 3;
          background: none;
          border: none;
          color: $text-secondary;
          cursor: pointer;
          padding: 8px;
          border-radius: 8px;
          transition: all 0.3s ease;
          display: flex;
          align-items: center;
          justify-content: center;

          &:hover {
            color: $primary-blue;
            background: rgba(0, 122, 255, 0.1);
          }
        }
      }

      &:focus-within .input-icon {
        color: $primary-blue;
      }
    }

    // 登录按钮
    .login-button {
      width: 100%;
      height: 52px;
      border-radius: 16px;
      font-size: 16px;
      font-weight: 600;
      letter-spacing: 0.2px;
      background: linear-gradient(
        135deg,
        $primary-blue 0%,
        $primary-purple 100%
      );
      border: none;
      box-shadow:
        0 8px 24px rgba(0, 122, 255, 0.3),
        0 0 0 1px rgba(255, 255, 255, 0.1) inset;
      transition: all 0.3s cubic-bezier(0.23, 1, 0.32, 1);
      margin-top: 8px;
      position: relative;
      overflow: hidden;

      &:before {
        content: "";
        position: absolute;
        top: 0;
        left: -100%;
        width: 100%;
        height: 100%;
        background: linear-gradient(
          90deg,
          transparent,
          rgba(255, 255, 255, 0.2),
          transparent
        );
        transition: left 0.5s ease;
      }

      &:hover {
        transform: translateY(-2px);
        box-shadow:
          0 12px 32px rgba(0, 122, 255, 0.4),
          0 0 0 1px rgba(255, 255, 255, 0.2) inset;

        &:before {
          left: 100%;
        }
      }

      &:active {
        transform: translateY(0);
      }

      &.is-loading {
        cursor: not-allowed;
        transform: none;
      }
    }
  }

  // 演示信息
  .demo-info {
    margin-top: 32px;

    .demo-card {
      background: rgba(118, 118, 128, 0.12);
      border-radius: 16px;
      padding: 20px;
      border: 1px solid rgba(118, 118, 128, 0.16);

      h4 {
        font-size: 14px;
        font-weight: 600;
        color: $text-primary;
        margin: 0 0 12px 0;
        text-align: center;
      }

      .demo-credentials {
        display: flex;
        flex-direction: column;
        gap: 8px;

        .credential-item {
          display: flex;
          justify-content: space-between;
          align-items: center;

          .label {
            font-size: 13px;
            color: $text-secondary;
            font-weight: 500;
          }

          .value {
            font-size: 13px;
            color: $text-primary;
            font-weight: 600;
            font-family: "SF Mono", "Monaco", "Consolas", monospace;
            background: rgba(0, 122, 255, 0.1);
            padding: 4px 8px;
            border-radius: 6px;
          }
        }
      }
    }
  }

  // 响应式设计
  @media (max-width: 520px) {
    padding: 20px;

    .login-card {
      margin: 0;
      padding: 32px 24px;
      border-radius: 20px;
      max-width: 100%;
    }

    .brand-section {
      margin-bottom: 32px;

      .title {
        font-size: 28px;
      }

      .subtitle {
        font-size: 15px;
      }
    }

    .login-form {
      .form-item {
        margin-bottom: 20px;
      }

      .login-button {
        height: 48px;
        font-size: 15px;
      }
    }
  }

  @media (max-width: 320px) {
    .login-card {
      padding: 24px 20px;
    }
  }
}

// 动画定义
@keyframes gradientShift {
  0% {
    background-position: 0% 50%;
  }
  50% {
    background-position: 100% 50%;
  }
  100% {
    background-position: 0% 50%;
  }
}

@keyframes float {
  0% {
    transform: translateY(0) rotate(0deg);
    opacity: 0.7;
  }
  33% {
    transform: translateY(-30px) rotate(120deg);
    opacity: 0.8;
  }
  66% {
    transform: translateY(30px) rotate(240deg);
    opacity: 0.6;
  }
  100% {
    transform: translateY(0) rotate(360deg);
    opacity: 0.7;
  }
}

@keyframes cardSlideIn {
  0% {
    opacity: 0;
    transform: translateY(40px) scale(0.95);
  }
  100% {
    opacity: 1;
    transform: translateY(0) scale(1);
  }
}

// Element Plus 组件样式重写
:deep(.el-form-item) {
  margin-bottom: 0;
  width: 100%; // 确保表单项占满宽度

  .el-form-item__content {
    width: 100%; // 确保表单项内容区域占满宽度
  }

  .el-form-item__error {
    font-size: 12px;
    color: #ff3b30;
    font-weight: 500;
    margin-top: 6px;
    padding-left: 4px;
  }
}

:deep(.modern-input) {
  width: 100%; // 确保输入框组件占满容器宽度

  .el-input__wrapper {
    background: rgba(142, 142, 147, 0.12);
    border: 1px solid rgba(142, 142, 147, 0.16);
    border-radius: 12px;
    height: 52px;
    width: 100%; // 确保输入框包装器占满宽度
    padding: 0 48px 0 48px;
    transition: all 0.3s cubic-bezier(0.23, 1, 0.32, 1);
    box-shadow: none;

    &:hover {
      background: rgba(142, 142, 147, 0.16);
      border-color: rgba(0, 122, 255, 0.3);
    }

    &.is-focus {
      background: rgba(255, 255, 255, 0.9);
      border-color: $primary-blue;
      box-shadow:
        0 0 0 4px rgba(0, 122, 255, 0.1),
        0 2px 8px rgba(0, 0, 0, 0.08);
    }

    .el-input__inner {
      font-size: 16px;
      font-weight: 400;
      color: $text-primary;
      line-height: 1.5;
      height: 50px;
      width: 100%; // 确保内部输入框占满宽度

      &::placeholder {
        color: $text-tertiary;
        font-weight: 400;
      }

      &:-webkit-autofill {
        -webkit-box-shadow: 0 0 0 1000px rgba(255, 255, 255, 0.9) inset !important;
        -webkit-text-fill-color: $text-primary !important;
        transition: background-color 5000s ease-in-out 0s;
      }
    }
  }
}

:deep(.el-tooltip) {
  .el-tooltip__trigger {
    width: 100%;
  }
}

// 深色模式支持
@media (prefers-color-scheme: dark) {
  .login-container {
    .login-card {
      background: rgba(28, 28, 30, 0.95);
      border-color: rgba(84, 84, 88, 0.4);
    }

    .brand-section .title {
      color: #f2f2f7;
    }

    .brand-section .subtitle {
      color: #8e8e93;
    }

    .login-form {
      .form-label {
        color: #f2f2f7;
      }
    }

    .demo-info .demo-card {
      background: rgba(58, 58, 60, 0.4);
      border-color: rgba(84, 84, 88, 0.4);

      h4 {
        color: #f2f2f7;
      }

      .credential-item {
        .label {
          color: #8e8e93;
        }

        .value {
          color: #f2f2f7;
        }
      }
    }
  }

  :deep(.modern-input) {
    .el-input__wrapper {
      background: rgba(58, 58, 60, 0.4);
      border-color: rgba(84, 84, 88, 0.4);

      &:hover {
        background: rgba(58, 58, 60, 0.6);
      }

      &.is-focus {
        background: rgba(44, 44, 46, 0.9);
      }

      .el-input__inner {
        color: #f2f2f7;

        &::placeholder {
          color: #8e8e93;
        }

        &:-webkit-autofill {
          -webkit-box-shadow: 0 0 0 1000px rgba(44, 44, 46, 0.9) inset !important;
          -webkit-text-fill-color: #f2f2f7 !important;
        }
      }
    }
  }
}
</style>
