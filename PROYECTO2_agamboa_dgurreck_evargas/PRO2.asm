TITLE P17HANRD (EXE) 
    .MODEL SMALL
    .STACK 100H
;------------------------
; SEGMENTO DE MACROS
;------------------------
POS_CURSOR MACRO FIL, COL      
    MOV AH, 02H
    MOV BH, 00
    MOV DH, FIL
    MOV DL, COL
    INT 10H
ENDM


;------------------------
; FIN SEGMENTO DE MACROS
;------------------------

;------------------------
; SEGMENTO DE DATOS
;------------------------
    .DATA
    MSG_PROGRAMA_FINALIZADO DB "!PROGRAMA FINALIZADO CON EXITO! ", '$'
    MSG_JUGAR DB "JUGAR ", '$'
    MSG_CARGAR DB "CARGAR PARTIDA ", '$'
    ISCLICK DB 0

    POSX DW 15
    POSY DW 15
    COLOR_PIXEL DB 01H

    ;PARA SABER DONDE SE DIÓ CLICK
    CLICK_SUPERIOR_IZQUIERDA DB 0
    CLICK_LADO_IZQUIERDO DB 0
    CLICK_INFERIOR_IZQUIERDA DB 0
    CLICK_SUPERIOR_DERECHA DB 0
    CLICK_LADO_DERECHO DB 0
    CLICK_INFERIOR_DERECHA DB 0
    CLICK_LADO_SUPERIOR DB 0
    CLICK_LADO_INFERIOR DB 0
    CLICK_CENTRO DB 0

    CLICK_JUGAR DB 0
    CLICK_CARGAR DB 0

    COLOR_LIMITE_ARRIBA DW 0  ; LIMITE DE ARRIBA PARA EL RELLENO
    COLOR_LIMITE_ABAJO DW 0 ; LIMITE DE ABAJO PARA EL RELLENO

    ;PARA SABER QUÉ CUADROS ESTÁN PINTADOS
    SUPERIOR_IZQUIERDA_PINTADO DB 0
;-------------
    COLORES_DIBUJADOS DW 0   ; CANTIDAD DE COLORES DIBUJADOS
    ; PALETA DE COLORES
    CL_ROSADO DB 0DH
    CL_AZUL DB 01H
    CL_VERDE DB 0AH
    CL_ROJO DB 04H
    CL_MARRON DB 0CH
    CL_AMARILLO DB 0EH
    CL_BLANCO DB 0FH
;------------------
;------------------------
; FINAL SEGMENTO DE DATOS
;------------------------

;------------------------
; SEGMENTO DE CODIGO
;------------------------
    .CODE
MAIN PROC FAR

    MOV AX, @DATA
    MOV DS, AX

    CALL LIMPIAR_PANTALLA
    
    ;MOSTRAR CURSOR
    MOV AX, 01H
    INT 33H

    CALL MENU_INICIAL

    CALL RESTAURA_MOUSE

    CALL DIBUJAR_GUI

    CALL DETECTAR_CLICK
    
    CALL CICLO_SISTEMA

    CALL TERMINAR_PROGRAMA
    
MAIN ENDP

RESTAURA_MOUSE PROC
	;RESTAURA ESTADO DEL MOUSE 
    MOV AX, 17H 
    INT 33H 
    ;INICIALIZA MOUSE
    MOV AX, 00H 
    INT 33H 
    ;MOSTRAR CURSOR
    MOV AX, 01H
    INT 33H

    MOV AX,07H  ;Petición para fijar límite horizontal
    MOV CX,638  ;Límite inferior
    MOV DX,00   ;Límite superior
    INT 33H

    MOV AX, 08H ;Petición para fijar límite vertical
    MOV CX,340  ;Límite inferior
    MOV DX,0    ;Límite superior
    INT 33H 

    MOV AX, 1AH ;Petición para establecer sensibilidad del ratón
    MOV BX, 8   ;Mickeys horizontales (por omisión = 8)
    MOV CX, 32  ;Mickeys verticales (por omisión = 16)
    MOV DX, 100  ;Umbral de velocidad (por omisión = 64)
    INT 33H 
    RET
RESTAURA_MOUSE ENDP

CICLO_SISTEMA PROC

    MOV AX, 0001H
    INT 33H
    
   ; CALL DETECTAR_CLICK
    CALL CICLO_SISTEMA
    RET
    
CICLO_SISTEMA ENDP

DETECTAR_CLICK PROC
    MOV AX, 03H                 ; PARA DETECTAR CUANDO SE SUELTA EL CLICK
    INT 33h                     ; SE LLAMA LA INTERRUPCION DEL MOUSE     
    CMP BX, 1                   ; LA INTERRUPCION DEVUELVE EN BX LA CANTIDAD DE VECES QUE SE SOLTO, ENTONCES COMPARO CON 1
    JNL COMPARAR_COORDENADAS    ; SI SE PRESIONO AL MENOS UNA VEZ, SALTA A CLICK_IZQUIERDO
    JNE DETECTAR_CLICK

    COMPARAR_COORDENADAS:

        CALL COORDENADAS_SUPERIOR_IZQUIERDA
        CALL COORDENADAS_LADO_IZQUIERDO
        CALL COORDENADAS_INFERIOR_IZQUIERDA

        CALL COORDENADAS_SUPERIOR_DERECHA
        CALL COORDENADAS_LADO_DERECHO
        CALL COORDENADAS_INFERIOR_DERECHA

        CALL COORDENADAS_LADO_SUPERIOR
        CALL COORDENADAS_LADO_INFERIOR
        CALL COORDENADAS_CENTRO

        CMP CLICK_SUPERIOR_IZQUIERDA, 1
        JE CLICK_EN_SUPERIOR_IZQUIERDA 
        CMP CLICK_LADO_IZQUIERDO, 1
        JE CLICK_EN_LADO_IZQUIERDO
        CMP CLICK_INFERIOR_IZQUIERDA, 1
        JE CLICK_EN_INFERIOR_IZQUIERDA
        JE CLICK_EN_LADO_IZQUIERDO

        CMP CLICK_SUPERIOR_DERECHA, 1
        JE CLICK_EN_SUPERIOR_DERECHA
        CMP CLICK_LADO_DERECHO, 1
        JE CLICK_EN_LADO_DERECHO
        CMP CLICK_INFERIOR_DERECHA, 1
        JE CLICK_EN_INFERIOR_DERECHA

        CMP CLICK_LADO_SUPERIOR, 1
        JE CLICK_EN_LADO_SUPERIOR
        CMP CLICK_LADO_INFERIOR, 1
        JE CLICK_EN_LADO_INFERIOR
        CMP CLICK_CENTRO, 1
        JE CLICK_EN_CENTRO

        JMP DETECTAR_CLICK

    CLICK_EN_SUPERIOR_IZQUIERDA:
        MOV AX, 02H
        INT 33H
        CALL RELLENEAR_CUADRO ;<----------------------------------------------------
        MOV AX, 01H
        INT 33H
        JMP DETECTAR_CLICK    
    CLICK_EN_LADO_IZQUIERDO:
        ;CALL TERMINAR_PROGRAMA
        JMP DETECTAR_CLICK 
    CLICK_EN_INFERIOR_IZQUIERDA:
        ;CALL TERMINAR_PROGRAMA
        JMP DETECTAR_CLICK 
    CLICK_EN_SUPERIOR_DERECHA:
        ;CALL TERMINAR_PROGRAMA
        JMP DETECTAR_CLICK 
    CLICK_EN_LADO_DERECHO:
        ;CALL TERMINAR_PROGRAMA
        JMP DETECTAR_CLICK 
    CLICK_EN_INFERIOR_DERECHA:
        ;CALL TERMINAR_PROGRAMA
        JMP DETECTAR_CLICK 
    CLICK_EN_LADO_SUPERIOR:
        ;CALL TERMINAR_PROGRAMA
        JMP DETECTAR_CLICK 
    CLICK_EN_LADO_INFERIOR:
        ;CALL TERMINAR_PROGRAMA
        JMP DETECTAR_CLICK 
    CLICK_EN_CENTRO:
        CALL TERMINAR_PROGRAMA
        JMP DETECTAR_CLICK            
               
DETECTAR_CLICK ENDP

COORDENADAS_SUPERIOR_IZQUIERDA PROC
    MOV CLICK_SUPERIOR_IZQUIERDA, 1
    CMP CX, 19 ;3
    JL SALIR_SUP_IZQ
    CMP CX, 221 ;1
    JG SALIR_SUP_IZQ
    CMP DX, 39 ;4
    JL SALIR_SUP_IZQ
    CMP DX, 123 ;2
    JG SALIR_SUP_IZQ
    RET

    SALIR_SUP_IZQ:
        MOV CLICK_SUPERIOR_IZQUIERDA, 0
        RET
COORDENADAS_SUPERIOR_IZQUIERDA ENDP

COORDENADAS_LADO_IZQUIERDO PROC
    MOV CLICK_LADO_IZQUIERDO, 1
    CMP CX, 19
    JL SALIR_LAD_IZQ
    CMP CX, 221
    JG SALIR_LAD_IZQ
    CMP DX, 103
    JL SALIR_LAD_IZQ
    CMP DX,207
    JG SALIR_LAD_IZQ
    RET

    SALIR_LAD_IZQ:
        MOV CLICK_LADO_IZQUIERDO, 0
        RET
COORDENADAS_LADO_IZQUIERDO ENDP

COORDENADAS_INFERIOR_IZQUIERDA PROC
    MOV CLICK_INFERIOR_IZQUIERDA, 1
    CMP CX, 19
    JL SALIR_INF_IZQ
    CMP CX, 221
    JG SALIR_INF_IZQ
    CMP DX, 207
    JL SALIR_INF_IZQ
    CMP DX,291
    JG SALIR_INF_IZQ
    RET

    SALIR_INF_IZQ:
        MOV CLICK_INFERIOR_IZQUIERDA, 0
        RET
COORDENADAS_INFERIOR_IZQUIERDA ENDP

COORDENADAS_SUPERIOR_DERECHA PROC
    MOV CLICK_SUPERIOR_DERECHA, 1
    CMP CX, 419
    JL SALIR_SUP_DER
    CMP CX, 621
    JG SALIR_SUP_DER
    CMP DX, 39
    JL SALIR_SUP_DER
    CMP DX, 123
    JG SALIR_SUP_DER
    RET

    SALIR_SUP_DER:
        MOV CLICK_SUPERIOR_DERECHA, 0
        RET
COORDENADAS_SUPERIOR_DERECHA ENDP

COORDENADAS_LADO_DERECHO PROC
    MOV CLICK_LADO_DERECHO, 1
    CMP CX, 419
    JL SALIR_LAD_DER
    CMP CX, 621
    JG SALIR_LAD_DER
    CMP DX, 103
    JL SALIR_LAD_DER
    CMP DX, 207
    JG SALIR_LAD_DER
    RET

    SALIR_LAD_DER:
        MOV CLICK_LADO_DERECHO, 0
        RET
COORDENADAS_LADO_DERECHO ENDP

COORDENADAS_INFERIOR_DERECHA PROC
    MOV CLICK_INFERIOR_DERECHA, 1
    CMP CX, 419
    JL SALIR_INF_DER
    CMP CX, 621
    JG SALIR_INF_DER
    CMP DX, 207
    JL SALIR_INF_DER
    CMP DX, 291
    JG SALIR_INF_DER
    RET

    SALIR_INF_DER:
        MOV CLICK_INFERIOR_DERECHA, 0
        RET
COORDENADAS_INFERIOR_DERECHA ENDP

COORDENADAS_LADO_SUPERIOR PROC
    MOV CLICK_LADO_SUPERIOR, 1
    CMP CX, 219
    JL SALIR_LAD_SUP
    CMP CX, 421
    JG SALIR_LAD_SUP
    CMP DX, 39
    JL SALIR_LAD_SUP
    CMP DX, 123
    JG SALIR_LAD_SUP
    RET

    SALIR_LAD_SUP:
        MOV CLICK_LADO_SUPERIOR, 0
        RET
COORDENADAS_LADO_SUPERIOR ENDP

COORDENADAS_LADO_INFERIOR PROC
    MOV CLICK_LADO_INFERIOR, 1
    CMP CX, 219
    JL SALIR_LAD_INF
    CMP CX, 421
    JG SALIR_LAD_INF
    CMP DX, 207
    JL SALIR_LAD_INF
    CMP DX, 331
    JG SALIR_LAD_INF
    RET

    SALIR_LAD_INF:
        MOV CLICK_LADO_INFERIOR, 0
        RET
COORDENADAS_LADO_INFERIOR ENDP

COORDENADAS_CENTRO PROC
    MOV CLICK_CENTRO, 1
    CMP CX, 219
    JL SALIR_CENTRO
    CMP CX, 421
    JG SALIR_CENTRO
    CMP DX, 123
    JL SALIR_CENTRO
    CMP DX, 292
    JG SALIR_CENTRO
    RET

    SALIR_CENTRO:
        MOV CLICK_CENTRO, 0
        RET
COORDENADAS_CENTRO ENDP

DIBUJAR_GUI PROC
    MOV COLOR_PIXEL, 07H
    
    MOV POSX, 20
    MOV POSY, 40
    JMP ESQUINA_SUPERIOR_IZQUIERDA_1

    ESQUINA_SUPERIOR_IZQUIERDA_1:
        CMP POSX, 220
        JE ESQUINA_SUPERIOR_IZQUIERDA_2
        CALL PRINT_PIXEL
        INC POSX
        JMP ESQUINA_SUPERIOR_IZQUIERDA_1
    ESQUINA_SUPERIOR_IZQUIERDA_2:
        CMP POSY, 124
        JE ESQUINA_SUPERIOR_IZQUIERDA_3
        CALL PRINT_PIXEL
        INC POSY
        JMP ESQUINA_SUPERIOR_IZQUIERDA_2
    ESQUINA_SUPERIOR_IZQUIERDA_3:
        CMP POSX, 20
        JE ESQUINA_SUPERIOR_IZQUIERDA_4
        CALL PRINT_PIXEL
        DEC POSX
        JMP ESQUINA_SUPERIOR_IZQUIERDA_3
    ESQUINA_SUPERIOR_IZQUIERDA_4:
        CMP POSY, 40
        JE LADO_IZQUIERDO
        CALL PRINT_PIXEL
        DEC POSY
        JMP ESQUINA_SUPERIOR_IZQUIERDA_4
;------------------------------------------        
        LADO_IZQUIERDO:
        MOV POSX, 20
        MOV POSY, 124
        JMP LADO_IZQUIERDO_1

    LADO_IZQUIERDO_1:
        CMP POSX, 220
        JE LADO_IZQUIERDO_2
        CALL PRINT_PIXEL
        INC POSX
        JMP LADO_IZQUIERDO_1
    LADO_IZQUIERDO_2:
        CMP POSY, 208
        JE LADO_IZQUIERDO_3
        CALL PRINT_PIXEL
        INC POSY
        JMP LADO_IZQUIERDO_2
    LADO_IZQUIERDO_3:
        CMP POSX, 20
        JE LADO_IZQUIERDO_4
        CALL PRINT_PIXEL
        DEC POSX
        JMP LADO_IZQUIERDO_3
    LADO_IZQUIERDO_4:
        CMP POSY, 104
        JE ESQUINA_INFERIOR_IZQUIERDA
        CALL PRINT_PIXEL
        DEC POSY
        JMP LADO_IZQUIERDO_4
;------------------------------------------
    ESQUINA_INFERIOR_IZQUIERDA:
        MOV POSX, 20
        MOV POSY, 208
        JMP ESQUINA_INFERIOR_IZQUIERDA_1

    ESQUINA_INFERIOR_IZQUIERDA_1:
        CMP POSX, 220
        JE ESQUINA_INFERIOR_IZQUIERDA_2
        CALL PRINT_PIXEL
        INC POSX
        JMP ESQUINA_INFERIOR_IZQUIERDA_1
    ESQUINA_INFERIOR_IZQUIERDA_2:
        CMP POSY, 292
        JE ESQUINA_INFERIOR_IZQUIERDA_3
        CALL PRINT_PIXEL
        INC POSY
        JMP ESQUINA_INFERIOR_IZQUIERDA_2
    ESQUINA_INFERIOR_IZQUIERDA_3:
        CMP POSX, 20
        JE ESQUINA_INFERIOR_IZQUIERDA_4
        CALL PRINT_PIXEL
        DEC POSX
        JMP ESQUINA_INFERIOR_IZQUIERDA_3
    ESQUINA_INFERIOR_IZQUIERDA_4:
        CMP POSY, 208
        JE ESQUINA_INFERIOR_DERECHA
        CALL PRINT_PIXEL
        DEC POSY
        JMP ESQUINA_INFERIOR_IZQUIERDA_4
;------------------------------------------
    ESQUINA_INFERIOR_DERECHA:
        MOV POSX, 420
        MOV POSY, 208
        JMP ESQUINA_INFERIOR_DERECHA_1

    ESQUINA_INFERIOR_DERECHA_1:
        CMP POSX, 620
        JE ESQUINA_INFERIOR_DERECHA_2
        CALL PRINT_PIXEL
        INC POSX
        JMP ESQUINA_INFERIOR_DERECHA_1
    ESQUINA_INFERIOR_DERECHA_2:
        CMP POSY, 292
        JE ESQUINA_INFERIOR_DERECHA_3
        CALL PRINT_PIXEL
        INC POSY
        JMP ESQUINA_INFERIOR_DERECHA_2
    ESQUINA_INFERIOR_DERECHA_3:
        CMP POSX, 420
        JE ESQUINA_INFERIOR_DERECHA_4
        CALL PRINT_PIXEL
        DEC POSX
        JMP ESQUINA_INFERIOR_DERECHA_3
    ESQUINA_INFERIOR_DERECHA_4:
        CMP POSY, 208
        JE ESQUINA_SUPERIOR_DERECHA
        CALL PRINT_PIXEL
        DEC POSY
        JMP ESQUINA_INFERIOR_DERECHA_4
;------------------------------------------
    ESQUINA_SUPERIOR_DERECHA:
        MOV POSX, 420
        MOV POSY, 40
        JMP ESQUINA_SUPERIOR_DERECHA_1

    ESQUINA_SUPERIOR_DERECHA_1:
        CMP POSX, 620
        JE ESQUINA_SUPERIOR_DERECHA_2
        CALL PRINT_PIXEL
        INC POSX
        JMP ESQUINA_SUPERIOR_DERECHA_1
    ESQUINA_SUPERIOR_DERECHA_2:
        CMP POSY, 124
        JE ESQUINA_SUPERIOR_DERECHA_3
        CALL PRINT_PIXEL
        INC POSY
        JMP ESQUINA_SUPERIOR_DERECHA_2
    ESQUINA_SUPERIOR_DERECHA_3:
        CMP POSX, 420
        JE ESQUINA_SUPERIOR_DERECHA_4
        CALL PRINT_PIXEL
        DEC POSX
        JMP ESQUINA_SUPERIOR_DERECHA_3
    ESQUINA_SUPERIOR_DERECHA_4:
        CMP POSY, 40
        JE LADO_DERECHO
        CALL PRINT_PIXEL
        DEC POSY
        JMP ESQUINA_SUPERIOR_DERECHA_4
;------------------------------------------
    LADO_DERECHO:
        MOV POSX, 420
        MOV POSY, 124
        JMP LADO_DERECHO_1

    LADO_DERECHO_1:
        CMP POSX, 620
        JE LADO_DERECHO_2
        CALL PRINT_PIXEL
        INC POSX
        JMP LADO_DERECHO_1
    LADO_DERECHO_2:
        CMP POSY, 208
        JE LADO_DERECHO_3
        CALL PRINT_PIXEL
        INC POSY
        JMP LADO_DERECHO_2
    LADO_DERECHO_3:
        CMP POSX, 420
        JE LADO_DERECHO_4
        CALL PRINT_PIXEL
        DEC POSX
        JMP LADO_DERECHO_3
    LADO_DERECHO_4:
        CMP POSY, 104
        JE  LADO_SUPERIOR
        CALL PRINT_PIXEL
        DEC POSY
        JMP LADO_DERECHO_4
;------------------------------------------
    LADO_SUPERIOR:
        MOV POSX, 220
        MOV POSY, 40
        JMP LADO_SUPERIOR_1

    LADO_SUPERIOR_1:
        CMP POSX, 420
        JE LADO_SUPERIOR_2
        CALL PRINT_PIXEL
        INC POSX
        JMP LADO_SUPERIOR_1
    LADO_SUPERIOR_2:
        CMP POSY, 124
        JE LADO_SUPERIOR_3
        CALL PRINT_PIXEL
        INC POSY
        JMP LADO_SUPERIOR_2
    LADO_SUPERIOR_3:
        CMP POSX, 220
        JE LADO_SUPERIOR_4
        CALL PRINT_PIXEL
        DEC POSX
        JMP LADO_SUPERIOR_3
    LADO_SUPERIOR_4:
        CMP POSY, 40
        JE LADO_INFERIOR
        CALL PRINT_PIXEL
        DEC POSY
        JMP LADO_SUPERIOR_4
    ;------------------------------------------
    LADO_INFERIOR:
        MOV POSX, 220
        MOV POSY, 208
        JMP LADO_INFERIOR_1

    LADO_INFERIOR_1:
        CMP POSX, 420
        JE LADO_INFERIOR_2
        CALL PRINT_PIXEL
        INC POSX
        JMP LADO_INFERIOR_1
    LADO_INFERIOR_2:
        CMP POSY, 292
        JE LADO_INFERIOR_3
        CALL PRINT_PIXEL
        INC POSY
        JMP LADO_INFERIOR_2
    LADO_INFERIOR_3:
        CMP POSX, 220
        JE LADO_INFERIOR_4
        CALL PRINT_PIXEL
        DEC POSX
        JMP LADO_INFERIOR_3
    LADO_INFERIOR_4:
        CMP POSY, 208
        JE TERMINAR
        CALL PRINT_PIXEL
        DEC POSY
        JMP LADO_INFERIOR_4
    TERMINAR:
        
        MOV COLOR_PIXEL, 01H
        RET
DIBUJAR_GUI ENDP

RELLENEAR_CUADRO PROC
    DIBUJAR_COLORES_DISPONIBLES:
        MOV POSX, 20
        MOV POSY, 40
        MOV COLOR_LIMITE_ARRIBA, 40  
        MOV COLOR_LIMITE_ABAJO, 124

        JMP DIBUJAR_COLOR_CICLO

        DIBUJAR_COLOR_CICLO: 
            MOV COLOR_PIXEL, 07H
            JMP DIBUJAR_COLOR

            TERMINAR_DIBUJO:
                JMP TERMINAR_RELLENO
            
            DIBUJAR_COLOR: 
                MOV DX, COLOR_LIMITE_ABAJO
                ADD DX, 1
                CMP POSY, DX
                JE DIBUJAR_SIGUIENTE_COLOR_INRANGE
                MOV DX, COLOR_LIMITE_ARRIBA
                CMP POSY, DX
                JE COLOR_BORDE
                MOV DX, COLOR_LIMITE_ABAJO
                CMP POSY, DX
                JE COLOR_BORDE
                CMP POSX, 20
                JE COLOR_BORDE
                CMP POSX, 220
                JE COLOR_BORDE
                JMP RELLENO_COLOR_1

                DIBUJAR_SIGUIENTE_COLOR_INRANGE:
                    JMP DIBUJAR_SIGUIENTE_COLOR

                COLOR_BORDE:
                    MOV COLOR_PIXEL, 07H
                    CALL PRINT_PIXEL
                    INC POSX
                    CMP POSX, 221
                    JE SIGUIENTE_LINEA_RELLENO
                    JMP DIBUJAR_COLOR
                    
                    SIGUIENTE_LINEA_RELLENO:
                        MOV POSX, 20
                        ADD POSY, 1
                        JMP DIBUJAR_COLOR

                    RELLENO_COLOR_1:
                       MOV DH, CL_ROJO
                        MOV COLOR_PIXEL, DH
                        JMP APLICAR_RELLENADO

                    APLICAR_RELLENADO:
                        CALL PRINT_PIXEL
                        INC POSX
                        JMP DIBUJAR_COLOR

            DIBUJAR_SIGUIENTE_COLOR:
                JMP TERMINAR_RELLENO
    TERMINAR_RELLENO: 
        MOV COLOR_PIXEL, 01H
        RET
RELLENEAR_CUADRO ENDP

PRINT_PIXEL PROC
    MOV AH, 0CH                     ; PARA IMPRIMIR UN PIXEL EN PANTALLA GRAFICA
    MOV AL, COLOR_PIXEL             ; SE DEFINE EL COLOR DEL PIXEL
    MOV CX, POSX                    ; SE DEFINE LA POSICION X DONDE SE UBICARA EL PIXEL
    MOV DX, POSY                    ; SE DEFINE LA POSICION Y DONDE SE UBICARA EL PIXEL
    MOV BH, 0                     
    INT 10H                  
    RET
PRINT_PIXEL ENDP

MUESTRA_MOUSE PROC
    ;LIMPIA EL MOUSE
	MOV AX, 0000H
	INT 33H
	;MUESTRA EL MOUSE
	MOV AX, 0001H
    INT 33H
    RET
MUESTRA_MOUSE ENDP

LIMPIAR_PANTALLA PROC
    MOV AH, 00H                     ; INICIA MODO VIDEO
    MOV AL, 10H                     ; 640 * 350
    INT 10H
    
    MOV AH, 0BH                     ; CAMBIA COLOR DE FONDO
    MOV BH, 00
    MOV BL, 08
    INT 10H
    
    RET
LIMPIAR_PANTALLA ENDP



MENU_INICIAL PROC
    POS_CURSOR 10,38 
    MOV AH, 09H
	LEA DX, MSG_JUGAR
	INT 21H

    POS_CURSOR 16,34 
    MOV AH, 09H
	LEA DX, MSG_CARGAR
	INT 21H

    MOV COLOR_PIXEL, 07H
    MOV POSX, 260
    MOV POSY, 125
    JMP JUGAR_1

    JUGAR_1:
        CMP POSX, 390
        JE JUGAR_2
        CALL PRINT_PIXEL
        INC POSX
        JMP JUGAR_1
    JUGAR_2:
        CMP POSY, 165
        JE JUGAR_3
        CALL PRINT_PIXEL
        INC POSY
        JMP JUGAR_2
    JUGAR_3:
        CMP POSX, 260
        JE JUGAR_4
        CALL PRINT_PIXEL
        DEC POSX
        JMP JUGAR_3
    JUGAR_4:
        CMP POSY, 125
        JE CARGAR
        CALL PRINT_PIXEL
        DEC POSY
        JMP JUGAR_4

   CARGAR:
        MOV POSX, 260
        MOV POSY, 210
        JMP CARGAR_1

    CARGAR_1:
        CMP POSX, 390
        JE CARGAR_2
        CALL PRINT_PIXEL
        INC POSX
        JMP CARGAR_1
    CARGAR_2:
        CMP POSY, 250
        JE CARGAR_3
        CALL PRINT_PIXEL
        INC POSY
        JMP CARGAR_2
    CARGAR_3:
        CMP POSX, 260
        JE CARGAR_4
        CALL PRINT_PIXEL
        DEC POSX
        JMP CARGAR_3
    CARGAR_4:
        CMP POSY, 210
        JE MENU_DIB_BUCLE
        CALL PRINT_PIXEL
        DEC POSY
        JMP CARGAR_4

    MENU_DIB_BUCLE:
    CALL DETECTAR_CLICK_MENU
    CMP CLICK_JUGAR, 1
    JE TERMINAR_MENU_DIB 
    CMP CLICK_CARGAR, 1
    JE TERMINAR_MENU_DIB 

    JMP MENU_DIB_BUCLE

    TERMINAR_MENU_DIB: 
        MOV COLOR_PIXEL, 01H
        CALL LIMPIAR_PANTALLA
        RET
MENU_INICIAL ENDP
    
DETECTAR_CLICK_MENU PROC
    MOV AX, 03H                 ; PARA DETECTAR CUANDO SE SUELTA EL CLICK
    INT 33h                     ; SE LLAMA LA INTERRUPCION DEL MOUSE     
    CMP BX, 1                   ; LA INTERRUPCION DEVUELVE EN BX LA CANTIDAD DE VECES QUE SE SOLTO, ENTONCES COMPARO CON 1
    JE COMPARAR_COORDENADAS_MENU     ; SI SE PRESIONO AL MENOS UNA VEZ, SALTA A CLICK_IZQUIERDO
    JNE DETECTAR_CLICK_MENU

    COMPARAR_COORDENADAS_MENU:
        CALL COORDENADAS_JUGAR
        CALL COORDENADAS_CARGAR

        CMP CLICK_JUGAR, 1
        JE TERMINA_CLICK_MENU 
        CMP CLICK_CARGAR, 1
        JE TERMINA_CLICK_MENU 

        JMP DETECTAR_CLICK_MENU

    TERMINA_CLICK_MENU:
        RET
DETECTAR_CLICK_MENU ENDP

COORDENADAS_JUGAR PROC
    MOV CLICK_JUGAR, 1
    CMP CX, 259
    JL SALIR_COR_JUGAR
    CMP CX, 391
    JG SALIR_COR_JUGAR
    CMP DX, 124
    JL SALIR_COR_JUGAR
    CMP DX, 164
    JG SALIR_COR_JUGAR
    RET

    SALIR_COR_JUGAR:
        MOV CLICK_JUGAR, 0
        RET
COORDENADAS_JUGAR ENDP

COORDENADAS_CARGAR PROC
    MOV CLICK_CARGAR, 1
    CMP CX, 259
    JL SALIR_COR_CARGAR
    CMP CX, 391
    JG SALIR_COR_CARGAR
    CMP DX, 209
    JL SALIR_COR_CARGAR
    CMP DX, 249
    JG SALIR_COR_CARGAR
    RET

    SALIR_COR_CARGAR:
        MOV CLICK_CARGAR, 0
        RET
COORDENADAS_CARGAR ENDP

TERMINAR_PROGRAMA PROC
    CALL LIMPIAR_PANTALLA
    POS_CURSOR 12,25 
    ;MENSAJE FINAL
    MOV AH, 09H
	LEA DX, MSG_PROGRAMA_FINALIZADO
	INT 21H
    ;FINALIZA
    MOV AH, 4CH
    INT 21H
TERMINAR_PROGRAMA ENDP
END
;------------------------
;FINAL SEGMENTO DE CODIGO
;------------------------