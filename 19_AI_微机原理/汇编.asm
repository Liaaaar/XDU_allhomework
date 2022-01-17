;author��fkw
;creat time: 2021/11/20
;coding: gb2312
;version: 3.0
;finish time: 2021/11/14

;�����ջ��
stack segment stack
    db 256 dup(0)   
top label word  ; ����һ������������Ϊtop������Ϊword, ��ջ��
stack ends

;�������ݶ�
data segment
;����������ʾ
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
    ;�ַ�������
    keybuf  db 129 ;����129
            db 0   ;���string���ַ�����
            db 61 dup(0) ;���string
    numbuf db 0
            db 20 dup(0)
data ends 
            
;code�ζ���
code segment
    assume cs:code ds:data,ss:stack ;�������ݶΣ�����Σ���ջ��
start:
    mov ax, data  ;data->ax   ����������ֱ�ӵ��μĴ�����ͨ���μĴ���->ͨ�üĴ���->�μĴ���
    mov ds, ax    ;ax->ds     ds�����ݶμĴ���,���ڴ�ŵ�ǰ���ݶεĶε�ַ
    mov ax, stack ;stack->ax   
    mov ss, ax    ;ax->ss     ss: ��ջ�μĴ���,���ڴ�ŵ�ǰ��ջ�εĶε�ַ
    mov sp, offset top       ;sp: ��ջָ�룬���ڱ����ջ�εĶ���ƫ�Ƶ�ַ   offset top: ջ����ƫ�Ƶ�ַ  
main:         
    call menu   ;����menu
    again:      
    mov ah,2  
    mov bh,0    ;ҳ��
    mov dl,0   ;�к�
    mov dh,6   ;�к�
    int 10h     ;���λ������
    mov ah,1
    int 21h     ;������������û�����
    cmp al,'1'
    jb  again
    cmp al,'5'
    ja  again
    ;����ѡ��
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
    ;�����Ե��ַ�����
    mov ah,8
    int 21h
    ;����esc�����main
    cmp al,1bh
    jz main
    ;���������������ӳ���opt1
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
    mov ah,0   ;��ڲ���ah=0
    mov al,3   ;��ʾģʽ80*25 16ɫ
    mov bl,0   
    int 10h         
    ;���ù��λ��        
    mov ah,2   ;��ڲ���ah=2,���ù��λ��
    mov bh,0   ;bh=ҳ��
    mov dl,0   ;dl=�к�
    mov dh,0   ;dh=�к�
    int 10h    ;���λ������  
    ;���tips0
    mov ah,9  ;��ڲ���ah=9,�ڹ�괦��ʾ�ַ���
    lea dx,tips0  ;ȡtips0�ĵ�ַ
    int 21h   ;��ʾ�ַ���
    ;���ù��λ��
    mov ah,2  
    mov dl,0   
    mov dh,1  
    int 10h
    ;���tips1   
    mov ah,9
    lea dx,tips1
    int 21h
    ;���ù��λ��     
    mov ah,2  
    mov dl,0  
    mov dh,2  
    int 10h   
    ;���tips2
    mov ah,9
    lea dx,tips2
    int 21h
    ;���ù��λ��
    mov ah,2  
    mov dl,0 
    mov dh,3  
    int 10h   
    ;���tips3
    mov ah,9
    lea dx,tips3
    int 21h
    ;���ù��λ��
    mov ah,2  
    mov dl,0  
    mov dh,4  
    int 10h  
    ;���tips4
    mov ah,9
    lea dx,tips4
    int 21h    
    ;���ù��λ��
    mov ah,2  
    mov dl,0  
    mov dh,5  
    int 10h   
    ;���tips5
    mov ah,9
    lea dx,tips5
    int 21h  
    ret

;Сдת��д                         
changestr:
rechg:
    ;���� 
    mov ah,0   
    mov al,3    ;������ʾ��ʽ
    mov bl,0
    int 10h  
    ;������ʾ���λ������  
    mov ah,2
    mov bh,0    ;ҳ��
    mov dl,0    ;�к�
    mov dh,0    ;�к�
    int 10h  
    ;���tips 
    mov ah,9
    lea dx,in_str
    int 21h
    ;����sting
    
    mov ah,2
    mov dl,0
    mov dh,1
    int 10h
    ;�������뵽������
    mov ah,0ah
    lea dx,keybuf
    int 21h
    ;�ж������ַ����Ƿ�Ϊ��    
    cmp keybuf+1,0
    jz rechg  ;��Ϊ�����¿�ʼ
    ;�ַ���ĩβ�� $
    lea bx,keybuf+2  ;bxΪ�����ַ������׵�ַ
    mov al,keybuf+1  ;keybuff+1Ϊ������ַ�����
    cbw              ;al��>ax ��չ
    mov cx,ax        ;�ַ�������->cx����loop�Ĵ������
    add bx,ax        ;ax->bx  bxΪ�ַ���ĩβ����һλ��ַ
    mov byte ptr [bx],'$' ;�������ַ�����ĩβ���Ͻ�����ʶ��
    lea bx,keybuf+2
    
    ;���ù��λ��
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
    ;�ж��Ƿ���Ҫת��
    cmp byte ptr [bx],61h
    jb nochg  ;����Ҫת����ת
    and byte ptr [bx],0dfh ;Сдת��д
nochg:
    inc bx  ;bx++
    loop lchg     ;loopѭ�������������ѭ������Ϊcx��
    
    ;���ù��λ��
    mov ah,2
    mov bh,0
    mov dl,0
    mov dh,3
    int 10h
    ;���tips
    mov ah,9
    lea dx,out_str
    int 21h
    ;����ı����ַ���
    mov ah,9
    lea dx,keybuf+2
    int 21h
    ;���������ù��λ��
    mov ah,2
    mov bh,0
    mov dl,0
    mov dh,4
    int 10h
    ;���tips
    mov ah,9
    lea dx,tipsn
    int 21h
    ret

;�������
maxnumber:
remax:
    ;������ʾ����ʽ
    mov ah,0
    mov al,3
    mov bl,0
    int 10h ;����
    ;���λ��
    mov ah,2
    mov bh,0
    mov dl,0
    mov dh,0
    int 10h
    ;���tips
    mov ah,9
    lea dx,in_str
    int 21h
    ;���ù��λ��
    mov ah,2
    mov dl,0
    mov dh,1
    int 10h
    ;�����ַ����������� keybuf+1Ϊ�ַ�������keybuf+2��ʼΪ�ַ���
    mov ah,0ah
    lea dx,keybuf
    int 21h
    ;�ж��ַ����Ƿ�Ϊ��
    cmp keybuf+1,0
    jz remax ;�ַ���Ϊ����������

    lea bx,keybuf+2  ;bxΪ�ַ����׵�ַ
    mov al,keybuf+1  ;alΪ������ַ�������
    cbw   ;al->ax ��չal
    mov cx,ax  ;cx����loop�Ĵ������
    add bx,ax  ;bxΪ�ַ���ĩβ����һ����ַ
    mov byte ptr [bx],'$' ;ĩβ�� $
    
    ;���ù��λ��
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

    ;���ù��λ��
    mov ah,2
    mov bh,0
    mov dl,0
    mov dh,3
    int 10h
    ;���tips
    mov ah,9
    lea dx,max_num
    int 21h
    

    mov dl,0 ;dl�洢���ֵ
    lea bx,keybuf+2

;ѡ�����ֵ
lcmp:   
    cmp [bx],dl ;�ж��Ƿ�С��dl
    jb nolchg
    mov dl,[bx]
nolchg:
    inc bx
    loop lcmp
    

    mov ah,2
    int 21h
    ;���ù��λ��
    mov ah,2
    mov bh,0
    mov dl,0
    mov dh,4
    int 10h
    ;���tips
    mov ah,9
    lea dx,tipsn
    int 21h
    ret
;ת16���Ʋ�sort
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
     
     lea bx,keybuf+2  ;bxΪ�ַ����׵�ַ
    mov al,keybuf+1  ;alΪ������ַ�������
    cbw   ;al->ax ��չal
    mov cx,ax  ;cx����loop�Ĵ������
    add bx,ax  ;bxΪ�ַ���ĩβ����һ����ַ
    mov byte ptr [bx],'$' ;ĩβ�� $

    ;���ù��λ��
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



;ʱ��չʾ
showtime:
    ;����
    mov ah,0
    mov al,3
    mov bl,0
    int 10h 
    ;���λ��
    mov ah,2
    mov bh,0
    mov dl,0
    mov dh,0
    int 10h
    ;���tips
    mov ah,9
    lea dx,out_time
    int 21h
dis:
    ;���λ��
    mov ah,2
    mov bh,0
    mov dl,72
    mov dh,0
    int 10h
    ;ȡϵͳʱ��
    mov ah,2ch
    int 21h
    ;��ʾСʱ
    mov al,ch
    call shownum
    ;��ʾ��
    mov ah,2
    mov dl,':'
    int 21h
    ;��ʾ����
    mov al,cl
    call shownum
    ;��ʾ��
    mov ah,2
    mov dl,':'
    int 21h
    ;��ʾ��
    mov al,dh
    call shownum
    ;���������ù��λ��
    mov ah,2
    mov bh,0
    mov dl,0
    mov dh,1
    int 10h
    ;���tips
    mov ah,9
    lea dx,tipsn
    int 21h
    ;����������
    mov ah,0bh
    int 21h
    cmp al,0
    jz dis    
    
ret

shownum:     
;��al�е�������ʮ�������
;��ڲ���al
;���ڲ�������
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
