<template>
  <div class="error-page">
    <div class="error-content">
      <div class="error-code">404</div>
      <div class="error-message">页面未找到</div>
      <div class="error-description">抱歉，您访问的页面不存在或已被删除</div>
      <div class="error-actions">
        <MonButton type="primary" @click="goHome"> 返回首页 </MonButton>
        <MonButton @click="goBack"> 返回上页 </MonButton>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { useRouter } from "vue-router";
import { MonButton } from "@monorepo-project/ui-components";

const router = useRouter();

const goHome = () => {
  router.push("/");
};

const goBack = () => {
  router.back();
};
</script>

<style lang="scss" scoped>
.error-page {
  display: flex;
  justify-content: center;
  align-items: center;
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
}

.error-content {
  text-align: center;
  color: white;

  .error-code {
    font-size: 120px;
    font-weight: bold;
    margin-bottom: 20px;
    text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
  }

  .error-message {
    font-size: 32px;
    margin-bottom: 10px;
    font-weight: 600;
  }

  .error-description {
    font-size: 16px;
    margin-bottom: 40px;
    opacity: 0.9;
  }

  .error-actions {
    display: flex;
    gap: 16px;
    justify-content: center;
  }
}
</style>
