todo

- 补充这几个指令的伪代码

# p2_stack

## 指令

在这里提到的所有的指令, reglist 中都不能同时包含 lr, pc, 但是可以单独包含其中一个. (我因为这个事情在 stackoverflow 中扣了声誉...)

### `stmdb`

```asm
stmdb   r13!, {r1, r2} @ same as {r1-r2}
```

`store multiple registers and decrease before`

连续存储寄存器到内存

当 rn = sp 时, 并且使用 `!` 开启写回, 和push的机器码是相同的

> 1. address = rn - reglist中寄存器的数量*4
>
> 2. 在 address 按照数字顺序存放寄存器, (r0, r1, r2依次升序存放, 低位寄存器存放到低位地址, 如果不按照升序 as 会报错)
>
> 3. rn = rn - reglist中寄存器的数量*4

### `push`

```asm
push    {r1, r2}
```

`push` 可以理解为 `stmdb` 的语法糖, 这两个指令机器码是相同的. push 就是 stmdb 中, sp 作为 rn, 而且, 开启写回的情况.

### `ldmia`

```asm
ldmia   r13!, {r1, r2} 
```

`load multiple increase after	`

当 rn = sp 是, 并且通过 `!` 开启写回, 和 pop 机器码是相同的

> 1. address = rn
>
> 2. 从高位地址开始读取, 按照 reglist 读到高位寄存器中
>
> 3. 更新 rn

### `pop`

```asm
pop     {r1, r2}
```

是 `ladmia` 的语法糖, 这两个指令机器码也是相同的. `pop` 就是 `ldmia` 在 rn = sp, 而且开启写回的情况



## 使用栈

没什么好说的, 总之要确保 pop 和 push 的调用是一一对应
