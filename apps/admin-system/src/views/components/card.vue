<template>
  <div class="components-container">
    <el-row :gutter="20">
      <el-col :span="12">
        <MonCard header="简单卡片">
          <div class="card-content">
            <p>这是一个简单的卡片组件</p>
            <p>卡片内容可以是任意的HTML元素</p>
          </div>
        </MonCard>
      </el-col>

      <el-col :span="12">
        <MonCard>
          <template #header>
            <div class="custom-header">
              <span>自定义头部</span>
              <el-icon><Star /></el-icon>
            </div>
          </template>
          <template #extra>
            <MonButton type="text" size="small">更多</MonButton>
          </template>
          <div class="card-content">
            <p>这是带有自定义头部和额外操作的卡片</p>
          </div>
        </MonCard>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px">
      <el-col :span="8">
        <MonCard header="阴影效果" shadow="always">
          <div class="card-content">
            <p>总是显示阴影</p>
          </div>
        </MonCard>
      </el-col>

      <el-col :span="8">
        <MonCard header="悬停阴影" shadow="hover">
          <div class="card-content">
            <p>悬停时显示阴影</p>
          </div>
        </MonCard>
      </el-col>

      <el-col :span="8">
        <MonCard header="无阴影" shadow="never">
          <div class="card-content">
            <p>从不显示阴影</p>
          </div>
        </MonCard>
      </el-col>
    </el-row>

    <el-row :gutter="20" style="margin-top: 20px">
      <el-col :span="24">
        <MonCard header="带有底部操作的卡片">
          <div class="card-content">
            <h4>产品信息</h4>
            <p>产品名称：MonCard 组件</p>
            <p>版本：1.0.0</p>
            <p>
              描述：基于 Element Plus
              封装的卡片组件，提供更好的默认样式和插槽支持。
            </p>
          </div>
          <template #footer>
            <div class="card-footer">
              <MonButton type="primary">编辑</MonButton>
              <MonButton>查看详情</MonButton>
              <MonButton type="danger">删除</MonButton>
            </div>
          </template>
        </MonCard>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { Star } from "@element-plus/icons-vue";
import { MonCard, MonButton } from "@monorepo-project/ui-components";
</script>

<style lang="scss" scoped>
.components-container {
  margin: 30px;
}

.card-content {
  padding: 10px 0;

  h4 {
    margin-bottom: 10px;
    color: #303133;
  }

  p {
    margin-bottom: 8px;
    color: #606266;
    line-height: 1.5;
  }
}

.custom-header {
  display: flex;
  align-items: center;
  justify-content: space-between;

  span {
    font-weight: 500;
  }
}

.card-footer {
  display: flex;
  justify-content: flex-end;
  gap: 10px;
}
</style>
