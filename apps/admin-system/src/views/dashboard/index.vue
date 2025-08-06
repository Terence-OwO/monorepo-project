<template>
  <div class="dashboard-container">
    <el-row style="background: #fff; padding: 16px 16px 0; margin-top: 32px">
      <el-col :span="24">
        <MonCard header="组件库示例" class="demo-card">
          <template #extra>
            <el-button type="primary" size="small" @click="goToComponents">
              查看更多
            </el-button>
          </template>

          <div class="component-demo">
            <el-row :gutter="20">
              <el-col :span="8">
                <MonButton type="primary" @click="showMessage">
                  点击按钮
                </MonButton>
              </el-col>
              <el-col :span="8">
                <MonButton type="success" loading> 加载中 </MonButton>
              </el-col>
              <el-col :span="8">
                <MonButton type="danger" round> 圆角按钮 </MonButton>
              </el-col>
            </el-row>
          </div>
        </MonCard>
      </el-col>
    </el-row>
  </div>
</template>

<script setup lang="ts">
import { MonButton, MonCard } from "@monorepo-project/ui-components";
import { ElMessage } from "element-plus";
import { useRouter } from "vue-router";

const router = useRouter();

const handleSetLineChartData = (type: string) => {
  console.log("切换图表数据:", type);
};

const showMessage = () => {
  ElMessage.success("这是一个来自组件库的按钮!");
};

const goToComponents = () => {
  router.push("/components/button");
};
</script>

<style lang="scss" scoped>
.dashboard {
  &-container {
    margin: 30px;
  }

  &-text {
    font-size: 30px;
    line-height: 46px;
    margin-bottom: 30px;

    h2 {
      color: #1890ff;
      margin-bottom: 10px;
    }

    p {
      color: #666;
      font-size: 16px;
      line-height: 1.6;
    }
  }
}

.panel-group {
  margin-top: 18px;

  .card-panel-col {
    margin-bottom: 32px;
  }

  .card-panel {
    height: 108px;
    cursor: pointer;
    font-size: 12px;
    position: relative;
    overflow: hidden;
    color: #666;
    background: #fff;
    box-shadow: 4px 4px 40px rgba(0, 0, 0, 0.05);
    border-color: rgba(0, 0, 0, 0.05);

    &:hover {
      .card-panel-icon-wrapper {
        color: #fff;
      }

      .icon-people {
        background: #40c9c6;
      }

      .icon-message {
        background: #36a3f7;
      }

      .icon-money {
        background: #f4516c;
      }

      .icon-shopping {
        background: #34bfa3;
      }
    }

    .icon-people {
      color: #40c9c6;
    }

    .icon-message {
      color: #36a3f7;
    }

    .icon-money {
      color: #f4516c;
    }

    .icon-shopping {
      color: #34bfa3;
    }

    .card-panel-icon-wrapper {
      float: left;
      margin: 14px 0 0 14px;
      padding: 16px;
      transition: all 0.38s ease-out;
      border-radius: 6px;
    }

    .card-panel-icon {
      float: left;
      font-size: 48px;
    }

    .card-panel-description {
      float: right;
      font-weight: bold;
      margin: 26px;
      margin-left: 0px;

      .card-panel-text {
        line-height: 18px;
        color: rgba(0, 0, 0, 0.45);
        font-size: 16px;
        margin-bottom: 12px;
      }

      .card-panel-num {
        font-size: 20px;
      }
    }
  }
}

.demo-card {
  .component-demo {
    padding: 20px 0;
  }
}

@media (max-width: 550px) {
  .card-panel-description {
    display: none;
  }

  .card-panel-icon-wrapper {
    float: none !important;
    width: 100%;
    height: 100%;
    margin: 0 !important;

    .svg-icon {
      display: block;
      margin: 14px auto !important;
      float: none !important;
    }
  }
}
</style>
