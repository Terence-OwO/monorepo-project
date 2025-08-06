<template>
  <el-breadcrumb class="app-breadcrumb" separator="/">
    <transition-group name="breadcrumb">
      <el-breadcrumb-item v-for="(item, index) in levelList" :key="item.path">
        <span
          v-if="
            item.redirect === 'noRedirect' || index === levelList.length - 1
          "
          class="no-redirect"
        >
          {{ item.meta?.title }}
        </span>
        <a v-else @click.prevent="handleLink(item)">
          {{ item.meta?.title }}
        </a>
      </el-breadcrumb-item>
    </transition-group>
  </el-breadcrumb>
</template>

<script setup lang="ts">
import { ref, watch } from "vue";
import { useRoute, useRouter } from "vue-router";
import type { RouteLocationMatched } from "vue-router";

const route = useRoute();
const router = useRouter();

const levelList = ref<RouteLocationMatched[]>([]);

const getBreadcrumb = () => {
  // only show routes with meta.title
  let matched = route.matched.filter((item) => item.meta && item.meta.title);
  const first = matched[0];

  if (!isDashboard(first)) {
    // 创建一个符合 RouteLocationMatched 类型的对象
    const dashboardRoute: RouteLocationMatched = {
      path: "/dashboard",
      name: "Dashboard",
      meta: { title: "仪表板" },
      components: {},
      instances: {},
      children: [],
      aliasOf: undefined,
      redirect: undefined,
      beforeEnter: undefined,
      props: {},
      leaveGuards: new Set(),
      updateGuards: new Set(),
      enterCallbacks: {},
      mods: {},
    };
    matched = [dashboardRoute].concat(matched);
  }

  levelList.value = matched.filter(
    (item) => item.meta && item.meta.title && item.meta.breadcrumb !== false
  );
};

const isDashboard = (route: RouteLocationMatched) => {
  const name = route && route.name;
  if (!name) {
    return false;
  }
  return (
    (name as string).trim().toLocaleLowerCase() ===
    "Dashboard".toLocaleLowerCase()
  );
};

const handleLink = (item: RouteLocationMatched) => {
  const { redirect, path } = item;
  if (redirect) {
    router.push(redirect as string);
    return;
  }
  router.push(path);
};

getBreadcrumb();

watch(route, getBreadcrumb);
</script>

<style lang="scss" scoped>
.app-breadcrumb.el-breadcrumb {
  display: inline-block;
  font-size: 14px;
  line-height: 50px;
  margin-left: 8px;

  .no-redirect {
    color: #97a8be;
    cursor: text;
  }
}
</style>
