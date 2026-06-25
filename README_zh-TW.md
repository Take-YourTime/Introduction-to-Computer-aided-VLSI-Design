# 積體電路電腦輔助設計概論

> [English](README.md) | [繁體中文]

這份 repo 包含了「
積體電路電腦輔助設計概論」課程的四次程式實驗。
以下為各個實驗的題目介紹以及對應的實作方法說明。

## Lab 1: Test Pattern Generation

### 題目說明

針對特定的邏輯電路，撰寫程式來找出能夠偵測所有 Stuck-At Faults (包含 Stuck-At-0 與 Stuck-At-1) 的最小測試樣本集合 (Minimum Test Pattern Set)。

### 實作方法

使用 **C++** 實作並採用 **Greedy Algorithm (貪婪演算法)**。

1. 首先模擬 0~15 共 16 種不同的輸入向量 (Input Vectors) 進入電路，記錄每種輸入可以偵測到哪些節點的 Stuck-At 錯誤 (建立 Fault Dictionary)。
2. 利用貪婪策略，每次挑選能夠涵蓋「最多尚未被偵測到的 Faults」的輸入向量。
3. 重複此過程，直到所有的 Stuck-At Faults 都被涵蓋，進而求出最佳的 Minimum Test Pattern Set。

---

## Lab 2: Scheduling

### 題目說明

使用 C/C++ 實作高階合成 (High-Level Synthesis, HLS) 中的 **List Scheduling** 演算法。程式需能讀取給定的 Data Flow Graphs (包含 DFG1、DFG2 以及 RGB to YUV 的 DFG)，並在指定的運算資源限制下 (如特定數量的加法器與乘法器) 進行排程。

### 實作方法

使用 **C++** 撰寫 List Scheduling 程式。

1. 程式會從文字檔讀取 DFG 的節點 (Operations) 與相依性。
2. 透過 Depth-First Search (DFS) 計算每個節點的 **Critical Path Priority** (距離輸出的最長路徑，越長優先度越高)。
3. 在每一個 Cycle 中，將所有滿足相依性 (Ready) 的節點放入 Ready Queue，並根據 Priority 進行排序。
4. 依照當前可用的 ALU 資源 (Multiplier 與 Adder 數量)，優先排入 Priority 最高的運算，完成 Resource-Constrained Scheduling。

---

## Lab 3: RTL Design of RGB to YUV

### 題目說明

以 **Verilog HDL** 實作 RGB to YUV 轉換電路的暫存器傳遞階層 (Register Transfer Level, RTL) 設計。設計需區分為 Datapath 與 Controller (Finite State Machine)，並使用 Synopsys VCS 與 Verdi 搭配提供的 Testbench 來驗證電路功能是否正確。

### 實作方法

基於 Lab 2 排程與資源分配的結果，採用 **Structural Design** 的方式進行硬體描述：

1. **Datapath (資料路徑)**：撰寫各個子模組 (Sub-modules)，包含 `Multipliper.v`, `Add.v`, `MUX2.v`, `MUX3.v`, `MUX4.v`, `Register.v`, 以及 `ROM.v`，並將它們在 `Datapath.v` 中實體化 (Instantiate) 且接線。
2. **Controller (控制器)**：在 `Controller.v` 中實作一個 Finite State Machine (FSM)，根據當前狀態輸出對應的 Control Signals (如 MUX 選擇訊號、Register Load 訊號) 來控制 Datapath 的運算流程。
3. 整合後於 `RGB2YUV.v` 中完成 Top-level 模組，並透過 Testbench 讀取圖片進行驗證。

---

## Lab 4: Logic Synthesis of RGB to YUV

### 題目說明

使用 **Synopsys Design Compiler (DC)** 對 Lab 3 的 RGB to YUV RTL 電路進行邏輯合成 (Logic Synthesis)。需分別合成兩種架構：

- **Version 1**：使用 1 個 Multiplier 與 1 個 Adder。
- **Version 2**：使用 3 個 Multiplier 與 3 個 Adder。

因此也需要使用到 Lab2 中的排程結果，最後在比較兩種版本的 Timing、Area、Power 以及執行所花費的 Cycles 數。

### 實作方法

撰寫 TCL 腳本給定合成的約束條件 (Constraints, SDC)，並透過 Design Compiler 將 RTL code 轉換為 Gate-level Netlist：

1. 分別設定並合成 **Version 1** (資源少，需要較多的 Cycles 才能算完一個 Pixel) 與 **Version 2** (資源多，運算 Cycles 少) 兩種架構。
2. 透過 Design Compiler 產生的 Reports，分析兩種架構在 PPA (Power, Performance, Area) 的 Trade-off。
3. 整理比較出資源受限架構 (Version 1) 與高平行度架構 (Version 2) 在硬體成本與運算效率上的差異，並總結於實驗報告中。
