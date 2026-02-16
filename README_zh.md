# FinCore (赛博账本) 💸

> **基于 Flutter 构建的赛博朋克风格个人财务管理终端。**

[![English Documentation](https://img.shields.io/badge/Language-English-red)](README.md)

![Flutter](https://img.shields.io/badge/Flutter-3.x-02569B?style=for-the-badge&logo=flutter)
![Dart](https://img.shields.io/badge/Dart-3.x-0175C2?style=for-the-badge&logo=dart)
![Hive](https://img.shields.io/badge/NoSQL-Hive-FF6F00?style=for-the-badge&logo=hive)
![Style](https://img.shields.io/badge/Style-Cyberpunk-00E5FF?style=for-the-badge)

## 📖 项目简介

**FinCore** 是一款拥有高科技、未来感赛博朋克视觉风格的个人记账应用。与传统的记账软件不同，FinCore 将你的财务视为一个需要管理的“系统”。

它具备类似股票交易终端的实时资金走势图、故障艺术（Glitch）开场动画，并使用 Hive 进行强大的本地存储。它能帮助你在一个沉浸式的视觉环境中，像操作终端一样追踪收入、支出和储蓄目标。

## ✨ 核心功能

* **🎨 极致赛博视觉:**
    * 专为深色模式优化的霓虹配色（荧光青/黑客绿/警示红）。
    * 沉浸式的“系统启动”故障动画与交互音效感视觉。
    * 定制化的数字终端风格组件。

* **📈 资金走势可视化:**
    * 基于 `fl_chart` 的交互式图表。
    * 股票交易风格的收入、支出与结余（Net）三线走势图。
    * 支持时间维度快速切换：本周 (1W)、本月 (1M)、本年 (1Y)。

* **⚡ 高效记账管理:**
    * 快速记账弹窗，内置自动分类图标（如：零食、父母生活费、数码产品等）。
    * 动态 UI 适配收入与支出模式。
    * 内置日历选择器，支持补录历史账单。

* **🔒 隐私优先:**
    * 100% 基于 `Hive` NoSQL 数据库的本地存储。
    * 无需联网，不上传任何数据，你的财务数据只属于你。

## 🛠️ 技术栈

* **框架:** [Flutter](https://flutter.dev/)
* **语言:** [Dart](https://dart.dev/)
* **状态管理:** `Provider`
* **本地数据库:** `Hive` (高性能 NoSQL)
* **图表库:** `fl_chart`
* **动画:** `flutter_animate`, Custom Painters (自绘组件)

## 🚀 快速开始

### 前置条件
* 已安装 Flutter SDK (推荐 3.10.0 或更高版本)
* 已安装 Dart SDK
* 开发工具 (VS Code 或 Android Studio)

### 安装步骤

1.  **克隆仓库:**
    ```bash
    git clone [https://github.com/dongfang281127/cyber_budget.git](https://github.com/dongfang281127/cyber_budget.git)
    cd cyber_budget
    ```

2.  **安装依赖:**
    ```bash
    flutter pub get
    ```

3.  **生成数据库适配器:**
    *(仅当你修改了 models 目录下的数据模型时需要运行)*
    ```bash
    flutter pub run build_runner build --delete-conflicting-outputs
    ```

4.  **运行应用:**
    ```bash
    flutter run
    ```

## 🤝 参与贡献

欢迎贡献代码！如果你有任何新功能点子、UI 设计建议或发现了 Bug，欢迎提交 Issue 或 Pull Request。

## 📄 开源协议

本项目采用 MIT 开源协议 - 详情请见 [LICENSE](LICENSE) 文件。

---

**Developed with ❤️ by Dongfang**
