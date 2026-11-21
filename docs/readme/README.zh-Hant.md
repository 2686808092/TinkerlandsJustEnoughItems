# Just Enough Items for Tinkerlands

[English](README.en.md) · [简体中文](../../README.md) · **繁體中文** · [한국어](README.ko.md) · [Deutsch](README.de.md) · [Español](README.es.md) · [Français](README.fr.md) · [日本語](README.ja.md) · [Português (Brasil)](README.pt-BR.md) · [Русский](README.ru.md)

在《Tinkerlands》的角色物品欄內查詢物品、製作配方、用途和取得途徑。物品列表位於畫面左側。

## 安裝

從[GitHub Releases](https://github.com/2686808092/TinkerlandsJustEnoughItems/releases/latest)下載 `Just_Enough_Items_1.7.0.zip`，將 ZIP 原樣放入遊戲的 `mods` 資料夾，然後重新啟動遊戲。升級時請移除舊版 JEI ZIP。

模組介面提供簡體中文和英文，物品與工作站名稱沿用遊戲目前的語言。

## 預設操作

| 操作 | 按鍵或滑鼠 |
| --- | --- |
| 查看配方或取得途徑 | 左鍵點選列表物品，或將游標移到物品上並按 `R`。 |
| 查看用途 | 右鍵點選列表物品，或將游標移到物品上並按 `U`。 |
| 搜尋與翻頁 | 用 `Ctrl+F` 聚焦搜尋欄。使用滾輪、翻頁箭頭或 `Page Up` / `Page Down` 翻頁。 |
| 顯示或隱藏列表 | 開啟物品欄後按 `Ctrl+O` 切換。模組會記住上次的選擇。 |
| 關閉詳細資料或開啟設定 | 用 `Esc` 關閉詳細資料。點選搜尋欄旁的工具圖示開啟設定。 |

## 配方與取得途徑

- 支援一般合成、烹飪與轉化方塊的 3×3 配方。點選材料可繼續查詢，點選工作站名稱可查看該站的配方。
- 「用途」顯示使用目前物品的配方。已識別的取得途徑包括掉落、商店、任務、契約、釣魚、寶箱和採集。
- 可用 `#配方` 等條件搜尋配方藍圖。按 `R` 查看已識別的取得途徑，按 `U` 查看解鎖的製作配方。

## 搜尋

可輸入物品名稱，中文名稱也支援拼音。用 `#Accessories` 查找飾品，用 `@vanilla` 篩選原版物品。

`$text` 搜尋描述，`%category` 篩選類別，雙引號括住詞組，`-word` 排除詞語。空格會合併條件，直線符號表示符合任一條件。開發者模式支援 `id:144` 等物品 ID 查詢。

## 設定、作弊與開發者模式

單人模式預設自動暫停，可在設定中關閉。多人連線時遊戲持續執行。

在工具圖示上使用 `Ctrl＋左鍵` 切換作弊模式。點選列表物品可取得一個，按住 Shift 點選可取得一組。同時開啟開發者模式時，可取得遊戲能生成的隱藏物品。

[更新日誌](../../CHANGELOG.md) · [擴充介面](../extension-api.md)
