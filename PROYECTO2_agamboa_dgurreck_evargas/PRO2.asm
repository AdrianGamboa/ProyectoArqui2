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
    MSG_GUARDAR DB "GUARDAR PARTIDA ", '$'
    MSG_REINICIAR DB "REINICIAR PARTIDA ", '$'
    MSG_SALIR DB "SALIR PARTIDA ", '$'

    MSG_INSTRUCCIONES_COLOR DB "SELECCIONE EL COLOR DE LOS JUGADORES PARA INICIAR ", '$'
    MSG_COLOR1 DB "COLOR JUGADOR 1: 1 = ROJO , 2 = AMARILLO , 3 = BLANCO ", '$'
    MSG_COLOR2 DB "COLOR JUGADOR 2: 4 = ROSADO , 5 = AZUL , 6 = VERDE ", '$'
   
    MSG_GANADOR1 DB "HA GANADO EL JUGADOR 1: ", '$'
    MSG_GANADOR2 DB "HA GANADO EL JUGADOR 2: ", '$'
    MSG_EMPATE DB "HA SIDO UN EMPATE ", '$'

    MSG_PUNTOS_JUG1 DB "PUNTOS JUGADOR 1: ", '$'
    MSG_PUNTOS_JUG2 DB "PUNTOS JUGADOR 2: ", '$'

     ISCLICK DB 0
    NAMEPAR LABEL BYTE
    MAXNLEN DB 20
    NAMELEN DB ?
    NAMEFLD1 DB 21 DUP(' ')
    PROMPT1 DB 'Jugador 1: ', '$'
    NAMEJUGA1 DB 21 DUP(' '), '$'
    NAMEJUGA2 DB 21 DUP(' '), '$'
    PROMPT2 DB 'Jugador 2: ', '$'
    
    WORDA DW 3000 
    WORDB DW 4000 
    POSX DW 15
    POSY DW 15
    COLOR_PIXEL DB 01H

    MSG_TURNO DB "Turno: ", '$'
    LIMPIA_TEXTO DB "          ", '$'

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
    CLICK_GUARDAR DB 0
    CLICK_REINICIAR DB 0
    CLICK_SALIR DB 0

    COLOR_LIMITE_ARRIBA DW 0  ; LIMITE DE ARRIBA PARA EL RELLENO
    COLOR_LIMITE_ABAJO DW 0 ; LIMITE DE ABAJO PARA EL RELLENO

    COLOR1_SELECCIONADO DB 0
    COLOR2_SELECCIONADO DB 0

    TURNO_JUGADOR DW 0
    PUNTOS_JUGADOR1 DB 0
    PUNTOS_JUGADOR2 DB 0

    FIN_PARTIDA DB 0
    ;PARA SABER QUÉ CUADROS ESTÁN PINTADOS
    SUPERIOR_IZQUIERDA_PINTADO DB 0
    LADO_IZQUIERDO_PINTADO DB 0
    INFERIOR_IZQUIERDA_PINTADO DB 0

    LADO_SUPERIOR_PINTADO DB 0
    CENTRAL_PINTADO DB 0
    LADO_INFERIOR_PINTADO DB 0

    SUPERIOR_DERECHA_PINTADO DB 0
    LADO_DERECHO_PINTADO DB 0
    INFERIOR_DERECHA_PINTADO DB 0

    CUADROS_PINTADOS DB 0
    CAMBIO_DE_TURNO DB 0
    GANADOR DB 0
;-------------
    ; PALETA DE COLORES
    CL_ROSADO DB 0DH;
    CL_AZUL DB 01H
    CL_VERDE DB 0AH
    CL_ROJO DB 04H ;
    CL_MARRON DB 0CH
    CL_AMARILLO DB 0EH;
    CL_BLANCO DB 0FH;

    COLOR_JUGADOR1 DB 04H
    COLOR_JUGADOR2 DB 01H
    COLOR_RELLENO DB 0AH
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

    INICIO:
        CALL LIMPIAR_PANTALLA
        
        ;MOSTRAR CURSOR
        MOV AX, 01H
        INT 33H

        CALL MENU_INICIAL

        CALL RESTAURA_MOUSE

        CALL DETECTAR_TECLAS


        CALL OBTENER_NOMBRE

        CALL DIBUJAR_GUI

        CALL DETECTAR_CLICK
        
        CMP CLICK_SALIR, 1
        JE INICIO

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

    CALL BUSCAR_GANADOR
    CMP GANADOR, 1
    JE FINISH
    CMP CUADROS_PINTADOS, 9
    JE FINISH
    JNE INI_CLICK   

    FINISH:
        CALL DETERMINA_GANADOR
        INC FIN_PARTIDA

    INI_CLICK:
        
        MOV AX, 03H                 ; PARA DETECTAR CUANDO SE SUELTA EL CLICK
        INT 33h                     ; SE LLAMA LA INTERRUPCION DEL MOUSE                       
        CMP BX, 1                   ; LA INTERRUPCION DEVUELVE EN BX LA CANTIDAD DE VECES QUE SE SOLTO, ENTONCES COMPARO CON 1                   
        JNL COMPARAR_COORDENADAS    ; SI SE PRESIONO AL MENOS UNA VEZ, SALTA A CLICK_IZQUIERDO
        CMP FIN_PARTIDA,1
        JE INI_CLICK
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

        CALL COORDENADAS_GUARDAR
        CALL COORDENADAS_REINICIAR
        CALL COORDENADAS_SALIR

        JMP SIG1
        
        DETECTAR_CLICK_AUX0:
            CMP FIN_PARTIDA,1
            JE INI_CLICK
            JNE DETECTAR_CLICK

        SIG1:
            CMP CLICK_SUPERIOR_IZQUIERDA, 1
            JNE SIG2
            CLICK_EN_SUPERIOR_IZQUIERDA:
                CMP SUPERIOR_IZQUIERDA_PINTADO, 1
                JE DETECTAR_CLICK_AUX0
                CMP SUPERIOR_IZQUIERDA_PINTADO, 2
                JE DETECTAR_CLICK_AUX0
                MOV AX, 02H
                INT 33H
                CALL RELLENEAR_CUADRO_SUPERIOR_IZQUIERDA
                INC CUADROS_PINTADOS
                CALL TURNO_DEL_JUGADOR
                MOV AX, 01H
                INT 33H
                JMP DETECTAR_CLICK_AUX0  
        SIG2:
            CMP CLICK_LADO_IZQUIERDO, 1
            JNE SIG3
            CLICK_EN_LADO_IZQUIERDO:
                CMP LADO_IZQUIERDO_PINTADO, 1
                JE DETECTAR_CLICK_AUX0
                CMP LADO_IZQUIERDO_PINTADO, 2
                JE DETECTAR_CLICK_AUX0
                MOV AX, 02H
                INT 33H
                CALL RELLENEAR_CUADRO_LADO_IZQUIERDO
                INC CUADROS_PINTADOS
               CALL TURNO_DEL_JUGADOR
                MOV AX, 01H
                INT 33H
                JMP DETECTAR_CLICK_AUX0 
        SIG3:
            CMP CLICK_INFERIOR_IZQUIERDA, 1
            JNE SIG4
            CLICK_EN_INFERIOR_IZQUIERDA:
                CMP INFERIOR_IZQUIERDA_PINTADO, 1
                JE DETECTAR_CLICK_AUX0
                CMP INFERIOR_IZQUIERDA_PINTADO, 2
                JE DETECTAR_CLICK_AUX0
                MOV AX, 02H
                INT 33H
                CALL RELLENEAR_CUADRO_INFERIOR_IZQUIERDO
                INC CUADROS_PINTADOS
                CALL TURNO_DEL_JUGADOR
                MOV AX, 01H
                INT 33H
                JMP DETECTAR_CLICK_AUX0

        DETECTAR_CLICK_AUX1:
            JMP DETECTAR_CLICK_AUX0

        SIG4:
            CMP CLICK_SUPERIOR_DERECHA, 1
            JNE SIG5
            CLICK_EN_SUPERIOR_DERECHA:
                CMP SUPERIOR_DERECHA_PINTADO, 1
                JE DETECTAR_CLICK_AUX1
                CMP SUPERIOR_DERECHA_PINTADO, 2
                JE DETECTAR_CLICK_AUX1
                MOV AX, 02H
                INT 33H
                CALL RELLENEAR_CUADRO_SUPERIOR_DERECHA
                INC CUADROS_PINTADOS
                CALL TURNO_DEL_JUGADOR
                MOV AX, 01H
                INT 33H
                JMP DETECTAR_CLICK_AUX1  
        SIG5:    
            CMP CLICK_LADO_DERECHO, 1
            JNE SIG6
            CLICK_EN_LADO_DERECHO:
                CMP LADO_DERECHO_PINTADO, 1
                JE DETECTAR_CLICK_AUX1
                CMP LADO_DERECHO_PINTADO, 2
                JE DETECTAR_CLICK_AUX1
                MOV AX, 02H
                INT 33H
                CALL RELLENEAR_CUADRO_LADO_DERECHO
                INC CUADROS_PINTADOS
                CALL TURNO_DEL_JUGADOR
                MOV AX, 01H
                INT 33H
                JMP DETECTAR_CLICK_AUX1     

        SIG6:
            CMP CLICK_INFERIOR_DERECHA, 1
            JNE SIG7
            CLICK_EN_INFERIOR_DERECHA:
                CMP INFERIOR_DERECHA_PINTADO, 1
                JE DETECTAR_CLICK_AUX1
                CMP INFERIOR_DERECHA_PINTADO, 2
                JE DETECTAR_CLICK_AUX1
                MOV AX, 02H
                INT 33H
                CALL RELLENEAR_CUADRO_INFERIOR_DERECHA
                INC CUADROS_PINTADOS
                CALL TURNO_DEL_JUGADOR
                MOV AX, 01H
                INT 33H
                JMP DETECTAR_CLICK_AUX1  

        DETECTAR_CLICK_AUX2:
            JMP DETECTAR_CLICK_AUX1     

        SIG7:
            CMP CLICK_LADO_SUPERIOR, 1
            JNE SIG8
            CLICK_EN_LADO_SUPERIOR:
                CMP LADO_SUPERIOR_PINTADO, 1
                JE DETECTAR_CLICK_AUX2
                CMP LADO_SUPERIOR_PINTADO, 2
                JE DETECTAR_CLICK_AUX2
                MOV AX, 02H
                INT 33H
                CALL RELLENEAR_CUADRO_LADO_SUPERIOR
                INC CUADROS_PINTADOS
                CALL TURNO_DEL_JUGADOR
                MOV AX, 01H
                INT 33H
                JMP DETECTAR_CLICK_AUX2

        SIG8:
            CMP CLICK_LADO_INFERIOR, 1
            JNE SIG9
            CLICK_EN_LADO_INFERIOR:
                CMP LADO_INFERIOR_PINTADO, 1
                JE DETECTAR_CLICK_AUX2
                CMP LADO_INFERIOR_PINTADO, 2
                JE DETECTAR_CLICK_AUX2
                MOV AX, 02H
                INT 33H
                CALL RELLENEAR_CUADRO_LADO_INFERIOR
                INC CUADROS_PINTADOS
                CALL TURNO_DEL_JUGADOR
                MOV AX, 01H
                INT 33H
                JMP DETECTAR_CLICK_AUX2     
        SIG9:
            CMP CLICK_CENTRO, 1
            JNE SIG10  
            CLICK_EN_CENTRO:
                CMP CENTRAL_PINTADO, 1
                JE DETECTAR_CLICK_AUX2
                CMP CENTRAL_PINTADO, 2
                JE DETECTAR_CLICK_AUX2
                MOV AX, 02H
                INT 33H
                CALL RELLENEAR_CUADRO_CENTRAL
                INC CUADROS_PINTADOS
                CALL TURNO_DEL_JUGADOR
                MOV AX, 01H
                INT 33H
                JMP DETECTAR_CLICK_AUX2

        DETECTAR_CLICK_AUX3:
            JMP DETECTAR_CLICK_AUX2

        SIG10:
            CMP CLICK_GUARDAR, 1
            JNE SIG11
            CLICK_EN_GUARDAR:
                ;CALL TERMINAR_PROGRAMA    
                JMP DETECTAR_CLICK_AUX3
        SIG11:
            CMP CLICK_REINICIAR, 1
            JNE SIG12
            CLICK_EN_REINICIAR:
                CALL REINICIA_JUEGO
                JMP DETECTAR_CLICK_AUX3
        SIG12:
            CMP CLICK_SALIR, 1
            JNE DETECTAR_CLICK_AUX3
            CLICK_EN_SALIR:  
            RET
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

COORDENADAS_LADO_INFERIOR PROC ;C
    MOV CLICK_LADO_INFERIOR, 1
    CMP CX, 219
    JL SALIR_LAD_INF
    CMP CX, 421
    JG SALIR_LAD_INF
    CMP DX, 207
    JL SALIR_LAD_INF
    CMP DX, 291
    JG SALIR_LAD_INF
    RET

    SALIR_LAD_INF:
        MOV CLICK_LADO_INFERIOR, 0
        RET
COORDENADAS_LADO_INFERIOR ENDP

COORDENADAS_CENTRO PROC ; C
    MOV CLICK_CENTRO, 1
    CMP CX, 219
    JL SALIR_CENTRO
    CMP CX, 421
    JG SALIR_CENTRO
    CMP DX, 123
    JL SALIR_CENTRO
    CMP DX, 207
    JG SALIR_CENTRO
    RET

    SALIR_CENTRO:
        MOV CLICK_CENTRO, 0
        RET
COORDENADAS_CENTRO ENDP

COORDENADAS_GUARDAR PROC ; C
    MOV CLICK_GUARDAR, 1
    CMP CX, 23 
    JL SALIR_GUARDAR
    CMP CX, 217
    JG SALIR_GUARDAR
    CMP DX, 314 
    JL SALIR_GUARDAR
    CMP DX, 341 
    JG SALIR_GUARDAR
    RET

    SALIR_GUARDAR:
        MOV CLICK_GUARDAR, 0
        RET
COORDENADAS_GUARDAR ENDP

COORDENADAS_REINICIAR PROC ; C
    MOV CLICK_REINICIAR, 1
    CMP CX, 223 ;3
    JL SALIR_REINICIAR
    CMP CX, 415;1
    JG SALIR_REINICIAR
    CMP DX, 314 ;4
    JL SALIR_REINICIAR
    CMP DX, 341 ;2
    JG SALIR_REINICIAR
    RET
    SALIR_REINICIAR:
        MOV CLICK_REINICIAR, 0
        RET
COORDENADAS_REINICIAR ENDP

COORDENADAS_SALIR PROC ; C
    MOV CLICK_SALIR, 1
    CMP CX, 423 ;3
    JL SALIR_SALIR
    CMP CX, 615;1
    JG SALIR_SALIR
    CMP DX, 314 ;4
    JL SALIR_SALIR
    CMP DX, 341 ;2
    JG SALIR_SALIR
    RET
    SALIR_SALIR:
        MOV CLICK_SALIR, 0
        RET
COORDENADAS_SALIR ENDP

DIBUJAR_GUI PROC
    MOV AX, 02H
    INT 33H

    POS_CURSOR 21,54
    MOV AH, 09H
	LEA DX, MSG_TURNO
	INT 21H

    POS_CURSOR 23,7 
    MOV AH, 09H
	LEA DX, MSG_GUARDAR
	INT 21H
    POS_CURSOR 23,32
    MOV AH, 09H
	LEA DX, MSG_REINICIAR
	INT 21H
    POS_CURSOR 23,59 
    MOV AH, 09H
	LEA DX, MSG_SALIR
	INT 21H

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
        CMP POSY, 124
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
        JE BTNS_GAME
        CALL PRINT_PIXEL
        DEC POSY
        JMP LADO_INFERIOR_4
    ;------------------------------------------
    BTNS_GAME:
        CALL DIBUJAR_BTNS_GAME
    
    TERMINAR:
        CALL TURNO_DEL_JUGADOR
        MOV AX, 01H
        INT 33H
        MOV COLOR_PIXEL, 01H
        RET
DIBUJAR_GUI ENDP

DIBUJAR_BTNS_GAME PROC ; DIBUJO LOS BOTONES DEL TABLERO
    BTN_GUARDAR:
        MOV POSX, 24
        MOV POSY, 315
        JMP BTN_GUARDAR_1

    BTN_GUARDAR_1:
        CMP POSX, 216
        JE BTN_GUARDAR_2
        CALL PRINT_PIXEL
        INC POSX
        JMP BTN_GUARDAR_1
    BTN_GUARDAR_2:
        CMP POSY, 342
        JE BTN_GUARDAR_3
        CALL PRINT_PIXEL
        INC POSY
        JMP BTN_GUARDAR_2
    BTN_GUARDAR_3:
        CMP POSX, 24
        JE BTN_GUARDAR_4
        CALL PRINT_PIXEL
        DEC POSX
        JMP BTN_GUARDAR_3
    BTN_GUARDAR_4:
        CMP POSY, 315
        JE BTN_REINICIAR
        CALL PRINT_PIXEL
        DEC POSY
        JMP BTN_GUARDAR_4
    ;------------------------------------------
    BTN_REINICIAR:
        MOV POSX, 224
        MOV POSY, 315
        JMP BTN_REINICIAR_1

    BTN_REINICIAR_1:
        CMP POSX, 416
        JE BTN_REINICIAR_2
        CALL PRINT_PIXEL
        INC POSX
        JMP BTN_REINICIAR_1
    BTN_REINICIAR_2:
        CMP POSY, 342
        JE BTN_REINICIAR_3
        CALL PRINT_PIXEL
        INC POSY
        JMP BTN_REINICIAR_2
    BTN_REINICIAR_3:
        CMP POSX, 224
        JE BTN_REINICIAR_4
        CALL PRINT_PIXEL
        DEC POSX
        JMP BTN_REINICIAR_3
    BTN_REINICIAR_4:
        CMP POSY, 315
        JE BTN_SALIR
        CALL PRINT_PIXEL
        DEC POSY
        JMP BTN_REINICIAR_4
    ;------------------------------------------
    BTN_SALIR:
        MOV POSX, 424
        MOV POSY, 315
        JMP BTN_SALIR_1

    BTN_SALIR_1:
        CMP POSX, 616
        JE BTN_SALIR_2
        CALL PRINT_PIXEL
        INC POSX
        JMP BTN_SALIR_1
    BTN_SALIR_2:
        CMP POSY, 342
        JE BTN_SALIR_3
        CALL PRINT_PIXEL
        INC POSY
        JMP BTN_SALIR_2
    BTN_SALIR_3:
        CMP POSX, 424
        JE BTN_SALIR_4
        CALL PRINT_PIXEL
        DEC POSX
        JMP BTN_SALIR_3
    BTN_SALIR_4:
        CMP POSY, 315
        JE TERMINAR_BTNS
        CALL PRINT_PIXEL
        DEC POSY
        JMP BTN_SALIR_4

    TERMINAR_BTNS:
        RET
DIBUJAR_BTNS_GAME ENDP

REINICIA_JUEGO PROC
    CALL LIMPIAR_PANTALLA
    CALL DIBUJAR_GUI

    CMP FIN_PARTIDA, 0
    JE REINICIO_TOTAL
    JMP REINICIO

    REINICIO_TOTAL:
    MOV PUNTOS_JUGADOR2 , 0
    MOV PUNTOS_JUGADOR1 , 0
    MOV COLOR1_SELECCIONADO , 0
    MOV COLOR2_SELECCIONADO , 0

    REINICIO:

    MOV CLICK_SUPERIOR_IZQUIERDA , 0
    MOV CLICK_LADO_IZQUIERDO , 0
    MOV CLICK_INFERIOR_IZQUIERDA , 0
    MOV CLICK_SUPERIOR_DERECHA , 0
    MOV CLICK_LADO_DERECHO , 0
    MOV CLICK_INFERIOR_DERECHA , 0
    MOV CLICK_LADO_SUPERIOR , 0
    MOV CLICK_LADO_INFERIOR , 0
    MOV CLICK_CENTRO , 0

    MOV CLICK_GUARDAR , 0
    MOV CLICK_REINICIAR , 0
    MOV CLICK_SALIR , 0

    MOV TURNO_JUGADOR , 0

    MOV SUPERIOR_IZQUIERDA_PINTADO , 0
    MOV LADO_IZQUIERDO_PINTADO , 0
    MOV INFERIOR_IZQUIERDA_PINTADO , 0

    MOV LADO_SUPERIOR_PINTADO , 0
    MOV CENTRAL_PINTADO , 0
    MOV LADO_INFERIOR_PINTADO , 0

    MOV SUPERIOR_DERECHA_PINTADO , 0
    MOV LADO_DERECHO_PINTADO , 0
    MOV INFERIOR_DERECHA_PINTADO , 0

    MOV CUADROS_PINTADOS , 0
    MOV GANADOR , 0
    MOV FIN_PARTIDA, 0

    POS_CURSOR 1,16
    MOV AH, 09H
    LEA DX, PROMPT1
    INT 21H

    POS_CURSOR 1,27
    MOV AH, 09H
    LEA DX, NAMEJUGA1
    INT 21H

    POS_CURSOR 1,53
    MOV AH, 09H
    LEA DX, PROMPT2
    INT 21H

    POS_CURSOR 1,64
    MOV AH, 09H
    LEA DX, NAMEJUGA2
    INT 21H

    ;MOSTRAR CURSOR
    MOV AX, 01H
    INT 33H
    RET
REINICIA_JUEGO ENDP

RELLENEAR_CUADRO_SUPERIOR_IZQUIERDA PROC
        MOV POSX, 20
        MOV POSY, 40
        MOV COLOR_LIMITE_ARRIBA, 40  
        MOV COLOR_LIMITE_ABAJO, 124
        MOV COLOR_PIXEL, 07H
            
        DIBUJAR_SUP_IZQ: 
            MOV DX, COLOR_LIMITE_ABAJO
            ADD DX, 1
            CMP POSY, DX
            JE TERMINAR_RELLENO_SUP_IZQ
            MOV DX, COLOR_LIMITE_ARRIBA
            CMP POSY, DX
            JE BORDE_SUP_IZQ
            MOV DX, COLOR_LIMITE_ABAJO
            CMP POSY, DX
            JE BORDE_SUP_IZQ
            CMP POSX, 20
            JE BORDE_SUP_IZQ
            CMP POSX, 220
            JE BORDE_SUP_IZQ
            JMP RELLENO_SUP_IZQ

            BORDE_SUP_IZQ:
                MOV COLOR_PIXEL, 07H
                CALL PRINT_PIXEL
                INC POSX
                CMP POSX, 221
                JE SIGUIENTE_SUP_IZQ
                JMP DIBUJAR_SUP_IZQ
                
                SIGUIENTE_SUP_IZQ:
                    MOV POSX, 20
                    ADD POSY, 1
                    JMP DIBUJAR_SUP_IZQ

                RELLENO_SUP_IZQ:
                    CMP TURNO_JUGADOR, 0
                    JE JUG_1_SUP_IZQ
                    JMP JUG_2_SUP_IZQ
                JUG_1_SUP_IZQ:
                    MOV DH, COLOR_JUGADOR1
                    MOV COLOR_RELLENO, DH
                    JMP CONTINUA_RELLENO_SUP_IZQ
                JUG_2_SUP_IZQ:
                    MOV DH, COLOR_JUGADOR2
                    MOV COLOR_RELLENO, DH
                    
                    JMP CONTINUA_RELLENO_SUP_IZQ
                CONTINUA_RELLENO_SUP_IZQ:
                    MOV DH, COLOR_RELLENO
                    MOV COLOR_PIXEL, DH
                    JMP APLICAR_RELLENADO_SUP_IZQ

                APLICAR_RELLENADO_SUP_IZQ:
                    CALL PRINT_PIXEL
                    INC POSX
                    JMP DIBUJAR_SUP_IZQ

        TERMINAR_RELLENO_SUP_IZQ:
            CMP TURNO_JUGADOR, 0
            JE TURNO_JUG_1_SUP_IZQ
            JMP TURNO_JUG_2_SUP_IZQ

        TURNO_JUG_1_SUP_IZQ:
            INC TURNO_JUGADOR
            MOV SUPERIOR_IZQUIERDA_PINTADO, 1
            JMP FIN_RELLENO_SUP_IZQ
        TURNO_JUG_2_SUP_IZQ:
            DEC TURNO_JUGADOR
            MOV SUPERIOR_IZQUIERDA_PINTADO, 2
            JMP FIN_RELLENO_SUP_IZQ
        FIN_RELLENO_SUP_IZQ:
        MOV COLOR_PIXEL, 01H
        RET
RELLENEAR_CUADRO_SUPERIOR_IZQUIERDA ENDP

RELLENEAR_CUADRO_LADO_IZQUIERDO PROC
        
        MOV POSX, 20
        MOV POSY, 124
        MOV COLOR_LIMITE_ARRIBA, 124  
        MOV COLOR_LIMITE_ABAJO, 208
        MOV COLOR_PIXEL, 07H
    
        DIBUJAR_LAD_IZQ: 
            MOV DX, COLOR_LIMITE_ABAJO
            ADD DX, 1
            CMP POSY, DX
            JE TERMINAR_RELLENO_LAD_IZQ
            MOV DX, COLOR_LIMITE_ARRIBA
            CMP POSY, DX
            JE BORDE_LAD_IZQ
            MOV DX, COLOR_LIMITE_ABAJO
            CMP POSY, DX
            JE BORDE_LAD_IZQ
            CMP POSX, 20
            JE BORDE_LAD_IZQ
            CMP POSX, 220
            JE BORDE_LAD_IZQ
            JMP RELLENO_LAD_IZQ

                BORDE_LAD_IZQ:
                    MOV COLOR_PIXEL, 07H
                    CALL PRINT_PIXEL
                    INC POSX
                    CMP POSX, 221
                    JE SIGUIENTE_LAD_IZQ
                    JMP DIBUJAR_LAD_IZQ
                
                SIGUIENTE_LAD_IZQ:
                    MOV POSX, 20
                    ADD POSY, 1
                    JMP DIBUJAR_LAD_IZQ

                RELLENO_LAD_IZQ:
                    CMP TURNO_JUGADOR, 0
                    JE JUG_1_LAD_IZQ
                    JMP JUG_2_LAD_IZQ
                JUG_1_LAD_IZQ:
                    MOV DH, COLOR_JUGADOR1
                    MOV COLOR_RELLENO, DH
                    JMP CONTINUA_RELLENO_LAD_IZQ
                JUG_2_LAD_IZQ:
                    MOV DH, COLOR_JUGADOR2
                    MOV COLOR_RELLENO, DH
                    JMP CONTINUA_RELLENO_LAD_IZQ
                CONTINUA_RELLENO_LAD_IZQ:
                    MOV DH, COLOR_RELLENO
                    MOV COLOR_PIXEL, DH
                    JMP APLICAR_RELLENADO_LAD_IZQ

                APLICAR_RELLENADO_LAD_IZQ:
                    CALL PRINT_PIXEL
                    INC POSX
                    JMP DIBUJAR_LAD_IZQ

        TERMINAR_RELLENO_LAD_IZQ:
            CMP TURNO_JUGADOR, 0
            JE TURNO_JUG_1_LAD_IZQ
            JMP TURNO_JUG_2_LAD_IZQ
        TURNO_JUG_1_LAD_IZQ:
            INC TURNO_JUGADOR
            MOV LADO_IZQUIERDO_PINTADO, 1
            JMP FIN_RELLENO_LAD_IZQ
        TURNO_JUG_2_LAD_IZQ:
            DEC TURNO_JUGADOR
            MOV LADO_IZQUIERDO_PINTADO, 2
        FIN_RELLENO_LAD_IZQ:
        MOV COLOR_PIXEL, 01H
        RET
RELLENEAR_CUADRO_LADO_IZQUIERDO ENDP

RELLENEAR_CUADRO_INFERIOR_IZQUIERDO PROC
        
        MOV POSX, 20    ;INI
        MOV POSY, 208 ;INI
        MOV COLOR_LIMITE_ARRIBA, 208  ;INI Y
        MOV COLOR_LIMITE_ABAJO, 292; 2
        MOV COLOR_PIXEL, 07H
    
        DIBUJAR_INF_IZQ: 
            MOV DX, COLOR_LIMITE_ABAJO
            ADD DX, 1
            CMP POSY, DX
            JE TERMINAR_RELLENO_INF_IZQ
            MOV DX, COLOR_LIMITE_ARRIBA
            CMP POSY, DX
            JE BORDE_INF_IZQ
            MOV DX, COLOR_LIMITE_ABAJO
            CMP POSY, DX
            JE BORDE_INF_IZQ
            CMP POSX, 20 ;3
            JE BORDE_INF_IZQ
            CMP POSX, 220;1
            JE BORDE_INF_IZQ
            JMP RELLENO_INF_IZQ

                BORDE_INF_IZQ:
                    MOV COLOR_PIXEL, 07H
                    CALL PRINT_PIXEL
                    INC POSX
                    CMP POSX, 221;1
                    JE SIGUIENTE_INF_IZQ
                    JMP DIBUJAR_INF_IZQ
                
                SIGUIENTE_INF_IZQ:
                    MOV POSX, 20
                    ADD POSY, 1
                    JMP DIBUJAR_INF_IZQ

                RELLENO_INF_IZQ:
                    CMP TURNO_JUGADOR, 0
                    JE JUG_1_INF_IZQ
                    JMP JUG_2_INF_IZQ
                JUG_1_INF_IZQ:
                    MOV DH, COLOR_JUGADOR1
                    MOV COLOR_RELLENO, DH
                    JMP CONTINUA_RELLENO_INF_IZQ
                JUG_2_INF_IZQ:
                    MOV DH, COLOR_JUGADOR2
                    MOV COLOR_RELLENO, DH
                    JMP CONTINUA_RELLENO_INF_IZQ
                CONTINUA_RELLENO_INF_IZQ:
                    MOV DH, COLOR_RELLENO
                    MOV COLOR_PIXEL, DH
                    JMP APLICAR_RELLENADO_INF_IZQ

                APLICAR_RELLENADO_INF_IZQ:
                    CALL PRINT_PIXEL
                    INC POSX
                    JMP DIBUJAR_INF_IZQ

        TERMINAR_RELLENO_INF_IZQ:
            CMP TURNO_JUGADOR, 0
            JE TURNO_JUG_1_INF_IZQ
            JMP TURNO_JUG_2_INF_IZQ
        TURNO_JUG_1_INF_IZQ:
            INC TURNO_JUGADOR
            MOV INFERIOR_IZQUIERDA_PINTADO, 1
            JMP FIN_RELLENO_LAD_IZQ
        TURNO_JUG_2_INF_IZQ:
            DEC TURNO_JUGADOR
            MOV INFERIOR_IZQUIERDA_PINTADO, 2
        FIN_RELLENO_INF_IZQ:
        MOV COLOR_PIXEL, 01H
        RET
RELLENEAR_CUADRO_INFERIOR_IZQUIERDO ENDP

RELLENEAR_CUADRO_LADO_SUPERIOR PROC
        
        MOV POSX, 220    ;INI
        MOV POSY, 40 ;INI
        MOV COLOR_LIMITE_ARRIBA, 40  ;INI Y
        MOV COLOR_LIMITE_ABAJO, 124; 2
        MOV COLOR_PIXEL, 07H
    
        DIBUJAR_LAD_SUP: 
            MOV DX, COLOR_LIMITE_ABAJO
            ADD DX, 1
            CMP POSY, DX
            JE TERMINAR_RELLENO_LAD_SUP
            MOV DX, COLOR_LIMITE_ARRIBA
            CMP POSY, DX
            JE BORDE_LAD_SUP
            MOV DX, COLOR_LIMITE_ABAJO
            CMP POSY, DX
            JE BORDE_LAD_SUP
            CMP POSX, 220 ;3
            JE BORDE_LAD_SUP
            CMP POSX, 420;1
            JE BORDE_LAD_SUP
            JMP RELLENO_LAD_SUP

                BORDE_LAD_SUP:
                    MOV COLOR_PIXEL, 07H
                    CALL PRINT_PIXEL
                    INC POSX
                    CMP POSX, 421;1
                    JE SIGUIENTE_LAD_SUP
                    JMP DIBUJAR_LAD_SUP
                
                SIGUIENTE_LAD_SUP:
                    MOV POSX, 220;INI X
                    ADD POSY, 1
                    JMP DIBUJAR_LAD_SUP

                RELLENO_LAD_SUP:
                    CMP TURNO_JUGADOR, 0
                    JE JUG_1_LAD_SUP
                    JMP JUG_2_LAD_SUP
                JUG_1_LAD_SUP:
                    MOV DH, COLOR_JUGADOR1
                    MOV COLOR_RELLENO, DH
                    JMP CONTINUA_RELLENO_LAD_SUP
                JUG_2_LAD_SUP:
                    MOV DH, COLOR_JUGADOR2
                    MOV COLOR_RELLENO, DH
                    JMP CONTINUA_RELLENO_LAD_SUP
                CONTINUA_RELLENO_LAD_SUP:
                    MOV DH, COLOR_RELLENO
                    MOV COLOR_PIXEL, DH
                    JMP APLICAR_RELLENADO_LAD_SUP

                APLICAR_RELLENADO_LAD_SUP:
                    CALL PRINT_PIXEL
                    INC POSX
                    JMP DIBUJAR_LAD_SUP
                    
        TERMINAR_RELLENO_LAD_SUP:
            CMP TURNO_JUGADOR, 0
            JE TURNO_JUG_1_LAD_SUP
            JMP TURNO_JUG_2_LAD_SUP
        TURNO_JUG_1_LAD_SUP:
            INC TURNO_JUGADOR
            MOV LADO_SUPERIOR_PINTADO, 1         
            JMP FIN_RELLENO_LAD_IZQ
        TURNO_JUG_2_LAD_SUP:
            DEC TURNO_JUGADOR
            MOV LADO_SUPERIOR_PINTADO, 2
        FIN_RELLENO_LAD_SUP:
        MOV COLOR_PIXEL, 01H
        RET
RELLENEAR_CUADRO_LADO_SUPERIOR ENDP

RELLENEAR_CUADRO_CENTRAL PROC
        
        MOV POSX, 220    ;INI
        MOV POSY, 124 ;INI
        MOV COLOR_LIMITE_ARRIBA, 124  ;INI Y
        MOV COLOR_LIMITE_ABAJO, 208; 2
        MOV COLOR_PIXEL, 07H
    
        DIBUJAR_CENTRAL: 
            MOV DX, COLOR_LIMITE_ABAJO
            ADD DX, 1
            CMP POSY, DX
            JE TERMINAR_RELLENO_CENTRAL
            MOV DX, COLOR_LIMITE_ARRIBA
            CMP POSY, DX
            JE BORDE_CENTRAL
            MOV DX, COLOR_LIMITE_ABAJO
            CMP POSY, DX
            JE BORDE_CENTRAL
            CMP POSX, 220 ;3
            JE BORDE_CENTRAL
            CMP POSX, 420;1
            JE BORDE_CENTRAL
            JMP RELLENO_CENTRAL

                BORDE_CENTRAL:
                    MOV COLOR_PIXEL, 07H
                    CALL PRINT_PIXEL
                    INC POSX
                    CMP POSX, 421;1
                    JE SIGUIENTE_CENTRAL
                    JMP DIBUJAR_CENTRAL
                
                SIGUIENTE_CENTRAL:
                    MOV POSX, 220;INI X
                    ADD POSY, 1
                    JMP DIBUJAR_CENTRAL

                RELLENO_CENTRAL:
                    CMP TURNO_JUGADOR, 0
                    JE JUG_1_CENTRAL
                    JMP JUG_2_CENTRAL
                JUG_1_CENTRAL:
                    MOV DH, COLOR_JUGADOR1
                    MOV COLOR_RELLENO, DH
                    JMP CONTINUA_RELLENO_CENTRAL
                JUG_2_CENTRAL:
                    MOV DH, COLOR_JUGADOR2
                    MOV COLOR_RELLENO, DH
                    JMP CONTINUA_RELLENO_CENTRAL
                CONTINUA_RELLENO_CENTRAL:
                    MOV DH, COLOR_RELLENO
                    MOV COLOR_PIXEL, DH
                    JMP APLICAR_RELLENADO_CENTRAL

                APLICAR_RELLENADO_CENTRAL:
                    CALL PRINT_PIXEL
                    INC POSX
                    JMP DIBUJAR_CENTRAL
                    
        TERMINAR_RELLENO_CENTRAL:
            CMP TURNO_JUGADOR, 0
            JE TURNO_JUG_1_CENTRAL
            JMP TURNO_JUG_2_CENTRAL
        TURNO_JUG_1_CENTRAL:
            INC TURNO_JUGADOR
            MOV CENTRAL_PINTADO, 1         
            JMP FIN_RELLENO_LAD_IZQ
        TURNO_JUG_2_CENTRAL:
            DEC TURNO_JUGADOR
            MOV CENTRAL_PINTADO, 2
        FIN_RELLENO_CENTRAL:
        MOV COLOR_PIXEL, 01H
        RET
RELLENEAR_CUADRO_CENTRAL ENDP

RELLENEAR_CUADRO_LADO_INFERIOR PROC
        
        MOV POSX, 220    ;INI
        MOV POSY, 208 ;INI
        MOV COLOR_LIMITE_ARRIBA, 208  ;INI Y
        MOV COLOR_LIMITE_ABAJO, 292; 2
        MOV COLOR_PIXEL, 07H
    
        DIBUJAR_LAD_INF: 
            MOV DX, COLOR_LIMITE_ABAJO
            ADD DX, 1
            CMP POSY, DX
            JE TERMINAR_RELLENO_LAD_INF
            MOV DX, COLOR_LIMITE_ARRIBA
            CMP POSY, DX
            JE BORDE_LAD_INF
            MOV DX, COLOR_LIMITE_ABAJO
            CMP POSY, DX
            JE BORDE_LAD_INF
            CMP POSX, 220 ;3
            JE BORDE_LAD_INF
            CMP POSX, 420;1
            JE BORDE_LAD_INF
            JMP RELLENO_LAD_INF

                BORDE_LAD_INF:
                    MOV COLOR_PIXEL, 07H
                    CALL PRINT_PIXEL
                    INC POSX
                    CMP POSX, 421;1
                    JE SIGUIENTE_LAD_INF
                    JMP DIBUJAR_LAD_INF
                
                SIGUIENTE_LAD_INF:
                    MOV POSX, 220;INI X
                    ADD POSY, 1
                    JMP DIBUJAR_LAD_INF

                RELLENO_LAD_INF:
                    CMP TURNO_JUGADOR, 0
                    JE JUG_1_LAD_INF
                    JMP JUG_2_LAD_INF
                JUG_1_LAD_INF:
                    MOV DH, COLOR_JUGADOR1
                    MOV COLOR_RELLENO, DH
                    JMP CONTINUA_RELLENO_LAD_INF
                JUG_2_LAD_INF:
                    MOV DH, COLOR_JUGADOR2
                    MOV COLOR_RELLENO, DH
                    JMP CONTINUA_RELLENO_LAD_INF
                CONTINUA_RELLENO_LAD_INF:
                    MOV DH, COLOR_RELLENO
                    MOV COLOR_PIXEL, DH
                    JMP APLICAR_RELLENADO_LAD_INF

                APLICAR_RELLENADO_LAD_INF:
                    CALL PRINT_PIXEL
                    INC POSX
                    JMP DIBUJAR_LAD_INF
                    
        TERMINAR_RELLENO_LAD_INF:
            CMP TURNO_JUGADOR, 0
            JE TURNO_JUG_1_LAD_INF
            JMP TURNO_JUG_2_LAD_INF
        TURNO_JUG_1_LAD_INF:
            INC TURNO_JUGADOR
            MOV LADO_INFERIOR_PINTADO, 1         
            JMP FIN_RELLENO_LAD_IZQ
        TURNO_JUG_2_LAD_INF:
            DEC TURNO_JUGADOR
            MOV LADO_INFERIOR_PINTADO, 2
        FIN_RELLENO_LAD_INF:
        MOV COLOR_PIXEL, 01H
        RET
RELLENEAR_CUADRO_LADO_INFERIOR ENDP

RELLENEAR_CUADRO_SUPERIOR_DERECHA PROC
        MOV POSX, 420    ;INI
        MOV POSY, 40 ;INI
        MOV COLOR_LIMITE_ARRIBA, 40  ;INI Y
        MOV COLOR_LIMITE_ABAJO, 124; 2
        MOV COLOR_PIXEL, 07H
    
        DIBUJAR_SUP_DER: 
            MOV DX, COLOR_LIMITE_ABAJO
            ADD DX, 1
            CMP POSY, DX
            JE TERMINAR_RELLENO_SUP_DER
            MOV DX, COLOR_LIMITE_ARRIBA
            CMP POSY, DX
            JE BORDE_SUP_DER
            MOV DX, COLOR_LIMITE_ABAJO
            CMP POSY, DX
            JE BORDE_SUP_DER
            CMP POSX, 420 ;3
            JE BORDE_SUP_DER
            CMP POSX, 620;1
            JE BORDE_SUP_DER
            JMP RELLENO_SUP_DER

                BORDE_SUP_DER:
                    MOV COLOR_PIXEL, 07H
                    CALL PRINT_PIXEL
                    INC POSX
                    CMP POSX, 621;1
                    JE SIGUIENTE_SUP_DER
                    JMP DIBUJAR_SUP_DER
                
                SIGUIENTE_SUP_DER:
                    MOV POSX, 420;INI X
                    ADD POSY, 1
                    JMP DIBUJAR_SUP_DER

                RELLENO_SUP_DER:
                    CMP TURNO_JUGADOR, 0
                    JE JUG_1_SUP_DER
                    JMP JUG_2_SUP_DER
                JUG_1_SUP_DER:
                    MOV DH, COLOR_JUGADOR1
                    MOV COLOR_RELLENO, DH
                    JMP CONTINUA_RELLENO_SUP_DER
                JUG_2_SUP_DER:
                    MOV DH, COLOR_JUGADOR2
                    MOV COLOR_RELLENO, DH
                    JMP CONTINUA_RELLENO_SUP_DER
                CONTINUA_RELLENO_SUP_DER:
                    MOV DH, COLOR_RELLENO
                    MOV COLOR_PIXEL, DH
                    JMP APLICAR_RELLENADO_SUP_DER

                APLICAR_RELLENADO_SUP_DER:
                    CALL PRINT_PIXEL
                    INC POSX
                    JMP DIBUJAR_SUP_DER
                    
        TERMINAR_RELLENO_SUP_DER:
            CMP TURNO_JUGADOR, 0
            JE TURNO_JUG_1_SUP_DER
            JMP TURNO_JUG_2_SUP_DER
        TURNO_JUG_1_SUP_DER:
            INC TURNO_JUGADOR
            MOV SUPERIOR_DERECHA_PINTADO, 1         
            JMP FIN_RELLENO_LAD_IZQ
        TURNO_JUG_2_SUP_DER:
            DEC TURNO_JUGADOR
            MOV SUPERIOR_DERECHA_PINTADO, 2
        FIN_RELLENO_SUP_DER:
        MOV COLOR_PIXEL, 01H
        RET
RELLENEAR_CUADRO_SUPERIOR_DERECHA ENDP

RELLENEAR_CUADRO_LADO_DERECHO PROC
        MOV POSX, 420    ;INI
        MOV POSY, 124 ;INI
        MOV COLOR_LIMITE_ARRIBA, 124  ;INI Y
        MOV COLOR_LIMITE_ABAJO, 208; 2
        MOV COLOR_PIXEL, 07H
    
        DIBUJAR_LAD_DER: 
            MOV DX, COLOR_LIMITE_ABAJO
            ADD DX, 1
            CMP POSY, DX
            JE TERMINAR_RELLENO_LAD_DER
            MOV DX, COLOR_LIMITE_ARRIBA
            CMP POSY, DX
            JE BORDE_LAD_DER
            MOV DX, COLOR_LIMITE_ABAJO
            CMP POSY, DX
            JE BORDE_LAD_DER
            CMP POSX, 420 ;3
            JE BORDE_LAD_DER
            CMP POSX, 620;1
            JE BORDE_LAD_DER
            JMP RELLENO_LAD_DER

                BORDE_LAD_DER:
                    MOV COLOR_PIXEL, 07H
                    CALL PRINT_PIXEL
                    INC POSX
                    CMP POSX, 621;1
                    JE SIGUIENTE_LAD_DER
                    JMP DIBUJAR_LAD_DER
                
                SIGUIENTE_LAD_DER:
                    MOV POSX, 420;INI X
                    ADD POSY, 1
                    JMP DIBUJAR_LAD_DER

                RELLENO_LAD_DER:
                    CMP TURNO_JUGADOR, 0
                    JE JUG_1_LAD_DER
                    JMP JUG_2_LAD_DER
                JUG_1_LAD_DER:
                    MOV DH, COLOR_JUGADOR1
                    MOV COLOR_RELLENO, DH
                    JMP CONTINUA_RELLENO_LAD_DER
                JUG_2_LAD_DER:
                    MOV DH, COLOR_JUGADOR2
                    MOV COLOR_RELLENO, DH
                    JMP CONTINUA_RELLENO_LAD_DER
                CONTINUA_RELLENO_LAD_DER:
                    MOV DH, COLOR_RELLENO
                    MOV COLOR_PIXEL, DH
                    JMP APLICAR_RELLENADO_LAD_DER

                APLICAR_RELLENADO_LAD_DER:
                    CALL PRINT_PIXEL
                    INC POSX
                    JMP DIBUJAR_LAD_DER
                    
        TERMINAR_RELLENO_LAD_DER:
            CMP TURNO_JUGADOR, 0
            JE TURNO_JUG_1_LAD_DER
            JMP TURNO_JUG_2_LAD_DER
        TURNO_JUG_1_LAD_DER:
            INC TURNO_JUGADOR
            MOV LADO_DERECHO_PINTADO, 1         
            JMP FIN_RELLENO_LAD_IZQ
        TURNO_JUG_2_LAD_DER:
            DEC TURNO_JUGADOR
            MOV LADO_DERECHO_PINTADO, 2
        FIN_RELLENO_LAD_DER:
        MOV COLOR_PIXEL, 01H
        RET
RELLENEAR_CUADRO_LADO_DERECHO ENDP

RELLENEAR_CUADRO_INFERIOR_DERECHA PROC
        MOV POSX, 420
        MOV POSY, 208 
        MOV COLOR_LIMITE_ARRIBA, 208 
        MOV COLOR_LIMITE_ABAJO, 292;
        MOV COLOR_PIXEL, 07H
    
        DIBUJAR_INF_DER: 
            MOV DX, COLOR_LIMITE_ABAJO
            ADD DX, 1
            CMP POSY, DX
            JE TERMINAR_RELLENO_INF_DER
            MOV DX, COLOR_LIMITE_ARRIBA
            CMP POSY, DX
            JE BORDE_INF_DER
            MOV DX, COLOR_LIMITE_ABAJO
            CMP POSY, DX
            JE BORDE_INF_DER
            CMP POSX, 420 
            JE BORDE_INF_DER
            CMP POSX, 620
            JE BORDE_INF_DER
            JMP RELLENO_INF_DER

                BORDE_INF_DER:
                    MOV COLOR_PIXEL, 07H
                    CALL PRINT_PIXEL
                    INC POSX
                    CMP POSX, 621
                    JE SIGUIENTE_INF_DER
                    JMP DIBUJAR_INF_DER
                
                SIGUIENTE_INF_DER:
                    MOV POSX, 420
                    ADD POSY, 1
                    JMP DIBUJAR_INF_DER

                RELLENO_INF_DER:
                    CMP TURNO_JUGADOR, 0
                    JE JUG_1_INF_DER
                    JMP JUG_2_INF_DER
                JUG_1_INF_DER:
                    MOV DH, COLOR_JUGADOR1
                    MOV COLOR_RELLENO, DH
                    JMP CONTINUA_RELLENO_INF_DER
                JUG_2_INF_DER:
                    MOV DH, COLOR_JUGADOR2
                    MOV COLOR_RELLENO, DH
                    JMP CONTINUA_RELLENO_INF_DER
                CONTINUA_RELLENO_INF_DER:
                    MOV DH, COLOR_RELLENO
                    MOV COLOR_PIXEL, DH
                    JMP APLICAR_RELLENADO_INF_DER

                APLICAR_RELLENADO_INF_DER:
                    CALL PRINT_PIXEL
                    INC POSX
                    JMP DIBUJAR_INF_DER
                    
        TERMINAR_RELLENO_INF_DER:
            CMP TURNO_JUGADOR, 0
            JE TURNO_JUG_1_INF_DER
            JMP TURNO_JUG_2_INF_DER
        TURNO_JUG_1_INF_DER:
            INC TURNO_JUGADOR
            MOV INFERIOR_DERECHA_PINTADO, 1         
            JMP FIN_RELLENO_LAD_IZQ
        TURNO_JUG_2_INF_DER:
            DEC TURNO_JUGADOR
            MOV INFERIOR_DERECHA_PINTADO, 2
        FIN_RELLENO_INF_DER:
        MOV COLOR_PIXEL, 01H
        RET
RELLENEAR_CUADRO_INFERIOR_DERECHA ENDP

TURNO_DEL_JUGADOR PROC
    POS_CURSOR 21, 60
    MOV AH, 09H
    LEA DX, LIMPIA_TEXTO
    INT 21H

    CMP TURNO_JUGADOR, 0
    JE IMP_TURNO_JUG1
    CMP TURNO_JUGADOR, 1
    JE IMP_TURNO_JUG2

    IMP_TURNO_JUG1:
        POS_CURSOR 21, 61
        CALL IMPRIME_NOMBRE_JUG1
        RET
    IMP_TURNO_JUG2:
        POS_CURSOR 21, 61
        CALL IMPRIME_NOMBRE_JUG2
        RET
TURNO_DEL_JUGADOR ENDP

DETERMINA_GANADOR PROC

    CALL LIMPIAR_PANTALLA

    MOV SUPERIOR_IZQUIERDA_PINTADO , 1
    MOV LADO_IZQUIERDO_PINTADO , 1
    MOV INFERIOR_IZQUIERDA_PINTADO , 1
 
    MOV LADO_SUPERIOR_PINTADO , 1
    MOV CENTRAL_PINTADO , 1
    MOV LADO_INFERIOR_PINTADO , 1

    MOV SUPERIOR_DERECHA_PINTADO , 1
    MOV LADO_DERECHO_PINTADO , 1
    MOV INFERIOR_DERECHA_PINTADO , 1
   
    MOV AX, 01H
    INT 33H
    POS_CURSOR 23,7 
    MOV AH, 09H
	LEA DX, MSG_GUARDAR
	INT 21H
    POS_CURSOR 23,32
    MOV AH, 09H
	LEA DX, MSG_REINICIAR
	INT 21H
    POS_CURSOR 23,59 
    MOV AH, 09H
	LEA DX, MSG_SALIR
	INT 21H

    CMP GANADOR, 1
    JE HAY_GANADOR
    JMP NO_GANADOR
    
    HAY_GANADOR:
        CMP TURNO_JUGADOR, 0
        JE GANADOR_JUG2
        CMP TURNO_JUGADOR, 1
        JE GANADOR_JUG1

    GANADOR_JUG1:
        POS_CURSOR 10,25 
        MOV AH, 09H
        LEA DX, MSG_GANADOR1
        INT 21H

        POS_CURSOR 10,49
        CALL IMPRIME_NOMBRE_JUG1

        POS_CURSOR 14,20
        LEA SI, PUNTOS_JUGADOR1
        MOV BL, [SI]
        ADD BL, 10
        MOV PUNTOS_JUGADOR1, BL
        MOV AL, PUNTOS_JUGADOR1
        AAM
        MOV BX, AX
        MOV AH, 02H
        MOV DL, BH
        ADD DL, 30H
        INT 21H

        MOV AH, 02H
        MOV DL, BL
        ADD DL, 30H
        INT 21H
        
        CALL DIBUJAR_BTNS_GAME
        RET

    GANADOR_JUG2:
        POS_CURSOR 10,25 
        MOV AH, 09H
        LEA DX, MSG_GANADOR2
        INT 21H

        POS_CURSOR 10,49
        CALL IMPRIME_NOMBRE_JUG2

         POS_CURSOR 14,20
        LEA SI, PUNTOS_JUGADOR2
        MOV BL, [SI]
        ADD BL, 10
        MOV PUNTOS_JUGADOR2, BL
        MOV AL, PUNTOS_JUGADOR2
        AAM
        MOV BX, AX
        MOV AH, 02H
        MOV DL, BH
        ADD DL, 30H
        INT 21H

        MOV AH, 02H
        MOV DL, BL
        ADD DL, 30H
        INT 21H
        CALL DIBUJAR_BTNS_GAME
        RET

    NO_GANADOR:
        POS_CURSOR 10,30 
        MOV AH, 09H
        LEA DX, MSG_EMPATE
        INT 21H
        CALL DIBUJAR_BTNS_GAME
        RET
DETERMINA_GANADOR ENDP

BUSCAR_GANADOR  PROC

    HORIZONTAL1:
        MOV DH, SUPERIOR_IZQUIERDA_PINTADO 
        CMP DH, 0
        JE HORIZONTAL2
        MOV DH, LADO_SUPERIOR_PINTADO 
        CMP DH, 0
        JE HORIZONTAL2
        MOV DH, SUPERIOR_DERECHA_PINTADO 
        CMP DH, 0
        JE HORIZONTAL2
    

        HORIZONTAL1_PT1:
        MOV DH, SUPERIOR_IZQUIERDA_PINTADO 
        CMP DH, LADO_SUPERIOR_PINTADO
        JE HORIZONTAL1_PT2
        JMP HORIZONTAL2

        HORIZONTAL1_PT2:
        MOV DH, LADO_SUPERIOR_PINTADO
        CMP DH, SUPERIOR_DERECHA_PINTADO
        JE HORIZONTAL1_PT3
        JMP HORIZONTAL2

        HORIZONTAL1_PT3:
            MOV GANADOR, 1
            RET

    HORIZONTAL2:
        MOV DH, LADO_IZQUIERDO_PINTADO 
        CMP DH, 0
        JE HORIZONTAL3
        MOV DH, CENTRAL_PINTADO 
        CMP DH, 0
        JE HORIZONTAL3
        MOV DH, LADO_DERECHO_PINTADO 
        CMP DH, 0
        JE HORIZONTAL3
    

        HORIZONTAL2_PT1:
        MOV DH, LADO_IZQUIERDO_PINTADO 
        CMP DH, CENTRAL_PINTADO
        JE HORIZONTAL2_PT2
        JMP HORIZONTAL3

        HORIZONTAL2_PT2:
        MOV DH, CENTRAL_PINTADO
        CMP DH, LADO_DERECHO_PINTADO
        JE HORIZONTAL2_PT3
        JMP HORIZONTAL3

        HORIZONTAL2_PT3:
            MOV GANADOR, 1
            RET

    HORIZONTAL3:
        MOV DH, INFERIOR_IZQUIERDA_PINTADO 
        CMP DH, 0
        JE VERTICAL1
        MOV DH, LADO_INFERIOR_PINTADO 
        CMP DH, 0
        JE VERTICAL1
        MOV DH, INFERIOR_DERECHA_PINTADO 
        CMP DH, 0
        JE VERTICAL1
    

        HORIZONTAL3_PT1:
        MOV DH, INFERIOR_IZQUIERDA_PINTADO 
        CMP DH, LADO_INFERIOR_PINTADO
        JE HORIZONTAL3_PT2
        JMP VERTICAL1

        HORIZONTAL3_PT2:
        MOV DH, LADO_INFERIOR_PINTADO
        CMP DH, INFERIOR_DERECHA_PINTADO
        JE HORIZONTAL3_PT3
        JMP VERTICAL1

        HORIZONTAL3_PT3:
            MOV GANADOR, 1
            RET
    
    VERTICAL1:
        MOV DH, SUPERIOR_IZQUIERDA_PINTADO 
        CMP DH, 0
        JE VERTICAL2
        MOV DH, LADO_IZQUIERDO_PINTADO 
        CMP DH, 0
        JE VERTICAL2
        MOV DH, INFERIOR_IZQUIERDA_PINTADO 
        CMP DH, 0
        JE VERTICAL2
    

        VERTICAL1_PT1:
        MOV DH, SUPERIOR_IZQUIERDA_PINTADO 
        CMP DH, LADO_IZQUIERDO_PINTADO
        JE VERTICAL1_PT2
        JMP VERTICAL2

        VERTICAL1_PT2:
        MOV DH, LADO_IZQUIERDO_PINTADO
        CMP DH, INFERIOR_IZQUIERDA_PINTADO
        JE VERTICAL1_PT3
        JMP VERTICAL2

        VERTICAL1_PT3:
            MOV GANADOR, 1
            RET

    VERTICAL2:
        MOV DH, LADO_SUPERIOR_PINTADO 
        CMP DH, 0
        JE VERTICAL3
        MOV DH, CENTRAL_PINTADO 
        CMP DH, 0
        JE VERTICAL3
        MOV DH, LADO_INFERIOR_PINTADO 
        CMP DH, 0
        JE VERTICAL3
    

        VERTICAL2_PT1:
        MOV DH, LADO_SUPERIOR_PINTADO 
        CMP DH, CENTRAL_PINTADO
        JE VERTICAL2_PT2
        JMP VERTICAL3

        VERTICAL2_PT2:
        MOV DH, CENTRAL_PINTADO
        CMP DH, LADO_INFERIOR_PINTADO
        JE VERTICAL2_PT3
        JMP VERTICAL3

        VERTICAL2_PT3:
            MOV GANADOR, 1
            RET
        
    VERTICAL3:
        MOV DH, SUPERIOR_DERECHA_PINTADO 
        CMP DH, 0
        JE DIAGONAL1
        MOV DH, LADO_DERECHO_PINTADO 
        CMP DH, 0
        JE DIAGONAL1
        MOV DH, INFERIOR_DERECHA_PINTADO 
        CMP DH, 0
        JE DIAGONAL1
    

        VERTICAL3_PT1:
        MOV DH, SUPERIOR_DERECHA_PINTADO 
        CMP DH, LADO_DERECHO_PINTADO
        JE VERTICAL3_PT2
        JMP DIAGONAL1

        VERTICAL3_PT2:
        MOV DH, LADO_DERECHO_PINTADO
        CMP DH, INFERIOR_DERECHA_PINTADO
        JE VERTICAL3_PT3
        JMP DIAGONAL1

        VERTICAL3_PT3:
            MOV GANADOR, 1
            RET

    DIAGONAL1:
        MOV DH, SUPERIOR_IZQUIERDA_PINTADO 
        CMP DH, 0
        JE DIAGONAL2
        MOV DH, CENTRAL_PINTADO 
        CMP DH, 0
        JE DIAGONAL2
        MOV DH, INFERIOR_DERECHA_PINTADO 
        CMP DH, 0
        JE DIAGONAL2
    

        DIAGONAL1_PT1:
        MOV DH, SUPERIOR_IZQUIERDA_PINTADO 
        CMP DH, CENTRAL_PINTADO
        JE DIAGONAL1_PT2
        JMP DIAGONAL2

        DIAGONAL1_PT2:
        MOV DH, CENTRAL_PINTADO
        CMP DH, INFERIOR_DERECHA_PINTADO
        JE DIAGONAL1_PT3
        JMP DIAGONAL2

        DIAGONAL1_PT3:
            MOV GANADOR, 1
            RET

    DIAGONAL2:
        MOV DH, INFERIOR_IZQUIERDA_PINTADO 
        CMP DH, 0
        JE FIN_BUSCAR_GANADOR
        MOV DH, CENTRAL_PINTADO 
        CMP DH, 0
        JE FIN_BUSCAR_GANADOR
        MOV DH, SUPERIOR_DERECHA_PINTADO 
        CMP DH, 0
        JE FIN_BUSCAR_GANADOR
    

        DIAGONAL2_PT1:
        MOV DH, INFERIOR_IZQUIERDA_PINTADO 
        CMP DH, CENTRAL_PINTADO
        JE DIAGONAL2_PT2
        JMP FIN_BUSCAR_GANADOR

        DIAGONAL2_PT2:
        MOV DH, CENTRAL_PINTADO
        CMP DH, SUPERIOR_DERECHA_PINTADO
        JE DIAGONAL2_PT3
        JMP FIN_BUSCAR_GANADOR

        DIAGONAL2_PT3:
            MOV GANADOR, 1
            RET
    
    FIN_BUSCAR_GANADOR:
        RET
BUSCAR_GANADOR ENDP

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
    MOV AX, 03H                     ; PARA DETECTAR CUANDO SE SUELTA EL CLICK
    INT 33h                         ; SE LLAMA LA INTERRUPCION DEL MOUSE     
    CMP BX, 1                       ; LA INTERRUPCION DEVUELVE EN BX LA CANTIDAD DE VECES QUE SE SOLTO, ENTONCES COMPARO CON 1
    JE COMPARAR_COORDENADAS_MENU    ; SI SE PRESIONO AL MENOS UNA VEZ, SALTA A CLICK_IZQUIERDO
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

DETECTAR_TECLAS PROC

    POS_CURSOR 10,12 
    MOV AH, 09H
	LEA DX, MSG_COLOR1
	INT 21H

    POS_CURSOR 13,13
    MOV AH, 09H
	LEA DX, MSG_COLOR2
	INT 21H

    POS_CURSOR 5,13
    MOV AH, 09H
	LEA DX, MSG_INSTRUCCIONES_COLOR
	INT 21H

    DETECTAR_TECLAS1:
        CMP COLOR1_SELECCIONADO, 1
        JE SELEC1
        JMP DETECCION_TECLAS_MENU
        SELEC1:
            CMP COLOR2_SELECCIONADO, 1
            JE FIN_DETECCION_TECLAS
            JMP DETECCION_TECLAS_MENU

    FIN_DETECCION_TECLAS:
        CALL LIMPIAR_PANTALLA
        MOV AX, 01H ;MOSTRAR CURSOR
        INT 33H
        RET

    DETECCION_TECLAS_MENU:
        MOV AH, 00H
        INT 16H
        CMP AH, 02 ; TECLA 1
        JE JUG1_ROJO
        CMP AH, 03 ; TECLA 2
        JE JUG1_AMARILLO
        CMP AH, 04 ; TECLA 3
        JE JUG1_BLANCO
        CMP AH, 05 ; TECLA 4
        JE JUG2_ROSADO
        CMP AH, 06 ; TECLA 5
        JE JUG2_AZUL
        CMP AH, 07 ; TECLA 6
        JE JUG2_VERDE

        JMP DETECTAR_TECLAS1

    JUG1_ROJO:
        MOV DH, 04H
        MOV COLOR_JUGADOR1, DH
        MOV COLOR1_SELECCIONADO, 1
        JMP DETECTAR_TECLAS1
    JUG1_AMARILLO:
        MOV DH, 0EH
        MOV COLOR_JUGADOR1, DH
        MOV COLOR1_SELECCIONADO, 1
        JMP DETECTAR_TECLAS1
    JUG1_BLANCO:
        MOV DH, 0FH
        MOV COLOR_JUGADOR1, DH
        MOV COLOR1_SELECCIONADO, 1
        JMP DETECTAR_TECLAS1
    JUG2_ROSADO:
        MOV DH, 0DH
        MOV COLOR_JUGADOR2, DH
        MOV COLOR2_SELECCIONADO, 1
        JMP DETECTAR_TECLAS1
    JUG2_AZUL:
        MOV DH, 01H
        MOV COLOR_JUGADOR2, DH
        MOV COLOR2_SELECCIONADO, 1
        JMP DETECTAR_TECLAS1
    JUG2_VERDE:
        MOV DH, 0AH
        MOV COLOR_JUGADOR2, DH
        MOV COLOR2_SELECCIONADO, 1
        JMP DETECTAR_TECLAS1
DETECTAR_TECLAS ENDP

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

Q20CURS PROC NEAR
    MOV AH, 02H
    MOV BH, 00
    INT 10H
    
    RET
Q20CURS ENDP   

R10PRMP1 PROC NEAR
    MOV AH,09H
    LEA DX,PROMPT1
    INT 21H
    RET 
R10PRMP1 ENDP

R10PRMP2 PROC NEAR
    MOV AH,09H
    LEA DX,PROMPT2
    INT 21H
    RET 
R10PRMP2 ENDP

D10INPT PROC NEAR
    MOV AH,0AH
    LEA DX,NAMEPAR
    INT 21H
    RET 
D10INPT ENDP

SAVENAME1 PROC NEAR
    CLD
    MOV CX, 21
    LEA SI, NAMEFLD1
    LEA DI, NAMEJUGA1
    
A20:
    LODSB
    MOV [DI], AL
    INC DI
    LOOP A20
    RET
SAVENAME1 ENDP

SAVENAME2 PROC NEAR
    CLD
    MOV CX, 21
    LEA SI, NAMEFLD1
    LEA DI, NAMEJUGA2
    
B20:
    LODSB
    MOV [DI], AL
    INC DI
    LOOP A20
    RET
SAVENAME2 ENDP

OBTENER_NOMBRE PROC NEAR
    POS_CURSOR 1,3
    MOV AX, WORDA
    ADD AX,WORDB
    MOV WORDB , AX 

    CALL Q20CURS
    CALL R10PRMP1
    CALL D10INPT
    CALL SAVENAME1

    POS_CURSOR 1,53
    CALL Q20CURS
    CALL R10PRMP2
    CALL D10INPT
    CALL SAVENAME2
    RET
OBTENER_NOMBRE ENDP

IMPRIME_NOMBRE_JUG1 PROC
    CALL Q20CURS
    MOV AH, 09H
    LEA DX, NAMEJUGA1
    INT 21H
    RET
IMPRIME_NOMBRE_JUG1 ENDP

IMPRIME_NOMBRE_JUG2 PROC
    CALL Q20CURS
    MOV AH, 09H
    LEA DX, NAMEJUGA2
    INT 21H
    RET
IMPRIME_NOMBRE_JUG2 ENDP

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