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

> 1. address = rn - reglist中寄存器的数量*4, **不是给每个寄存器分别释放空间**
>
> 2. 在 address 按照数字顺序存放寄存器, (r0, r1, r2依次按照数字顺序升序存放, 低位寄存器存放到低位地址, 如果不按照升序 as 会warning) The lowest-numbered register is stored to the lowest memory address, through to the highest-numbered register to the highest memory address.
>
> 3. rn = rn - reglist中寄存器的数量*4. 最后更新 rn

伪代码:

注: BitCount() 统计 bit String 中出现的 1 的数量

```
if ConditionPassed() then 
		EncodingSpecificOperations(); NullCheckIfThumbEE(n); 
		address = R[n] - 4*BitCount(registers); // 首先减去内存地址, 之后再减去的内存地址中存储 		 for i = 0 to 14 
			if registers<i> == ‘1’ then 
					if i == n && wback && i != LowestSetBit(registers) then 
							MemA[address,4] = bits(32) UNKNOWN; // Only possible for encoding A1 						else 
							MemA[address,4] = R[i]; 
					address = address + 4; 
			if registers<15> == ‘1’ then // Only possible for encoding A1 
					MemA[address,4] = PCStoreValue(); 
			if wback then R[n] = R[n] - 4*BitCount(registers); // 最后更新 rn
```

### `push`

```asm
push    {r1, r2}
```

`push` 可以理解为 `stmdb` 的语法糖, 这两个指令机器码是相同的. push 就是 stmdb 中, sp 作为 rn, 而且, 开启写回的情况.

伪代码:

```
if ConditionPassed() then
    EncodingSpecificOperations(); NullCheckIfThumbEE(13); 
    address = SP - 4*BitCount(registers); // 先把空间退出来, 在这个空间里存放寄存器
    for i = 0 to 14 // 这个列表没有顺序, 无论怎么样都是 r0 到 r14
        if registers<i> == ‘1’ then
            if i == 13 && i != LowestSetBit(registers) then // Only possible for encoding A1
                MemA[address,4] = bits(32) UNKNOWN; 
            else
                MemA[address,4] = R[i];  // 必须对齐的内存访问
            address = address + 4;
if registers<15> == ‘1’ then // Only possible for encoding A1 or A2 
        MemA[address,4] = PCStoreValue();
SP = SP - 4*BitCount(registers); //更新 sp, 栈向下生长
```



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

伪代码:

```
if ConditionPassed() then
		EncodingSpecificOperations(); NullCheckIfThumbEE(n); 
		address = R[n];
		for i = 0 to 14
			if registers<i> == ‘1’ then
				R[i] = MemA[address,4]; address = address + 4;
		if registers<15> == ‘1’ then 
			LoadWritePC(MemA[address,4]);
		if wback && registers<n> == ‘0’ then R[n] = R[n] + 4*BitCount(registers); 
		if wback && registers<n> == ‘1’ then R[n] = bits(32) UNKNOWN;
```

### `pop`

```asm
pop     {r1, r2}
```

是 `ladmia` 的语法糖, 这两个指令机器码也是相同的. `pop` 就是 `ldmia` 在 rn = sp, 而且开启写回的情况

例子: 

```
LDM<c><q>	SP!, <registers> store mutiple
pop	{r4, r5} e8bd0030
cond		w   rn		register list
1110 100010 1 1 1101 0 000 0000 0011 0000
```

伪代码:

```
if ConditionPassed() then
    EncodingSpecificOperations(); NullCheckIfThumbEE(13); 
    address = SP;
    for i = 0 to 14
        if registers<i> == ‘1’ then
            R[i} = MemA[address,4]; address = address + 4;
if registers<15> == ‘1’ then LoadWritePC(MemA[address,4]);
if registers<13> == ‘0’ then SP = SP + 4*BitCount(registers); 
if registers<13> == ‘1’ then SP = bits(32) UNKNOWN;
```



## 使用栈

没什么好说的, 总之要确保 pop 和 push 的调用是一一对应
