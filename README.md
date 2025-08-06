# Modern Monorepo Project

一个基于 **Turborepo + pnpm** 构建的现代化 monorepo 项目，包含组件库和后台管理系统。

## 🚀 项目概述

turborepo + pnpm + workspace

### 📦 项目结构

```
monorepo-project/
├── apps/                          # 应用目录
│   └── admin-system/               # 后台管理系统
│       ├── src/
│       │   ├── components/         # 通用组件
│       │   ├── layout/            # 布局组件
│       │   ├── router/            # 路由配置
│       │   ├── stores/            # Pinia 状态管理
│       │   ├── styles/            # 样式文件
│       │   ├── utils/             # 工具函数
│       │   ├── views/             # 页面组件
│       │   └── main.ts            # 应用入口
│       ├── index.html
│       ├── package.json
│       ├── vite.config.ts
│       └── tsconfig.json
├── packages/                       # 包目录
│   └── ui-components/              # UI组件库
│       ├── src/
│       │   ├── components/         # 组件实现
│       │   ├── styles/            # 组件样式
│       │   ├── types/             # 类型定义
│       │   ├── utils/             # 工具函数
│       │   └── index.ts           # 组件库入口
│       ├── package.json
│       ├── vite.config.ts
│       └── tsconfig.json
├── turbo.json                      # Turborepo 配置
├── pnpm-workspace.yaml             # pnpm 工作空间配置
├── .npmrc                          # npm 配置
└── package.json                    # 根项目配置
```

## 🛠 技术栈

### 核心技术

- **构建工具**: Vite 6.0.5
- **前端框架**: Vue 3.5.18
- **UI 组件库**: Element Plus 2.10.4
- **状态管理**: Pinia 3.0.3
- **类型检查**: TypeScript 5.7.2

### Monorepo 工具

- **任务编排**: Turborepo 2.5.0
- **包管理器**: pnpm 9.15.1
- **依赖管理**: pnpm workspaces

### 开发工具

- **代码检查**: ESLint 9.17.0
- **代码格式化**: Prettier 3.4.2
- **样式预处理**: Sass 1.83.0
- **类型定义生成**: vite-plugin-dts 4.4.0

## 🔧 核心功能与配置

### 1. Turborepo 智能任务编排

#### 配置文件: `turbo.json`

```json
{
  "$schema": "https://turbo.build/schema.json",
  "ui": "tui",
  "tasks": {
    "build": {
      "dependsOn": ["^build"],
      "outputs": ["dist/**"],
      "env": ["NODE_ENV"]
    },
    "dev": {
      "cache": false,
      "persistent": true
    },
    "lint": {
      "dependsOn": ["^lint"]
    }
  }
}
```

#### 实现的功能

- ✅ **智能依赖分析**: 自动检测包之间的依赖关系
- ✅ **并行构建**: 无依赖关系的包可以并行构建
- ✅ **增量构建**: 只重新构建发生变化的包
- ✅ **构建缓存**: 提升重复构建的速度
- ✅ **任务管道**: 确保构建顺序的正确性

### 2. pnpm 依赖管理与幽灵依赖解决

#### 配置文件: `pnpm-workspace.yaml`

```yaml
packages:
  - "packages/*"
  - "apps/*"

shared-workspace-lockfile: true
strict-peer-dependencies: false
auto-install-peers: true
prefer-workspace-packages: true
save-workspace-protocol: rolling
```

#### 配置文件: `.npmrc`

```ini
shamefully-hoist=true
strict-peer-dependencies=false
auto-install-peers=true
prefer-offline=true
node-linker=hoisted
```

#### 解决的问题

- ✅ **幽灵依赖**: 通过 `shamefully-hoist=true` 确保依赖正确提升
- ✅ **依赖共享**: 工作空间内共享相同版本的依赖
- ✅ **版本一致性**: 使用 `prefer-workspace-packages` 优先使用工作空间内的包
- ✅ **Peer 依赖**: 自动安装 peer dependencies，避免版本冲突

### 3. UI 组件库设计

#### 组件库特性

- ✅ **基于 Element Plus**: 在 Element Plus 基础上进行二次封装
- ✅ **TypeScript 支持**: 完整的类型定义和类型推导
- ✅ **按需导入**: 支持 Tree Shaking 和按需加载
- ✅ **主题定制**: 自定义 CSS 变量和主题配置
- ✅ **构建输出**: 支持 ESM、CJS 多种格式

#### 已实现组件

- **MonButton**: 基于 ElButton 的增强按钮组件
- **MonCard**: 带有额外插槽和样式的卡片组件

#### 构建配置: `packages/ui-components/vite.config.ts`

```typescript
export default defineConfig({
  build: {
    lib: {
      entry: resolve(__dirname, "src/index.ts"),
      name: "MonorepoUIComponents",
      formats: ["es", "cjs"],
      fileName: (format) => `index.${format === "es" ? "js" : "cjs"}`,
    },
    rollupOptions: {
      external: ["vue", "element-plus"],
      output: {
        globals: {
          vue: "Vue",
          "element-plus": "ElementPlus",
        },
      },
    },
  },
});
```

#### 状态管理: Pinia Store

```typescript
// apps/admin-system/src/stores/app.ts
export const useAppStore = defineStore(
  "app",
  () => {
    const sidebar = ref({ opened: true, withoutAnimation: false });
    const device = ref<"desktop" | "tablet" | "mobile">("desktop");
    const theme = ref<"light" | "dark">("light");

    return {
      sidebar,
      device,
      theme,
      toggleSideBar,
      setDevice,
      setTheme,
    };
  },
  {
    persist: {
      key: "app-store",
      storage: localStorage,
      pick: ["theme", "language", "size", "sidebar.opened"],
    },
  }
);
```

## 🚀 快速开始

### 环境要求

- Node.js >= 18.0.0
- pnpm >= 8.0.0

### 安装依赖

```bash
# 安装所有依赖
pnpm install
```

### 开发模式

```bash
# 启动所有项目的开发服务器
pnpm dev

# 仅启动后台管理系统
pnpm --filter @monorepo-project/admin-system dev

# 仅启动组件库开发
pnpm --filter @monorepo-project/ui-components dev
```

### 构建项目

```bash
# 构建所有项目
pnpm build

# 构建组件库
pnpm --filter @monorepo-project/ui-components build

# 构建后台管理系统
pnpm --filter @monorepo-project/admin-system build
```

### 代码检查

```bash
# 运行 ESLint
pnpm lint

# 类型检查
pnpm type-check
```

### 🏗 架构设计

- 🧩 **模块化**: 清晰的项目结构和模块划分
- 🔄 **可复用**: 组件库可独立发布和使用
- 📏 **可扩展**: 易于添加新的应用和包
- 🎨 **主题化**: 支持自定义主题和样式

### ⚡ 性能优化

- 🚀 **构建优化**: Turborepo 智能缓存和并行构建
- 📦 **按需加载**: Tree Shaking 和代码分割
- 💾 **缓存策略**: 多层级缓存提升构建速度
- 🎯 **依赖优化**: 避免重复依赖和版本冲突

## 🔧 配置说明

### Turborepo 配置要点

1. **任务依赖**: 通过 `dependsOn` 确保构建顺序
2. **输出目录**: 配置 `outputs` 实现增量构建
3. **环境变量**: 通过 `env` 配置构建时的环境变量
4. **缓存策略**: 开发任务设置 `cache: false`

### pnpm 工作空间优势

1. **磁盘效率**: 硬链接避免重复存储相同依赖
2. **安装速度**: 并行安装和智能缓存
3. **依赖管理**: 严格的依赖解析避免幽灵依赖
4. **Monorepo 支持**: 原生支持工作空间和跨包依赖

### Vite 构建优化

1. **开发服务器**: 原生 ESM 支持，无需打包
2. **生产构建**: Rollup 打包，支持多种输出格式
3. **插件生态**: 丰富的插件支持 Vue、TypeScript 等
4. **代码分割**: 自动代码分割和懒加载

## 📚 使用示例

### 在其他项目中使用组件库

```typescript
// 安装组件库
npm install @monorepo-project/ui-components

// 全量导入
import { createApp } from 'vue'
import UIComponents from '@monorepo-project/ui-components'
import '@monorepo-project/ui-components/dist/ui-components.css'

const app = createApp(App)
app.use(UIComponents)

// 按需导入
import { MonButton, MonCard } from '@monorepo-project/ui-components'
```

### 添加新的应用

```bash
# 1. 在 apps 目录下创建新应用
mkdir apps/new-app

# 2. 创建 package.json
# 3. 配置 vite.config.ts
# 4. 添加到 pnpm-workspace.yaml (自动识别)
```

### 添加新的包

```bash
# 1. 在 packages 目录下创建新包
mkdir packages/new-package

# 2. 创建 package.json，设置包名为 @monorepo-project/new-package
# 3. 在其他项目中通过 workspace:* 引用
```
