<template>
  <div v-if="!item.hidden">
    <template
      v-if="
        hasOneShowingChild(item.children, item) &&
        (!onlyOneChild.children || onlyOneChild.noShowingChildren) &&
        !item.alwaysShow
      "
    >
      <app-link v-if="onlyOneChild.meta" :to="resolvePath(onlyOneChild.path)">
        <el-menu-item
          :index="resolvePath(onlyOneChild.path)"
          :class="{ 'submenu-title-noDropdown': !isNest }"
        >
          <el-icon v-if="onlyOneChild.meta.icon">
            <component :is="onlyOneChild.meta.icon" />
          </el-icon>
          <template #title>
            <span>{{ onlyOneChild.meta?.title }}</span>
          </template>
        </el-menu-item>
      </app-link>
    </template>

    <el-sub-menu
      v-else
      ref="subMenu"
      :index="resolvePath(item.path)"
      popper-append-to-body
    >
      <template #title>
        <el-icon v-if="item.meta && item.meta.icon">
          <component :is="item.meta.icon" />
        </el-icon>
        <span>{{ item.meta?.title }}</span>
      </template>
      <sidebar-item
        v-for="child in item.children"
        :key="child.path"
        :is-nest="true"
        :item="child"
        :base-path="resolvePath(child.path)"
        class="nest-menu"
      />
    </el-sub-menu>
  </div>
</template>

<script setup lang="ts">
import { ref } from "vue";
import AppLink from "./Link.vue";

interface RouteItem {
  path: string;
  name?: string;
  hidden?: boolean;
  alwaysShow?: boolean;
  meta?: {
    title: string;
    icon?: string;
    activeMenu?: string;
  };
  children?: RouteItem[];
  noShowingChildren?: boolean;
}

interface Props {
  item: RouteItem;
  isNest?: boolean;
  basePath?: string;
}

const props = withDefaults(defineProps<Props>(), {
  isNest: false,
  basePath: "",
});

const onlyOneChild = ref<RouteItem>({} as RouteItem);

const hasOneShowingChild = (children: RouteItem[] = [], parent: RouteItem) => {
  const showingChildren = children.filter((item) => {
    if (item.hidden) {
      return false;
    } else {
      // Temp set(will be used if only has one showing child)
      onlyOneChild.value = item;
      return true;
    }
  });

  // When there is only one child router, the child router is displayed by default
  if (showingChildren.length === 1) {
    return true;
  }

  // Show parent if there are no child router to display
  if (showingChildren.length === 0) {
    onlyOneChild.value = { ...parent, path: "", noShowingChildren: true };
    return true;
  }

  return false;
};

const resolvePath = (routePath: string) => {
  if (isExternalLink(routePath)) {
    return routePath;
  }
  if (isExternalLink(props.basePath)) {
    return props.basePath;
  }
  // 简单的路径拼接
  return props.basePath
    ? `${props.basePath}/${routePath}`.replace(/\/+/g, "/")
    : routePath;
};

const isExternalLink = (path: string) => {
  return /^(https?:|mailto:|tel:)/.test(path);
};
</script>
