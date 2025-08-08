<template>
  <div class="users-container">
    <MonCard header="用户管理" class="users-card">
      <template #extra>
        <MonButton type="primary">添加用户</MonButton>
      </template>

      <div class="user-content">
        <p>用户管理功能正在开发中...</p>
        <p>这里将展示用户列表、添加、编辑、删除等功能。</p>
      </div>
    </MonCard>
  </div>
</template>

<script setup lang="ts">
import { MonCard, MonButton } from "@monorepo-project/ui-components";
</script>

<style lang="scss" scoped>
.users-container {
  margin: 30px;
}

.user-content {
  padding: 20px 0;

  p {
    margin-bottom: 10px;
    color: #606266;
    line-height: 1.6;
  }
}
</style>
