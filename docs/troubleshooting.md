# 故障排除指南

## 已解决的问题

### 1. pnpm-lock.yaml 不匹配问题

**问题描述：**

```
ERR_PNPM_OUTDATED_LOCKFILE Cannot install with "frozen-lockfile" because pnpm-lock.yaml is not up to date
```

**原因：**

- lockfile 中包含了已被删除的依赖包（如 `unplugin-auto-import`、`unplugin-vue-components`）
- package.json 和 lockfile 不同步

**解决方案：**

```bash
# 重新生成 lockfile
pnpm install --no-frozen-lockfile

# 验证修复
pnpm install --frozen-lockfile
```

### 2. vue-tsc 与 minimatch 兼容性问题

**问题描述：**

```
TypeError: (0 , minimatch_1.minimatch) is not a function
```

**原因：**

- vue-tsc 2.2.0 与最新的 minimatch 包版本不兼容
- 这是一个已知的上游依赖问题

**临时解决方案：**

1. **降级 vue-tsc 版本：**

```json
{
  "devDependencies": {
    "vue-tsc": "^2.1.10" // 从 2.2.0 降级
  }
}
```

2. **分离构建和类型检查：**

```json
{
  "scripts": {
    "build": "vite build", // 不包含 vue-tsc
    "build:check": "vue-tsc && vite build", // 包含类型检查
    "type-check": "vue-tsc --noEmit"
  }
}
```

3. **CI/CD 中暂时跳过类型检查：**

```yaml
- name: Run type checking
  run: |
    # 跳过 vue-tsc 直到兼容性问题解决
    echo "Type checking temporarily disabled due to vue-tsc/minimatch compatibility issue"
    # pnpm type-check
```

### 3. TypeScript 模块导出警告

**问题描述：**

```
The condition "types" here will never be used as it comes after both "import" and "require"
```

**解决方案：**
调整 package.json 中的 exports 顺序，将 types 放在最前面：

```json
{
  "exports": {
    ".": {
      "types": "./dist/index.d.ts", // types 在前
      "import": "./dist/index.js",
      "require": "./dist/index.cjs"
    }
  }
}
```

## 预防措施

### 1. 定期依赖更新

```bash
# 检查过时的依赖
pnpm outdated

# 更新依赖
pnpm update

# 重新生成 lockfile
pnpm install --no-frozen-lockfile
```

### 2. 版本锁定

对于关键依赖，使用精确版本而不是范围版本：

```json
{
  "devDependencies": {
    "vue-tsc": "2.1.10" // 精确版本，不是 ^2.1.10
  }
}
```

### 3. CI/CD 容错设计

- 将关键构建步骤（如 Vite 构建）与可选步骤（如类型检查）分离
- 为已知问题提供回退方案
- 定期检查和更新工具链版本

## 常用排障命令

### 清理和重置

```bash
# 清理所有构建产物
pnpm clean

# 清理依赖
rm -rf node_modules apps/*/node_modules packages/*/node_modules
rm pnpm-lock.yaml

# 重新安装
pnpm install
```

### 调试构建

```bash
# 逐个构建包
pnpm --filter @monorepo-project/ui-components build
pnpm --filter @monorepo-project/admin-system build

# 查看详细日志
pnpm build --verbose

# 查看 Turbo 缓存状态
pnpm turbo build --dry-run
```

### 依赖分析

```bash
# 查看依赖树
pnpm list --depth=2

# 查看特定包的依赖
pnpm why vue-tsc

# 检查重复依赖
pnpm dedupe
```

## 版本兼容性参考

### 当前稳定版本组合

```json
{
  "vue": "^3.5.18",
  "vite": "^6.0.5",
  "vue-tsc": "^2.1.10",
  "typescript": "^5.7.2",
  "element-plus": "^2.10.4"
}
```

### 已知问题版本

- vue-tsc 2.2.0 + minimatch 新版本：类型检查失败
- pnpm 9.0.x 早期版本：workspace 解析问题

## 社区资源

- [Vue TypeScript 问题追踪](https://github.com/vuejs/language-tools/issues)
- [Vite 构建问题](https://github.com/vitejs/vite/issues)
- [pnpm Workspace 文档](https://pnpm.io/workspaces)
- [Turborepo 故障排除](https://turbo.build/repo/docs/troubleshooting)

## 联系支持

如遇到新问题，请按以下格式收集信息：

1. **环境信息：**

   ```bash
   node --version
   pnpm --version
   cat package.json | grep -A 10 -B 10 "scripts\|dependencies"
   ```

2. **错误日志：**

   ```bash
   pnpm build 2>&1 | tee build.log
   ```

3. **重现步骤：**
   - 详细的操作步骤
   - 期望结果 vs 实际结果
   - 环境差异（开发 vs CI/CD）
