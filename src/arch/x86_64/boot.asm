global start

section .text
bits 32
start:
    ; スタックポインタの初期化
    mov esp, stack_top

    ; 各種チェック
    call check_multiboot
    call check_cpuid
    call check_long_mode

    ; print 'Hi from Ix OS'
    ; 白文字緑背景
    mov dword [0xb8000], 0x2f692f48 ; Hi
    mov dword [0xb8004], 0x2f662f20 ;  f
    mov dword [0xb8008], 0x2f6f2f72 ; ro
    mov dword [0xb800c], 0x2f202f6d ; m 
    mov dword [0xb8010], 0x2f782f49 ; Ix
    mov dword [0xb8014], 0x2f4f2f20 ;  O
    mov dword [0xb8018], 0x2f002f53 ; S
    hlt

error:
    ; print 'ERR'
    mov dword [0xb8000], 0x4f524f45
    mov dword [0xb8004], 0x4f3a4f52
    mov dword [0xb8008], 0x4f204f20
    mov byte [0xb800a], al
    hlt

check_multiboot:
    ; magic number
    cmp eax, 0x36d76289
    jne .no_multiboot
    ret
.no_multiboot:
    mov al, "0"
    jmp error

check_cpuid:
    ; FLAGS -> EAX (FLAGSを直接いじることはできないためコピー)
    pushfd
    pop eax

    mov ecx, eax

    ; IDビットを反転
    xor eax, 1 << 21

    ; EAX -> FLAGS
    push eax
    popfd

    ; FLAGS -> EAX (CPUIDがサポートされていればビットが反転されている)
    pushfd
    pop eax

    ; ECX -> FLAGS (FLAGSの復元)
    push ecx
    popfd

    ; EAXとECXを比較
    ; 同じならばIDビットが反転されていないということなのでCPUID未対応
    cmp eax, ecx
    ; ボッシュート
    je .no_cpuid
    ret
.no_cpuid:
    mov al, "1"
    jmp error

check_long_mode:
    ; extended processor infoが使えるかチェック
    ; eaxはcpuidへの暗黙的な引数
    mov eax, 0x80000000
    ; CPUの機能のサポート具合をたしかめる
    ; cpuidの値で想定されている最大の値を取得
    cpuid
    ; 0x80000001以下ならばlong mode未対応
    cmp eax, 0x80000001
    ; ボッシュート
    jb .no_long_mode

    mov eax, 0x80000001
    ; extended processor infoでlong mode対応かチェック
    cpuid
    ; このビットがセットされていなければlong mode非対応
    test edx, 1 << 29
    jz .no_long_mode
    ret

.no_long_mode:
    mov al, "2"
    jmp error

section .bss
stack_bottom:
    resb 64
stack_top:
