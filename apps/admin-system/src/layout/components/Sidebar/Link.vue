<template>
  <component :is="linkProps(to)" v-bind="linkProps(to)" />
</template>

<script setup lang="ts">
import { computed } from "vue";

interface Props {
  to: string;
}

const props = defineProps<Props>();

const isExternalLink = (path: string) => {
  return /^(https?:|mailto:|tel:)/.test(path);
};

const linkProps = computed(() => (to: string) => {
  if (isExternalLink(to)) {
    return {
      is: "a",
      href: to,
      target: "_blank",
      rel: "noopener",
    };
  } else {
    return {
      is: "router-link",
      to: to,
    };
  }
});
</script>
