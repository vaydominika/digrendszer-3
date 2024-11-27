        .proc   p2
        
        org     1
        
        ldl0    sp,verem_vege
        
        ; Üzenet kiírása
        ces     eprintf
        db      "Irj be egy szoveget: ",0
        
        ldl0    r3,0        ; Szavak számlálója (nulláról indulunk)
        ldl0    r5,0        ; Előző karakter betű volt-e (0=nem, 1=igen)
        
olvas:  
        ces     getchar     ; Karakter beolvasása
        
        ; Enter ellenőrzése
        mvzl    r1,13       ; Enter ASCII kódja (CR)
        cmp     r4,r1       ; Enter volt?
        z jmp   vege        ; Ha igen, vége
        
        mov     r0,r4       ; Átmásoljuk R4-ből R0-ba a kiíráshoz
        ces     putchar     ; Kiírjuk a karaktert (echo)
        
        ; Betű ellenőrzése
        mov     r0,r4       ; Karakter átmásolása R0-ba isalpha-hoz
        call    isalpha     ; Betű-e?
        
        ; Ha nem betű, akkor r5 = 0
        NC ldl0 r5,0
        NC jmp  olvas
        
        ; Ha betű és r5 = 0, akkor új szó kezdődik
        sz      r5
        NZ jmp  kovetkezo   ; Ha r5 nem nulla, akkor már számoltuk ezt a szót
        plus    r3,1        ; Új szó kezdődik
kovetkezo:
        ldl0    r5,1        ; Jelezzük hogy betűnél vagyunk
        jmp     olvas
        
vege:
        ; Új sor karakter kiírása
        mvzl    r0,10       ; LF karakter
        ces     putchar
        
        ; Eredmény kiírása
        mov     r1,r3       ; A szavak számát R3-ból R1-be másoljuk az eprintf számára 
        mov     r0,r1  
        ces     eprintf
        db      "Ennyi szo van a szovegben: %d\n",0
        
        
        jmp     0xf000      ; Kilépés a monitorba
        
        ds      100         
verem_vege:
        db      0