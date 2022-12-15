# p3_nested_routine

## 嵌套调用

在`p1_branch_with_lr` 中 demo 过如何使用 `bl` 指令调用 subroutine. 每次调用的时候都会把 `pc` 的下一条指令放进 `br` 中保存. 

问题是如果进行嵌套调用的话, 函数内部的`bl`调用就会覆盖掉之前在 `lr` 中的地址. 

解决方法是把在 subroutine 开始执行的时候把 `lr` 入栈:

```asm
push {lr}
@ ...执行各种操作
@ 调用子程序
bl	label
@ 执行各种操作
pop {lr}
bx lr
@ 或者可以直接把 lr 出栈道 pc
@ pop {pc}
```

最好在 subroutine 的开始就入栈, 在结束的时候出栈, 这样可以方便的找到相关语句的位置.

## AAPCS

`The ARM Advanced Assembly Programming Calling Standard (AAPCS) `  是一套指令调用规范. 

- r0 作为返回值
- r0-r4 作为参数
- r4-r12 作为工作寄存器, 保存这些寄存器是被叫函数的责任
- r13 作为 sp, 栈指针
- r14 作为 lr, 链接寄存器, 必须妥善保存
- r15 作为 pc, 程序计数器
- CPSR 任何时候都不能随意修改

## 实践 AAPCS

### caller 的任务:

准备调用 subroutine

1. 入栈 `r0-r4` 
2. 把参数移动到 `r0-r4` 中
3. 如果有多余的参数, 把多余的参数入栈
4. 使用 `bl` 指令调用 subroutine

结束调用之后

1. 转存在 `r0` 中的返回值
2. 恢复 `r0-r4`

### called 的任务

在 subroutine 开始执行的时候:

1. 入栈 `r4-r12` 和 `lr`, 尤其是涉及到嵌套的话. 这样可以保存 caller 的工作寄存器

在 subroutine 结束执行的时候:

1. 把返回值放进 `r0`
2. 出栈 `r4-r12` 和 `lr`, 恢复 caller 的工作寄存器
3. 调用 `bx` 来返回. 或者可以直接在出栈的时候就把 `lr`出到 `pc` 中, 比如 `pop {r4-r12, pc}`

> 注意, 这种直接出栈到 `pc` 的写法只能在 arm 模式下使用
>
> `pop {r4-r12, pc}` 这种写法在 thumb 模式下是用不了的.