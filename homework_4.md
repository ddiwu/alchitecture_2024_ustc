# 第四次作业

**PB21020485 吴敌**



## 1
> 1. $$
>    1.5 GHz \times 0.8 \times 0.85 \times 0.7 \times 10 \times 8 = 57.12\ GFLOP/s
>    $$
>
> 2. （1）加速比为$16/8 = 2$
> 
>    （2）加速比为$15/10 = 1.5$
>
>    （3）加速比为$0.95/0.8 = 1.11$

## 2

> 1. 6个浮点运算，都4个写两个总共24Byte
>
> 2. ```assembly
>    	  addi  $VL,$r0,#44     #first 44 ops
>    	  addi  $r1,$r0,#0
>    loop: lv	$v1,a_rm+$r1
>          lv	$v2,b_rm+$r1
>          multv $v3,$v1,$v2
>          lv	$v4,a_im+$r1
>          lv	$v5,a_im+$r1
>          multv $v6,$v4,$v5
>          subtv $v3,$v3,$v6
>          sv	$v3,c_re+$r1
>          multv $v3,$v1,$v5
>          multv $v6,$v2,$v4
>          addtv $v3,$v3,$v6
>          sv	$v3,c_im+$r1
>          bne   $r1,0,norm
>          addi  $r1,$r1,#176    #float 4 Byte
>          addi  $VL,$r0,#64
>          j 	loop
>    norm: addi  $r1,$r1,#256
>    	  bne   $r1,1200,loop
>    ```
>
> 3. ```assembly
>    #lv		第一次启动15个+执行64个
>    #lv		单一储存器
>    mul	lv	#这条启动15个+64
>    lv	mul #15+64
>    sub sv	#15+64
>    mul lv	#取下个周期的15+64
>    mul lv	#15+64
>    add	sv	#15+64
>    ```
>
>    总共包含启动开销（稳定情况下）为474周期
>
> 4. 执行单元没多，所以和3的时钟周期均一致
