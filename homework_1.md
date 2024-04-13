# 第一次作业

**PB21020485 吴敌**



## 1
> (1) 
>
> LD-USE： 1->2 R1; 
>
> 数据定向：2->3 R1 RAW; 4->5 R2 RAW; 5->6 R4 RAW;
>
> (2)（假定EX段完才开始读存储器的值，而不是提前一个周期放入其读地址端口）
>
> 每次遇到RAW相关和hazard，延迟两个周期，遇到储存器再加一个周期；那么从第一个循环执行完到第二个开始需要18个周期。
>
> (3)
>
> RAW相关不会延迟流水线，hazrd有一个，分支预测失败有两个，存储器有一个；那么总共需要11个。
>
> (4)
>
> 分支预测成功不延迟。总共需要9个周期。

## 2

> (1)
>
> ![IMG_9589](C:\Users\32713\Downloads\IMG_9589.JPG)
>
> 先计算$A_i + B_i$，在将这些和分别乘积得到结果。    
>
> 吞吐率：执行7次计算，共18个周期：
> $$
> TP = \frac{7}{18\Delta t}
> $$
> 加速比：非流水线时间：$4 \times 3\Delta t + 3 \times 5\Delta t = 27 \Delta t$
> $$
> S = \frac{27\Delta t}{18\Delta t} = 1.5
> $$
> 效率：通过面积比值计算得到：
> $$
> E = \frac{3 \times 4 + 3 \times 5}{18 \times 5} = 0.3
> $$

## 3

>(1)
>
>sw，lw有结构相关，所以各延迟一个周期，
>
>总执行时间为：$(5 + 4 + 2) \times 200ps = 2.2ns$
>
>可以解决：结构相关即写数据时，无法取指令，通过nop即可使两个段错开。
>
>(2)
>
>分支阻塞时，在ID级：延迟一个周期；在EXE级：延迟两个分支。
>$$
>S = \frac{11 + 2}{11 + 1} = \frac{13}{12}
>$$
>(3)
>
>最大段执行时间仍为200ps
>$$
>S = \frac{13}{12}
>$$
>(4)
>
>时钟周期会增大为210ps。总执行时间$(11 + 3) \times 210ps = 2.94ns$
>$$
>S = \frac{2.94}{2.2} = 1.32
>$$
>
