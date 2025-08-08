<template>
  <div class="app-wrapper" :class="classObj">
    <AppMain />
  </div>
</template>

<script setup lang="ts">
import { useAppStore } from "@/stores/app";
import { computed } from "vue";
import AppMain from "./components/AppMain.vue";

const appStore = useAppStore();

const sidebar = computed(() => appStore.sidebar);
const device = computed(() => appStore.device);

const classObj = computed(() => ({
  hideSidebar: !sidebar.value.opened,
  openSidebar: sidebar.value.opened,
  withoutAnimation: sidebar.value.withoutAnimation,
  mobile: device.value === "mobile",
}));

const handleClickOutside = () => {
  appStore.closeSideBar({ withoutAnimation: false });
};
</script>

<style lang="scss" scoped>
@import "@/styles/mixin.scss";
@import "@/styles/variables.scss";

.app-wrapper {
  @include clearfix;
  position: relative;
  height: 100%;
  width: 100%;

  &.mobile.openSidebar {
    position: fixed;
    top: 0;
  }
}

.drawer-bg {
  background: #000;
  opacity: 0.3;
  width: 100%;
  top: 0;
  height: 100%;
  position: absolute;
  z-index: 999;
}

.fixed-header {
  position: fixed;
  top: 0;
  right: 0;
  z-index: 9;
  width: calc(100% - #{$sideBarWidth});
  transition: width 0.28s;
}

.hideSidebar .fixed-header {
  width: calc(100% - 54px);
}

.mobile .fixed-header {
  width: 100%;
}
</style>
