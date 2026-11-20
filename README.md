# Tinkerlands Just Enough Items

Tinkerlands 的物品、制作配方和获取途径查询模组。打开人物栏时显示 JEI 列表，按 `Ctrl+O` 切换显示状态，悬停物品时按 `R` 查配方、按 `U` 查用途。

## 安装

从 [Releases](https://github.com/2686808092/TinkerlandsJustEnoughItems/releases) 下载 `Just_Enough_Items_1.6.0.zip`，将 ZIP 放入 Tinkerlands 的 `mods` 目录。升级时用新版替换之前的 JEI ZIP。

搜索支持中英文标签，例如 `#饰品`、`#Accessories`；开发者模式可精确搜索 `id:144`。例如用 `#配方 蜂拥药水` 查找药水蓝图。

## 构建

在仓库目录运行 `python build.py` 生成 ZIP。1.6.0 在 Tinkerlands 封闭测试构建 `26736667` 上通过隔离引擎验证，覆盖十种语言切换。

[更新日志](CHANGELOG.md) · [扩展接口](docs/extension-api.md)

本项目基于原始 Just Enough Items 0.0.1 模组扩展。拼音数据的许可证见 [pypinyin MIT 许可证](third_party/LICENSE-pypinyin.txt)。
