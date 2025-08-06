<template>
  <el-card
    :header="header"
    :body-style="bodyStyle"
    :shadow="shadow"
    :body-class="bodyClass"
    class="mon-card"
    :class="cardClass"
  >
    <template v-if="$slots.header" #header>
      <div class="mon-card__header">
        <slot name="header" />
        <div v-if="$slots.extra" class="mon-card__extra">
          <slot name="extra" />
        </div>
      </div>
    </template>

    <div class="mon-card__content">
      <slot />
    </div>

    <template v-if="$slots.footer">
      <div class="mon-card__footer">
        <slot name="footer" />
      </div>
    </template>
  </el-card>
</template>

<script setup lang="ts">
import { computed } from "vue";
import { ElCard } from "element-plus";
import type { MonCardProps } from "./types";

defineOptions({
  name: "MonCard",
});

const props = withDefaults(defineProps<MonCardProps>(), {
  shadow: "always",
  bordered: true,
  hoverable: false,
  loading: false,
});

const cardClass = computed(() => {
  return {
    "mon-card--bordered": props.bordered,
    "mon-card--hoverable": props.hoverable,
    "mon-card--loading": props.loading,
    [props.class as string]: !!props.class,
  };
});
</script>

<style lang="scss" scoped>
.mon-card {
  &__header {
    display: flex;
    align-items: center;
    justify-content: space-between;
  }

  &__extra {
    margin-left: auto;
  }

  &__content {
    // 内容区域样式
  }

  &__footer {
    padding: 16px;
    border-top: 1px solid var(--el-border-color-light);
    background-color: var(--el-fill-color-blank);
  }
}
</style>
