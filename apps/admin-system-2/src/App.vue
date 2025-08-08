<template>
  <div id="app">
    <router-view />
  </div>
</template>

<script setup lang="ts">
import { onMounted } from "vue";
import { useAppStore } from "@/stores/app";

const appStore = useAppStore();

onMounted(() => {
  // 初始化应用状态
  appStore.initializeApp();
});
</script>

<style lang="scss">
#app {
  height: 100vh;
  width: 100vw;
}
</style>
