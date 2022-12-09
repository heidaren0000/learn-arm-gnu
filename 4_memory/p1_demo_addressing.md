todo:

- 补充有关 STR 和 LDR 指令的例子
- 补充有关连存取多个 word 的 STR 和 LDR 的例子
- 补充有关 STR 和 LDR 存取 hw, byte 的例子
- 补充有关 .data 中定义不同数据类型的例子
- 补充使用表达式计算偏移量的例子

# p1_demo_addressing

## 指令

### LDR 加载

### STR 存储

## 寻址模式

### 1. 内存无关的寻址模式

#### 立即 immediate

```asm
    @   1.1 immeidate addressing
    mov r0, #1  @ decimal
    mov r0, #0x1    @ hexdeimal value
```

#### 寄存器 register

```asm
    @   1.2 register addressing
    mov r1, r0
```

### 位移 scale

```asm
    @   1.3 scaling addressing
    mov r2, r1, lsl #1
    mov r2, r1, asr #1
    mov r2, r1, lsr #1
    mov r2, r1, ror r1
    mov r2, r1, rrx
```

### 2. 内存相关

#### 偏移 offset

中文课本上的 “寄存器间接寻址” 在 ARM 官方文档也是偏移寻址, 是偏移量为 0 的情况.

```asm
    @ 2.1 offset addressing
    ldr r1, =0x12345678
    ldr r1, =helloworld
    ldr r1, =myname
    ldr r2, [r1]
    ldr r2, [r1, #11]
```

#### 前索引 pre-index

```asm
    @ 2.2 pre-index addressing
    ldr r3, [r1, #1]!
```

1. 计算偏移后的内存地址, 也就是 `Rn(base) + offset`
2. 使用偏移之后的内存地址, 操作数据
3. 使用计算的地址更新 `Rn(base)`

#### 后索引 post-index

```asm
    @ 2.3 post-index addressing
    ldr r4, [r2], #1
```

1. 用 `Rn(base)` 中地址来操作数据
2. 计算偏移之后的内存地址, 也就是 `Rn(base) + offset`
3. 使用计算的地址更新 `Rn(base)`

### 3. 其他

> 其他比较离谱的寻址模式, 这些寻址模式我只在学校发的课本里见过, 没有找到这些“寻址模式”的来源. 

- 堆栈寻址, 这个跟 后面的 stack 有关, 但是在文档中不是单独的寻址模式
- 块复制寻址
- 多寄存器寻址