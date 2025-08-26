<script setup lang="ts">
import { ref } from "vue";

interface Option {
  id: string;
  label: string;
  description: string;
  icon: string;
}

const options: Option[] = [
  {
    id: "move",
    label: "搬家",
    description: "开启新的生活篇章",
    icon: "🏠",
  },
  {
    id: "stay",
    label: "不搬家",
    description: "保持现状的稳定",
    icon: "🏡",
  },
];

const isDrawing = ref(false);
const showResult = ref(false);
const selectedOption = ref<Option | null>(null);
const drawAnimation = ref(false);

const drawResult = () => {
  if (isDrawing.value) return;

  isDrawing.value = true;
  drawAnimation.value = true;
  showResult.value = false;

  // 模拟抓阄动画
  setTimeout(() => {
    // 50%概率随机选择
    const random = Math.random();
    selectedOption.value = random < 0.5 ? options[0] : options[1];

    drawAnimation.value = false;
    showResult.value = true;
    isDrawing.value = false;
  }, 2000);
};

const resetDraw = () => {
  showResult.value = false;
  selectedOption.value = null;
};
</script>

<template>
  <div class="lottery-container">
    <div class="header">
      <h1 class="title">🎯 抓阄决定</h1>
      <p class="subtitle">让命运为你做出选择</p>
    </div>

    <div class="options-container">
      <div
        v-for="option in options"
        :key="option.id"
        class="option-card"
        :class="{ selected: selectedOption?.id === option.id && showResult }"
      >
        <div class="option-icon">{{ option.icon }}</div>
        <div class="option-content">
          <h3 class="option-label">{{ option.label }}</h3>
          <p class="option-description">{{ option.description }}</p>
        </div>
      </div>
    </div>

    <div class="action-section">
      <button
        @click="drawResult"
        :disabled="isDrawing"
        class="draw-button"
        :class="{ drawing: isDrawing }"
      >
        <span v-if="!isDrawing">🎲 开始抓阄</span>
        <span v-else class="drawing-text">
          <span class="spinner"></span>
          正在抓阄...
        </span>
      </button>
    </div>

    <!-- 抓阄动画 -->
    <div v-if="drawAnimation" class="draw-animation">
      <div class="lottery-box">
        <div
          class="lottery-item"
          v-for="i in 6"
          :key="i"
          :style="{ animationDelay: `${i * 0.1}s` }"
        >
          🎯
        </div>
      </div>
    </div>

    <!-- 结果显示 -->
    <div v-if="showResult && selectedOption" class="result-section">
      <div class="result-card">
        <div class="result-icon">{{ selectedOption.icon }}</div>
        <h2 class="result-title">命运的选择是：{{ selectedOption.label }}</h2>
        <p class="result-description">{{ selectedOption.description }}</p>
        <button @click="resetDraw" class="reset-button">🔄 重新抓阄</button>
      </div>
    </div>
  </div>
</template>

<style scoped lang="scss">
.lottery-container {
  max-width: 800px;
  margin: 0 auto;
  padding: 2rem;
  font-family:
    -apple-system, BlinkMacSystemFont, "Segoe UI", Roboto, sans-serif;
}

.header {
  text-align: center;
  margin-bottom: 3rem;

  .title {
    font-size: 2.5rem;
    font-weight: 700;
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    -webkit-background-clip: text;
    -webkit-text-fill-color: transparent;
    background-clip: text;
    margin-bottom: 0.5rem;
  }

  .subtitle {
    font-size: 1.1rem;
    color: #6b7280;
    font-weight: 400;
  }
}

.options-container {
  display: grid;
  grid-template-columns: repeat(auto-fit, minmax(300px, 1fr));
  gap: 1.5rem;
  margin-bottom: 3rem;
}

.option-card {
  background: rgba(255, 255, 255, 0.8);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.2);
  border-radius: 20px;
  padding: 2rem;
  text-align: center;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 8px 32px rgba(0, 0, 0, 0.1);

  &:hover {
    transform: translateY(-4px);
    box-shadow: 0 20px 40px rgba(0, 0, 0, 0.15);
  }

  &.selected {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    transform: scale(1.05);

    .option-description {
      color: rgba(255, 255, 255, 0.9);
    }
  }
}

.option-icon {
  font-size: 3rem;
  margin-bottom: 1rem;
}

.option-label {
  font-size: 1.5rem;
  font-weight: 600;
  margin-bottom: 0.5rem;
}

.option-description {
  color: #6b7280;
  font-size: 1rem;
  line-height: 1.5;
}

.action-section {
  text-align: center;
  margin-bottom: 3rem;
}

.draw-button {
  background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
  color: white;
  border: none;
  border-radius: 50px;
  padding: 1rem 3rem;
  font-size: 1.1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 8px 25px rgba(102, 126, 234, 0.4);

  &:hover:not(:disabled) {
    transform: translateY(-2px);
    box-shadow: 0 15px 35px rgba(102, 126, 234, 0.6);
  }

  &:disabled {
    opacity: 0.7;
    cursor: not-allowed;
  }

  &.drawing {
    background: linear-gradient(135deg, #f093fb 0%, #f5576c 100%);
  }
}

.drawing-text {
  display: flex;
  align-items: center;
  gap: 0.5rem;
}

.spinner {
  width: 16px;
  height: 16px;
  border: 2px solid rgba(255, 255, 255, 0.3);
  border-top: 2px solid white;
  border-radius: 50%;
  animation: spin 1s linear infinite;
}

@keyframes spin {
  0% {
    transform: rotate(0deg);
  }
  100% {
    transform: rotate(360deg);
  }
}

.draw-animation {
  text-align: center;
  margin: 2rem 0;

  .lottery-box {
    display: inline-block;
    position: relative;
  }

  .lottery-item {
    position: absolute;
    font-size: 2rem;
    animation: bounce 0.6s ease-in-out infinite;

    &:nth-child(1) {
      top: -20px;
      left: -20px;
    }
    &:nth-child(2) {
      top: -20px;
      right: -20px;
    }
    &:nth-child(3) {
      top: 50%;
      left: -40px;
    }
    &:nth-child(4) {
      top: 50%;
      right: -40px;
    }
    &:nth-child(5) {
      bottom: -20px;
      left: -20px;
    }
    &:nth-child(6) {
      bottom: -20px;
      right: -20px;
    }
  }
}

@keyframes bounce {
  0%,
  20%,
  50%,
  80%,
  100% {
    transform: translateY(0);
  }
  40% {
    transform: translateY(-10px);
  }
  60% {
    transform: translateY(-5px);
  }
}

.result-section {
  text-align: center;
  margin-top: 3rem;
}

.result-card {
  background: rgba(255, 255, 255, 0.9);
  backdrop-filter: blur(20px);
  border: 1px solid rgba(255, 255, 255, 0.3);
  border-radius: 25px;
  padding: 3rem;
  box-shadow: 0 20px 60px rgba(0, 0, 0, 0.1);
  animation: slideIn 0.6s cubic-bezier(0.4, 0, 0.2, 1);
}

@keyframes slideIn {
  from {
    opacity: 0;
    transform: translateY(30px);
  }
  to {
    opacity: 1;
    transform: translateY(0);
  }
}

.result-icon {
  font-size: 4rem;
  margin-bottom: 1.5rem;
  animation: popIn 0.8s cubic-bezier(0.4, 0, 0.2, 1) 0.2s both;
}

@keyframes popIn {
  from {
    opacity: 0;
    transform: scale(0.5);
  }
  to {
    opacity: 1;
    transform: scale(1);
  }
}

.result-title {
  font-size: 2rem;
  font-weight: 700;
  color: #1f2937;
  margin-bottom: 1rem;
}

.result-description {
  font-size: 1.1rem;
  color: #6b7280;
  margin-bottom: 2rem;
  line-height: 1.6;
}

.reset-button {
  background: linear-gradient(135deg, #10b981 0%, #059669 100%);
  color: white;
  border: none;
  border-radius: 50px;
  padding: 0.8rem 2rem;
  font-size: 1rem;
  font-weight: 600;
  cursor: pointer;
  transition: all 0.3s cubic-bezier(0.4, 0, 0.2, 1);
  box-shadow: 0 6px 20px rgba(16, 185, 129, 0.3);

  &:hover {
    transform: translateY(-2px);
    box-shadow: 0 12px 30px rgba(16, 185, 129, 0.4);
  }
}

// 响应式设计
@media (max-width: 768px) {
  .lottery-container {
    padding: 1rem;
  }

  .header .title {
    font-size: 2rem;
  }

  .options-container {
    grid-template-columns: 1fr;
  }

  .option-card {
    padding: 1.5rem;
  }

  .draw-button {
    padding: 0.8rem 2rem;
    font-size: 1rem;
  }
}
</style>
