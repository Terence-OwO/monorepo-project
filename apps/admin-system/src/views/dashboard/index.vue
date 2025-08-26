<template>
  <div class="dashboard-container">
    <div class="lottery-container">
      <h2 class="lottery-title">抓阄决定是否搬家</h2>

      <div class="lottery-box">
        <div v-if="!isDrawing && !result" class="lottery-content">
          <div class="lottery-ball">
            <span class="ball-text">?</span>
          </div>
          <button @click="drawLottery" class="draw-button">开始抓阄</button>
        </div>

        <div v-if="isDrawing" class="lottery-content">
          <div class="lottery-ball spinning">
            <span class="ball-text">抽取中...</span>
          </div>
        </div>

        <div v-if="result" class="lottery-content">
          <div class="lottery-ball result" :class="result.type">
            <span class="ball-text">{{ result.text }}</span>
          </div>
          <div class="result-message">
            <h3>抓阄结果：{{ result.text }}</h3>
            <p class="result-description">{{ result.description }}</p>
          </div>
          <button @click="resetLottery" class="reset-button">重新抓阄</button>
        </div>
      </div>
    </div>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue";
import { useRouter } from "vue-router";

const router = useRouter();

interface LotteryResult {
  text: string;
  description: string;
  type: "move" | "stay";
}

const isDrawing = ref(false);
const result = ref<LotteryResult | null>(null);

const drawLottery = () => {
  isDrawing.value = true;
  result.value = null;

  // 模拟抽取过程，2秒后显示结果
  setTimeout(() => {
    const random = Math.random();

    if (random < 0.5) {
      result.value = {
        text: "搬家",
        description: "恭喜！抓阄结果是搬家，也许是时候迎接新的环境和机遇了！",
        type: "move",
      };
    } else {
      result.value = {
        text: "不搬家",
        description: "抓阄结果是不搬家，继续在现在的地方享受生活吧！",
        type: "stay",
      };
    }

    isDrawing.value = false;
  }, 2000);
};

const resetLottery = () => {
  result.value = null;
  isDrawing.value = false;
};
</script>

<style lang="scss" scoped>
.dashboard-container {
  padding: 20px;
  min-height: 100vh;
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  display: flex;
  align-items: center;
  justify-content: center;
}

.lottery-container {
  max-width: 500px;
  width: 100%;
  text-align: center;
}

.lottery-title {
  color: white;
  font-size: 28px;
  margin-bottom: 30px;
  text-shadow: 2px 2px 4px rgba(0, 0, 0, 0.3);
  font-weight: 600;
}

.lottery-box {
  background: rgba(255, 255, 255, 0.95);
  border-radius: 20px;
  padding: 40px 30px;
  box-shadow: 0 20px 40px rgba(0, 0, 0, 0.1);
  backdrop-filter: blur(10px);
}

.lottery-content {
  display: flex;
  flex-direction: column;
  align-items: center;
  gap: 30px;
}

.lottery-ball {
  width: 150px;
  height: 150px;
  border-radius: 50%;
  display: flex;
  align-items: center;
  justify-content: center;
  font-size: 24px;
  font-weight: bold;
  color: white;
  background: linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%);
  box-shadow: 0 10px 30px rgba(0, 0, 0, 0.2);
  transition: all 0.3s ease;

  &.spinning {
    animation: spin 1s linear infinite;
    background: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%);
  }

  &.result {
    transform: scale(1.1);

    &.move {
      background: linear-gradient(135deg, #ff9a9e 0%, #fecfef 100%);
    }

    &.stay {
      background: linear-gradient(135deg, #a8edea 0%, #fed6e3 100%);
    }
  }
}

.ball-text {
  color: #333;
  font-size: 18px;
  font-weight: 600;
}

.draw-button,
.reset-button {
  padding: 15px 40px;
  font-size: 18px;
  font-weight: 600;
  border: none;
  border-radius: 50px;
  cursor: pointer;
  transition: all 0.3s ease;
  text-transform: uppercase;
  letter-spacing: 1px;
}

.draw-button {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 25px rgba(102, 126, 234, 0.4);
  }
}

.reset-button {
  background: linear-gradient(135deg, #ffecd2 0%, #fcb69f 100%);
  color: #333;

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 10px 25px rgba(252, 182, 159, 0.4);
  }
}

.result-message {
  text-align: center;

  h3 {
    color: #333;
    font-size: 24px;
    margin-bottom: 10px;
    font-weight: 600;
  }

  .result-description {
    color: #666;
    font-size: 16px;
    line-height: 1.5;
    margin: 0;
  }
}

@keyframes spin {
  from {
    transform: rotate(0deg);
  }
  to {
    transform: rotate(360deg);
  }
}

// 响应式设计
@media (max-width: 768px) {
  .lottery-container {
    margin: 0 20px;
  }

  .lottery-title {
    font-size: 24px;
  }

  .lottery-ball {
    width: 120px;
    height: 120px;
  }

  .ball-text {
    font-size: 16px;
  }

  .lottery-box {
    padding: 30px 20px;
  }
}
</style>
