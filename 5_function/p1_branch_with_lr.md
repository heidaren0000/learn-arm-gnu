# p1_branch_with_lr



## 指令

### `bl`

```asm
bl  print
@ jump to print lable and save next instruction to lr
```

branch with link. 这是一个特殊的 branch, 在 brach 的时候会把下一条要执行的指令的内存地址(对于 ARM 来说 PC 中的值不是这个!)放到 LR(也就是 R14) 中, 用于在将来返回.

### `bx`

branch with exchange. 这个也是特殊的 branch. 跳转到参数中提供的内存地址. 由于我们把调用 sub routine 之前的下一条指令放到了lr中, 可以直接调用 

```asm
bx  lr
@ jump to address saved in lr
```

## 调用子程序的最简过程

1. 使用 bl 语句跳转到 label, 并且把 bl 的下一条指令存放到 lr 中.
2. 执行子程序
3. 调用 bx, 跳转到 lr 指向的地址.

> 这么做其实是有问题的:
>
> 1. 我们没有给子程序传递参数
> 2. 寄存器状态没有被保存, 所以子程序执行完之后, 即使跳转回去, 寄存器中原本存放的数据也已经被破坏了
> 3. 如果嵌套调用的话, lr 的存放的地址会被另一个子程序覆盖.
>
> 这些问题后面的例子会一一解决.