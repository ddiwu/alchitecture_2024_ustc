# 第三次作业

**PB21020485 吴敌**



## 1
> 1. $$
>    CPI = 1 + 0.15*（0.1 * 3 + 0.9 * 0.1 * 4） = 1.099
>    $$
>
> 2. $$
>    CPI_2  = 1 + 0.15 *2 = 1.3 > 1.099
>    $$
>
>    所以分支预测方法执行的更快

## 2

> 1. 调度后：
>
>    | 周期 |  指令  |
>    | :--: | :----: |
>    |  1   | DADDIU |
>    |  2   |   LD   |
>    |  3   |   LD   |
>    |  4   |  MULD  |
>    |  5   | DADDIU |
>    |  6   | DADDIU |
>    |  7   | DSLTU  |
>    |  8   | STALL  |
>    |  9   | STALL  |
>    |  10  |  ADDD  |
>    |  11  | STALL  |
>    |  12  | STALL  |
>    |  13  | STALL  |
>    |  14  |   SD   |
>    |  15  |  BNEZ  |
>
>    又stall的数目可以看出需要循环三次才能填满这些每个指令后的stall。

## 3

> 1. | 迭代 |  指令  |  IS  |  EX  |  WB  |        备注        |
>    | :--: | :----: | :--: | :--: | :--: | :----------------: |
>    |  1   |   LD   |  1   |  2   |  3   |                    |
>    |  1   |  MULD  |  2   |  4   |  19  | LD写回后一周期执行 |
>    |  1   |   LD   |  3   |  4   |  5   |                    |
>    |  1   |  ADDD  |  4   |  20  |  30  |       等MUL        |
>    |  1   |   SD   |  5   |  31  |  32  |       等ADD        |
>    |  1   | DADDIU |  6   |  7   |  8   |                    |
>    |  1   | DADDIU |  7   |  8   |  9   |                    |
>    |  1   | DSLUT  |  8   |  9   |  10  |                    |
>    |  1   |  BNEZ  |  9   |  11  |  12  |      等DSLUT       |
>    |  2   |   LD   |  10  |  12  |  13  |   预测后一个周期   |
>    |  2   |  MULD  |  11  |  19  |  34  |      等乘法器      |
>    |  2   |   LD   |  12  |  13  |  14  |                    |
>    |  2   |  ADDD  |  13  |  35  |  45  |       等MUL        |
>    |  2   |   SD   |  14  |  46  |  47  |                    |
>    |  2   | DADDIU |  15  |  16  |  17  |                    |
>    |  2   | DADDIU |  16  |  17  |  18  |                    |
>    |  2   | DSLUT  |  17  |  18  |  19  |                    |
>    |  2   |  BNEZ  |  18  |  20  |  21  |                    |
>    |  3   |   LD   |  19  |  21  |  22  |    预测后一周期    |
>    |  3   |  MULD  |  20  |  34  |  49  |                    |
>    |  3   |   LD   |  21  |  22  |  23  |                    |
>    |  3   |  ADDD  |  22  |  50  |  60  |                    |
>    |  3   |   SD   |  23  |  61  |  62  |                    |
>    |  3   | DADDIU |  24  |  25  |  26  |                    |
>    |  3   | DADDIU |  25  |  26  |  27  |                    |
>    |  3   | DSLUT  |  26  |  27  |  28  |                    |
>    |  3   |  BNEZ  |  27  |  29  |  30  |                    |
>
> 第一次循环： 31
>
> 第二次循环： 37
>
> 第三次循环： 43

