<template>
  <div class="sidebar-container">
    <div class="sidebar-logo">
      <router-link class="sidebar-logo-link" to="/">
        <img src="/logo.svg" class="sidebar-logo-img" alt="logo" />
        <h1 v-show="!isCollapse" class="sidebar-title">Admin System</h1>
      </router-link>
    </div>

    <el-scrollbar wrap-class="scrollbar-wrapper">
      <el-menu
        :default-active="activeMenu"
        :collapse="isCollapse"
        :background-color="variables.menuBg"
        :text-color="variables.menuText"
        :unique-opened="false"
        :active-text-color="variables.menuActiveText"
        :collapse-transition="false"
        mode="vertical"
      >
        <SidebarItem
          v-for="route in permission_routes"
          :key="route.path"
          :item="route"
          :base-path="route.path"
        />
      </el-menu>
    </el-scrollbar>
  </div>
</template>

<script setup lang="ts">
import { computed } from "vue";
import { useRoute } from "vue-router";
import { useAppStore } from "@/stores/app";
import SidebarItem from "./SidebarItem.vue";
import variables from "@/styles/variables.module.scss";

// 模拟路由权限（在实际项目中应该从store获取）
const permission_routes = [
  {
    path: "/dashboard",
    name: "Dashboard",
    meta: { title: "仪表板", icon: "Dashboard" },
  },
  {
    path: "/components",
    name: "Components",
    meta: { title: "组件示例", icon: "Grid" },
    children: [
      {
        path: "/components/button",
        name: "ButtonDemo",
        meta: { title: "按钮组件", icon: "Pointer" },
      },
      {
        path: "/components/card",
        name: "CardDemo",
        meta: { title: "卡片组件", icon: "Document" },
      },
    ],
  },
  {
    path: "/system",
    name: "System",
    meta: { title: "系统管理", icon: "Setting" },
    children: [
      {
        path: "/system/user",
        name: "UserManagement",
        meta: { title: "用户管理", icon: "User" },
      },
      {
        path: "/system/role",
        name: "RoleManagement",
        meta: { title: "角色管理", icon: "UserFilled" },
      },
    ],
  },
];

const appStore = useAppStore();
const route = useRoute();

const sidebar = computed(() => appStore.sidebar);
const isCollapse = computed(() => !sidebar.value.opened);
const activeMenu = computed(() => {
  const { meta, path } = route;
  if (meta?.activeMenu) {
    return meta.activeMenu as string;
  }
  return path;
});
</script>

<style lang="scss">
.sidebar-container {
  transition: width 0.28s;
  width: $sideBarWidth !important;
  background-color: $menuBg;
  height: 100%;
  position: fixed;
  top: 0;
  bottom: 0;
  left: 0;
  z-index: 1001;
  overflow: hidden;

  // reset element-ui css
  .horizontal-collapse-transition {
    transition:
      0s width ease-in-out,
      0s padding-left ease-in-out,
      0s padding-right ease-in-out;
  }

  .scrollbar-wrapper {
    overflow-x: hidden !important;
  }

  .el-scrollbar__bar.is-vertical {
    right: 0px;
  }

  .el-scrollbar {
    height: 100%;
  }

  &.has-logo {
    .el-scrollbar {
      height: calc(100% - 50px);
    }
  }

  .is-horizontal {
    display: none;
  }

  a {
    display: inline-block;
    width: 100%;
    overflow: hidden;
  }

  .svg-icon {
    margin-right: 16px;
  }

  .sub-el-icon {
    margin-right: 12px;
    margin-left: -2px;
  }

  .el-menu {
    border: none;
    height: 100%;
    width: 100% !important;
  }

  // menu hover
  .submenu-title-noDropdown,
  .el-submenu__title {
    &:hover {
      background-color: $menuHover !important;
    }
  }

  .is-active > .el-submenu__title {
    color: $subMenuActiveText !important;
  }

  & .nest-menu .el-submenu > .el-submenu__title,
  & .el-submenu .el-menu-item {
    min-width: $sideBarWidth !important;
    background-color: $subMenuBg !important;

    &:hover {
      background-color: $subMenuHover !important;
    }
  }
}

.hideSidebar {
  .sidebar-container {
    width: 54px !important;
  }

  .main-container {
    margin-left: 54px;
  }

  .submenu-title-noDropdown {
    padding: 0 !important;
    position: relative;

    .el-tooltip {
      padding: 0 !important;

      .svg-icon {
        margin-left: 20px;
      }

      .sub-el-icon {
        margin-left: 19px;
      }
    }
  }

  .el-submenu {
    overflow: hidden;

    & > .el-submenu__title {
      padding: 0 !important;

      .svg-icon {
        margin-left: 20px;
      }

      .sub-el-icon {
        margin-left: 19px;
      }

      .el-submenu__icon-arrow {
        display: none;
      }
    }
  }

  .el-menu--collapse {
    .el-submenu {
      & > .el-submenu__title {
        & > span {
          height: 0;
          width: 0;
          overflow: hidden;
          visibility: hidden;
          display: inline-block;
        }
      }
    }
  }
}

.el-menu--collapse .el-menu .el-submenu {
  min-width: $sideBarWidth !important;
}

// mobile responsive
.mobile {
  .main-container {
    margin-left: 0px;
  }

  .sidebar-container {
    transition: transform 0.28s;
    width: $sideBarWidth !important;
  }

  &.hideSidebar {
    .sidebar-container {
      pointer-events: none;
      transition-duration: 0.3s;
      transform: translate3d(-$sideBarWidth, 0, 0);
    }
  }
}

.withoutAnimation {
  .main-container,
  .sidebar-container {
    transition: none;
  }
}

// sidebar logo
.sidebar-logo {
  height: 50px;
  line-height: 50px;
  background: #2b2f3a;
  text-align: center;
  overflow: hidden;

  & .sidebar-logo-link {
    height: 100%;
    width: 100%;
    display: flex;
    align-items: center;
    justify-content: center;

    & .sidebar-logo-img {
      width: 32px;
      height: 32px;
      vertical-align: middle;
      margin-right: 12px;
    }

    & .sidebar-title {
      display: inline-block;
      margin: 0;
      color: #fff;
      font-weight: 600;
      line-height: 50px;
      font-size: 14px;
      font-family:
        Avenir,
        Helvetica Neue,
        Arial,
        Helvetica,
        sans-serif;
      vertical-align: middle;
    }
  }

  &.collapse {
    .sidebar-logo-img {
      margin-right: 0px;
    }
  }
}
</style>
