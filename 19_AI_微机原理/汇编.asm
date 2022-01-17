;author：fkw
;creat time: 2021/11/20
;coding: gb2312
;version: 3.0
;finish time: 2021/11/14

;定义堆栈段
stack segment stack
    db 256 dup(0)   
top label word  ; 插入一个变量，名称为top，类型为word, 即栈顶
stack ends

;定义数据段
data segment
;定义输入提示
    tips0 db 'Welcome! Please press the corresponding number(1-5)',0dh,0ah,'$'
    tips1 db '1.Change small letter into capital letter of string$',0dh,0ah,'$'
    tips2 db '2.Find the maximum ASCII value in the string',0dh,0ah,'$'
    tips3 db '3.Sorts strings from large to small',0dh,0ah,'$'
    tips4 db '4.Show time',0dh,0ah,'$'
    tips5 db '5.Exit',0dh,0ah,'$'
    tipsn db 'Any key to again and ESC to return main menu$',0dh,0ah,'$'
    in_str db 'Please input a string: $'
    out_str db 'The changed string is:$'
    in_num db 'Please input the numbers(0-255):$'
    out_num db 'The sorted numbers is:$'
    max_num db 'The max number is:$'
    out_time db 'Now time is:$'
    str_pre db 'The Original string is:$'
    ;字符缓冲区
    keybuf  db 129 ;容量129
            db 0   ;存放string中字符个数
            db 61 dup(0) ;存放string
    numbuf db 0
            db 20 dup(0)
data ends 
            
;code段定义
code segment
    assume cs:code ds:data,ss:stack ;声明数据段，代码段，堆栈段
start:
    mov ax, data  ;data->ax   立即数不能直接到段寄存器，通常段寄存器->通用寄存器->段寄存器
    mov ds, ax    ;ax->ds     ds：数据段寄存器,用于存放当前数据段的段地址
    mov ax, stack ;stack->ax   
    mov ss, ax    ;ax->ss     ss: 堆栈段寄存器,用于存放当前堆栈段的段地址
    mov sp, offset top       ;sp: 堆栈指针，用于保存堆栈段的段内偏移地址   offset top: 栈顶的偏移地址  
main:         
    call menu   ;调用menu
    again:      
    mov ah,2  
    mov bh,0    ;页号
    mov dl,0   ;列号
    mov dh,6   ;行号
    int 10h     ;光标位置设置
    mov ah,1
    int 21h     ;带返回码结束用户程序
    cmp al,'1'
    jb  again
    cmp al,'5'
    ja  again
    ;功能选择
    cmp al,'1'
    jz opt1   
    cmp al,'2'
    jz opt2
    cmp al,'3'
    jz opt3
    cmp al,'4'
    jz opt4
    cmp al,'5'
    jz opt5

opt1:
    call changestr
    ;带回显的字符输入
    mov ah,8
    int 21h
    ;输入esc则调到main
    cmp al,1bh
    jz main
    ;输入其他的跳到子程序opt1
    jmp opt1
opt2:    
    call maxnumber
    mov ah,8
    int 21h
    cmp al,1bh
    jz main
    jmp opt2
opt3:
    call sortnumber
    mov ah,8
    int 21h
    cmp al,1bh
    jz main
    jmp opt3
opt4:
    call showtime
    mov ah,8
    int 21h
    cmp al,1bh
    jz main
    jmp opt4
opt5:
    mov ah,4ch
    int 21h
    
menu:
    mov ah,0   ;入口参数ah=0
    mov al,3   ;显示模式80*25 16色
    mov bl,0   
    int 10h         
    ;设置光标位置        
    mov ah,2   ;入口参数ah=2,设置光标位置
    mov bh,0   ;bh=页号
    mov dl,0   ;dl=列号
    mov dh,0   ;dh=行号
    int 10h    ;光标位置设置  
    ;输出tips0
    mov ah,9  ;入口参数ah=9,在光标处显示字符串
    lea dx,tips0  ;取tips0的地址
    int 21h   ;显示字符串
    ;设置光标位置
    mov ah,2  
    mov dl,0   
    mov dh,1  
    int 10h
    ;输出tips1   
    mov ah,9
    lea dx,tips1
    int 21h
    ;设置光标位置     
    mov ah,2  
    mov dl,0  
    mov dh,2  
    int 10h   
    ;输出tips2
    mov ah,9
    lea dx,tips2
    int 21h
    ;设置光标位置
    mov ah,2  
    mov dl,0 
    mov dh,3  
    int 10h   
    ;输出tips3
    mov ah,9
    lea dx,tips3
    int 21h
    ;设置光标位置
    mov ah,2  
    mov dl,0  
    mov dh,4  
    int 10h  
    ;输出tips4
    mov ah,9
    lea dx,tips4
    int 21h    
    ;设置光标位置
    mov ah,2  
    mov dl,0  
    mov dh,5  
    int 10h   
    ;输出tips5
    mov ah,9
    lea dx,tips5
    int 21h  
    ret

;小写转大写                         
changestr:
rechg:
    ;清屏 
    mov ah,0   
    mov al,3    ;设置显示方式
    mov bl,0
    int 10h  
    ;输入提示光标位置设置  
    mov ah,2
    mov bh,0    ;页号
    mov dl,0    ;列号
    mov dh,0    ;行号
    int 10h  
    ;输出tips 
    mov ah,9
    lea dx,in_str
    int 21h
    ;输入sting
    
    mov ah,2
    mov dl,0
    mov dh,1
    int 10h
    ;键盘输入到缓存区
    mov ah,0ah
    lea dx,keybuf
    int 21h
    ;判定输入字符串是否为空    
    cmp keybuf+1,0
    jz rechg  ;若为空重新开始
    ;字符串末尾加 $
    lea bx,keybuf+2  ;bx为输入字符串的首地址
    mov al,keybuf+1  ;keybuff+1为输入的字符个数
    cbw              ;al—>ax 扩展
    mov cx,ax        ;字符串长度->cx用作loop的传入参数
    add bx,ax        ;ax->bx  bx为字符串末尾的下一位地址
    mov byte ptr [bx],'$' ;在输入字符串的末尾加上结束标识符
    lea bx,keybuf+2
    
    ;设置光标位置
    mov ah,2
    mov bh,0
    mov dl,0
    mov dh,2
    int 10h

    mov ah,9
    lea dx ,str_pre
    int 21h
    mov ah,9
    lea dx ,keybuf+2
    int 21h    
    lea bx,keybuf+2
    
lchg:
    ;判断是否需要转换
    cmp byte ptr [bx],61h
    jb nochg  ;不需要转换跳转
    and byte ptr [bx],0dfh ;小写转大写
nochg:
    inc bx  ;bx++
    loop lchg     ;loop循环，传入参数（循环次数为cx）
    
    ;设置光标位置
    mov ah,2
    mov bh,0
    mov dl,0
    mov dh,3
    int 10h
    ;输出tips
    mov ah,9
    lea dx,out_str
    int 21h
    ;输出改变后的字符串
    mov ah,9
    lea dx,keybuf+2
    int 21h
    ;清屏，设置光标位置
    mov ah,2
    mov bh,0
    mov dl,0
    mov dh,4
    int 10h
    ;输出tips
    mov ah,9
    lea dx,tipsn
    int 21h
    ret

;找最大数
maxnumber:
remax:
    ;设置显示器方式
    mov ah,0
    mov al,3
    mov bl,0
    int 10h ;清屏
    ;光标位置
    mov ah,2
    mov bh,0
    mov dl,0
    mov dh,0
    int 10h
    ;输出tips
    mov ah,9
    lea dx,in_str
    int 21h
    ;设置光标位置
    mov ah,2
    mov dl,0
    mov dh,1
    int 10h
    ;输入字符串到缓存区 keybuf+1为字符个数，keybuf+2开始为字符串
    mov ah,0ah
    lea dx,keybuf
    int 21h
    ;判断字符串是否为空
    cmp keybuf+1,0
    jz remax ;字符串为空重新输入

    lea bx,keybuf+2  ;bx为字符串首地址
    mov al,keybuf+1  ;al为输入的字符串长度
    cbw   ;al->ax 扩展al
    mov cx,ax  ;cx用作loop的传入参数
    add bx,ax  ;bx为字符串末尾的下一个地址
    mov byte ptr [bx],'$' ;末尾加 $
    
    ;设置光标位置
    mov ah,2
    mov bh,0
    mov dl,0
    mov dh,2
    int 10h

    mov ah,9
    lea dx ,str_pre
    int 21h
    mov ah,9
    lea dx ,keybuf+2
    int 21h    

    ;设置光标位置
    mov ah,2
    mov bh,0
    mov dl,0
    mov dh,3
    int 10h
    ;输出tips
    mov ah,9
    lea dx,max_num
    int 21h
    

    mov dl,0 ;dl存储最大值
    lea bx,keybuf+2

;选出最大值
lcmp:   
    cmp [bx],dl ;判断是否小于dl
    jb nolchg
    mov dl,[bx]
nolchg:
    inc bx
    loop lcmp
    

    mov ah,2
    int 21h
    ;设置光标位置
    mov ah,2
    mov bh,0
    mov dl,0
    mov dh,4
    int 10h
    ;输出tips
    mov ah,9
    lea dx,tipsn
    int 21h
    ret
;转16进制并sort
sortnumber:
resort:
     mov ah,0 
     mov al,3 
     mov bl,0 
     int 10h

     mov ah,2
     mov bh,0
     mov dl,0
     mov dh,0
     int 10h

     mov ah,9
     lea dx,in_num
     int 21h

     mov ah,2
     mov dl,0
     mov dh,1
     int 10h

     mov ah,0ah
     lea dx,keybuf
     int 21h
     
     lea bx,keybuf+2  ;bx为字符串首地址
    mov al,keybuf+1  ;al为输入的字符串长度
    cbw   ;al->ax 扩展al
    mov cx,ax  ;cx用作loop的传入参数
    add bx,ax  ;bx为字符串末尾的下一个地址
    mov byte ptr [bx],'$' ;末尾加 $

    ;设置光标位置
    mov ah,2
    mov bh,0
    mov dl,0
    mov dh,2
    int 10h

    mov ah,9
    lea dx ,str_pre
    int 21h
    mov ah,9
    lea dx ,keybuf+2
    int 21h  
     call cin_int
     cmp al,0
     jz resort
     cmp numbuf,0
     jz resort
     
     mov ah,2
     mov bh,0
     mov dl,0
     mov dh,3
     int 10h

     mov ah,9
     lea dx,out_num
     int 21h



     call mpsort
     call int_out
     mov ah,2
     mov bh,0
     mov dl,0
     mov dh,4
     int 10h
     mov ah,9
     lea dx,tipsn
     int 21h
     ret

cin_int:
     mov cl,keybuf+1
     lea si,keybuf+2
     mov ch,0
     mov dh,10
     mov al,0
     mov dl,0
fndnum:
     cmp byte ptr[si],' ' 
     jz addnum
     cmp byte ptr[si],'0'
     jb errnum
     cmp byte ptr[si],'9'
     ja errnum
     mov dl,1
     mul dh
     
     xor bh,bh
     mov bl,[si]
     add ax,bx
     sub ax,'0'
     cmp ah,0
     ja errnum
     jmp next
addnum: 
     cmp dl,1
     jnz next
     inc ch
     call addnew
     mov dl,0
     mov al,0
next:
     inc si
     dec cl
     cmp cl,0
     jnz fndnum
     cmp dl,1
     jnz total
     inc ch
     call addnew
total:
     mov numbuf,ch
     mov al,1
     jmp crtnum 
     
errnum:
     mov al,0
     
crtnum:
     ret


addnew:

     push ax
     lea bx,numbuf
     mov al,ch
     cbw
     add bx,ax
     pop ax
     mov [bx],al
     ret

mpsort:
     mov al,numbuf
     cmp al,1
     jbe nosort
     cbw
     mov cx,ax
     lea si,numbuf
     add si,cx
     dec cx 
lp1: 
     push cx
     push si
     mov dl,0
lp2: 
     mov al,[si]
     cmp al, [si-1]
     jae noxchg
     xchg al, [si-1]
     mov [si],al
     mov dl,1
noxchg:
     dec si
     loop lp2
     pop si
     pop cx
     cmp dl,1
     jnz nosort
     loop lp1 
     
nosort:ret
 


int_out:
     mov al,numbuf
     cbw
     mov cx,ax
     mov bl,10h
     lea si,numbuf + 1
print:
     mov al,[si]
     call outnum
     inc si
     mov ah,2
     mov dl,' '
     int 21h
     loop print
     ret



outnum: 
     mov ah,0
     div bl
     push ax
     cmp ah,10
     jb pnum
     add ah,7
pnum: add ah,30h
     mov dl,ah
     pop ax
     push dx
     cmp al,0
     jz outn
     call outnum
outn:
     pop dx
     mov ah,2
     int 21h
     ret



;时间展示
showtime:
    ;清屏
    mov ah,0
    mov al,3
    mov bl,0
    int 10h 
    ;光标位置
    mov ah,2
    mov bh,0
    mov dl,0
    mov dh,0
    int 10h
    ;输出tips
    mov ah,9
    lea dx,out_time
    int 21h
dis:
    ;光标位置
    mov ah,2
    mov bh,0
    mov dl,72
    mov dh,0
    int 10h
    ;取系统时间
    mov ah,2ch
    int 21h
    ;显示小时
    mov al,ch
    call shownum
    ;显示：
    mov ah,2
    mov dl,':'
    int 21h
    ;显示分钟
    mov al,cl
    call shownum
    ;显示：
    mov ah,2
    mov dl,':'
    int 21h
    ;显示秒
    mov al,dh
    call shownum
    ;清屏，设置光标位置
    mov ah,2
    mov bh,0
    mov dl,0
    mov dh,1
    int 10h
    ;输出tips
    mov ah,9
    lea dx,tipsn
    int 21h
    ;检测键盘输入
    mov ah,0bh
    int 21h
    cmp al,0
    jz dis    
    
ret

shownum:     
;把al中的数字以十进制输出
;入口参数al
;出口参数：无
    cbw
    push cx
    push dx

    mov cl,10
    div cl

    add ah,'0'
    mov bh,ah
    add al,'0'
         
    mov ah,2

    mov dl,al
    int 21h

    mov dl,bh
    int 21h

    pop dx
    pop cx
    ret

code ends   
end start
