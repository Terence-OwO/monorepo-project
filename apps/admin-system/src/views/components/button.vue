<template>
  <div class="components-container">
    <MonCard header="按钮组件演示" class="demo-card">
      <div class="demo-section">
        <h3>基础按钮</h3>
        <div class="demo-block">
          <MonButton>默认按钮</MonButton>
          <MonButton type="primary">主要按钮</MonButton>
          <MonButton type="success">成功按钮</MonButton>
          <MonButton type="info">信息按钮</MonButton>
          <MonButton type="warning">警告按钮</MonButton>
          <MonButton type="danger">危险按钮</MonButton>
        </div>
      </div>

      <div class="demo-section">
        <h3>朴素按钮</h3>
        <div class="demo-block">
          <MonButton plain>朴素按钮</MonButton>
          <MonButton type="primary" plain>主要按钮</MonButton>
          <MonButton type="success" plain>成功按钮</MonButton>
          <MonButton type="info" plain>信息按钮</MonButton>
          <MonButton type="warning" plain>警告按钮</MonButton>
          <MonButton type="danger" plain>危险按钮</MonButton>
        </div>
      </div>

      <div class="demo-section">
        <h3>圆角按钮</h3>
        <div class="demo-block">
          <MonButton round>圆角按钮</MonButton>
          <MonButton type="primary" round>主要按钮</MonButton>
          <MonButton type="success" round>成功按钮</MonButton>
          <MonButton type="info" round>信息按钮</MonButton>
          <MonButton type="warning" round>警告按钮</MonButton>
          <MonButton type="danger" round>危险按钮</MonButton>
        </div>
      </div>

      <div class="demo-section">
        <h3>不同尺寸</h3>
        <div class="demo-block">
          <MonButton size="large">大号按钮</MonButton>
          <MonButton>默认按钮</MonButton>
          <MonButton size="small">小型按钮</MonButton>
        </div>
      </div>

      <div class="demo-section">
        <h3>禁用状态</h3>
        <div class="demo-block">
          <MonButton disabled>禁用按钮</MonButton>
          <MonButton type="primary" disabled>主要按钮</MonButton>
          <MonButton type="success" disabled>成功按钮</MonButton>
        </div>
      </div>

      <div class="demo-section">
        <h3>加载状态</h3>
        <div class="demo-block">
          <MonButton loading>加载中</MonButton>
          <MonButton type="primary" loading>保存中</MonButton>
          <MonButton type="success" loading @click="handleClick">
            提交中
          </MonButton>
        </div>
      </div>
    </MonCard>
  </div>
</template>

<script setup lang="ts">
import { ElMessage } from "element-plus";
import { MonCard, MonButton } from "@monorepo-project/ui-components";

const handleClick = () => {
  ElMessage.success("按钮点击成功!");
};
</script>

<style lang="scss" scoped>
.components-container {
  margin: 30px;
}

.demo-card {
  .demo-section {
    margin-bottom: 30px;

    h3 {
      margin-bottom: 15px;
      color: #303133;
      font-size: 16px;
      font-weight: 500;
    }

    .demo-block {
      border: 1px solid #ebebeb;
      border-radius: 3px;
      transition: all 0.2s;
      padding: 20px;

      .mon-button {
        margin-right: 10px;
        margin-bottom: 10px;
      }

      &:hover {
        box-shadow:
          0 0 8px 0 rgba(232, 237, 250, 0.6),
          0 2px 4px 0 rgba(232, 237, 250, 0.5);
      }
    }
  }
}
</style>
