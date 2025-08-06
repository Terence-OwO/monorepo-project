<template>
  <el-button
    :type="type"
    :size="size"
    :plain="plain"
    :round="round"
    :circle="circle"
    :loading="loading"
    :disabled="disabled"
    :icon="icon"
    :autofocus="autofocus"
    :native-type="nativeType"
    :auto-insert-space="autoInsertSpace"
    :color="color"
    :dark="dark"
    :link="link"
    :text="text"
    :bg="bg"
    :tag="tag"
    @click="handleClick"
  >
    <template v-if="$slots.loading" #loading>
      <slot name="loading" />
    </template>
    <template v-if="$slots.icon" #icon>
      <slot name="icon" />
    </template>
    <slot />
  </el-button>
</template>

<script setup lang="ts">
import { ElButton } from "element-plus";
import { defineEmits, withDefaults } from "vue";
import type { MonButtonEmits, MonButtonProps } from "./types";

defineOptions({
  name: "MonButton",
  inheritAttrs: false,
});

const props = withDefaults(defineProps<MonButtonProps>(), {
  type: "default",
  size: "default",
  nativeType: "button",
  autoInsertSpace: true,
});

const emit = defineEmits<MonButtonEmits>();

const handleClick = (event: MouseEvent) => {
  emit("click", event);
};
</script>

<style scoped lang="scss">
// 可以在这里添加自定义样式
.mon-button {
  // 自定义按钮样式
}
</style>
