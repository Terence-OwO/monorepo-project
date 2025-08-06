<template>
  <el-dropdown trigger="click" @command="handleSetSize">
    <div>
      <el-icon :size="20">
        <DCaret />
      </el-icon>
    </div>
    <template #dropdown>
      <el-dropdown-menu>
        <el-dropdown-item
          v-for="item in sizeOptions"
          :key="item.value"
          :disabled="size === item.value"
          :command="item.value"
        >
          {{ item.label }}
        </el-dropdown-item>
      </el-dropdown-menu>
    </template>
  </el-dropdown>
</template>

<script setup lang="ts">
import { computed } from "vue";
import { DCaret } from "@element-plus/icons-vue";
import { useAppStore } from "@/stores/app";

const appStore = useAppStore();

const size = computed(() => appStore.size);

const sizeOptions = [
  { label: "大", value: "large" },
  { label: "默认", value: "default" },
  { label: "小", value: "small" },
];

const handleSetSize = (size: string) => {
  appStore.setSize(size as "large" | "default" | "small");
};
</script>
