<template>
  <div @click="click">
    <el-icon :size="20">
      <FullScreen v-if="!isFullscreen" />
      <Aim v-else />
    </el-icon>
  </div>
</template>

<script setup lang="ts">
import { ref, onMounted, onUnmounted } from "vue";
import { FullScreen, Aim } from "@element-plus/icons-vue";
import { ElMessage } from "element-plus";

const isFullscreen = ref(false);

const init = () => {
  if (document.fullscreenElement) {
    isFullscreen.value = true;
  } else {
    isFullscreen.value = false;
  }
};

const click = () => {
  if (!document.fullscreenElement) {
    document.documentElement
      .requestFullscreen()
      .then(() => {
        isFullscreen.value = true;
      })
      .catch(() => {
        ElMessage({
          message: "无法进入全屏模式",
          type: "error",
        });
      });
  } else {
    if (document.exitFullscreen) {
      document.exitFullscreen().then(() => {
        isFullscreen.value = false;
      });
    }
  }
};

const change = () => {
  init();
};

onMounted(() => {
  init();
  document.addEventListener("fullscreenchange", change);
});

onUnmounted(() => {
  document.removeEventListener("fullscreenchange", change);
});
</script>
