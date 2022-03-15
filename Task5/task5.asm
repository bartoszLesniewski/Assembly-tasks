.386
rozkazy SEGMENT use16
ASSUME cs:rozkazy

czyszczenie_ekranu PROC
	push ax
	push bx
	push es

	mov ax, 0A000H		; adres pami�ci ekranu dla trybu 13H
	mov es, ax

	mov bx, 0			; adres pierwszego piksela
	mov al, 0			; kolor czarny

czyszczenie:
	mov es:[bx], al			 ; wpisanie kodu koloru do pami�ci ekranu
	add bx, 1

	cmp bx, 320*200			; ca�y ekran 320 x 200
	jb czyszczenie

	pop es
	pop bx
	pop ax
	ret
czyszczenie_ekranu ENDP

kolorowanie_ekranu PROC
	; przechowanie rejestr�w
	push ax
	push bx
	push es
	push si

	cmp cs:czy_pokolorowane, 0
	je kolorowanie						; skok do kolorowania ekranu, je�li jest niepokolorowany - sytuacja po uruchomieniu programu lub po wci�ni�ciu strza�ki
		
	inc cs:licznik_przerwan				; zwi�kszenie licznika przerwa�

	cmp cs:licznik_przerwan, 18			; przerwanie zegarowe jest generowane co ok. 55 ms, 55ms * 18 = 1000 ms ~ 1 s
	jb wyjscie							; je�li mniej ni� 18 przerwa�, to kolor pozostaje bez zmian

	mov cs:licznik_przerwan, 0
	inc cs:licznik_kolorow				; zmiana koloru po up�ywie sekundy
	cmp cs:licznik_kolorow, 3
	jb kolorowanie

	mov cs:licznik_kolorow, 0			; ustawienie pierwszego koloru (czerwonego), je�li licznik przekroczy� dopuszczaln� ilo�� kolor�w

kolorowanie:
	mov ax, 0A000H		; adres pami�ci ekranu dla trybu 13H
	mov es, ax

	mov bx, cs:adres_piksela ; adres bie��cy piksela

	mov si, cs:licznik_kolorow
	mov al, cs:kolor[si]

ptl:
	mov es:[bx], al			 ; wpisanie kodu koloru do pami�ci ekranu

	cmp cs:kierunek, 1
	je gora
	cmp cs:kierunek, 2
	je dol
	
; lewo i prawo
	add bx, 1
	inc cs:licznik_pikseli
	
	cmp cs:licznik_pikseli, 160
	jb dalej
	
	add bx, 160					; przej�cie do kolejnej linii, je�li narysowno ju� 160 pikseli (lewa lub prawa po�owa ekranu)
	mov cs:licznik_pikseli, 0
	jmp dalej

gora:	
	add bx, 1
	cmp bx, 320*100				
	jb ptl	
	
	jmp wyjscie
	
dol:
	add bx, 1
	
dalej:	
	cmp bx, 320*200				
	jb ptl

wyjscie:
; odtworzenie rejestr�w
	mov cs:czy_pokolorowane, 1
	pop si
	pop es
	pop bx
	pop ax
; skok do oryginalnego podprogramu obs�ugi przerwania zegarowego
	jmp dword PTR cs:wektor8

; zmienne procedury
	adres_piksela dw 0		; bie��cy adres piksela
	wektor8 dd ?

	kierunek db 1			; okre�la, kt�r� po��wk� ekranu pokolorowa� (1 - g�rna, 2 - dolna, 3 - lewa, 4 - prawa)
	licznik_pikseli dw 0	; ilo�� pikseli w linii przy kolorowaniu lewej lub prawej po��wki ekranu, aby mo�na by�o stwierdzi�, kiedy przej�� do nast�pnej linii
	licznik_przerwan db 0	; okre�la ilo�� przerw�
	licznik_kolorow dw 0	; definiuje, kt�ry kolor z tablicy wybra�
	kolor db  4, 2, 1		; tablica z kolorami (4 - czerwony, 2 - zielony, 1 - niebieski)
	czy_pokolorowane db 0	; flaga okre�laj�ca, czy ekran jest ju� pokolorowany (1 - pokolorowany, 0 - niepokolorowany)

kolorowanie_ekranu ENDP

obsluga_klawiatury PROC
; przechowanie u�ywanych rejestr�w
	push ax
	push es

	in al, 60H

	cmp al, 72
	je strzalka_gora
	cmp al, 80
	je strzalka_dol
	cmp al, 75
	je strzalka_lewo
	cmp al, 77
	je strzalka_prawo

	jmp koniec

strzalka_gora:
	mov cs:kierunek, 1
	mov cs:adres_piksela, 0			; je�li ma zosta� pokolorowana g�rna po�owa, to nale�y zacz�� od piksela 0 (lewy g�rny r�g)
	call czyszczenie_ekranu			; wyczyszczenie bie��cego stanu ekranu
	mov cs:czy_pokolorowane, 0		; ustawienie flagi na 0 - ekran niepokolorowany
	jmp koniec
strzalka_dol:
	mov cs:kierunek, 2
	mov cs:adres_piksela, 32000		; je�li ma zosta� pokolorowana dolna po�owa, to nale�y zacz�� od po�owy ekranu (320 * 100)
	call czyszczenie_ekranu	
	mov cs:czy_pokolorowane, 0
	jmp koniec
strzalka_lewo:
	mov cs:kierunek, 3
	mov cs:adres_piksela, 0			; je�li ma zosta� pokolorowana lewa po�owa, to tak smao jak w przypadku g�rnej, nale�y zacz�� od lewego g�rnego rogu
	call czyszczenie_ekranu	
	mov cs:czy_pokolorowane, 0
	jmp koniec
strzalka_prawo:
	mov cs:kierunek, 4
	mov cs:adres_piksela, 160		; je�li ma zosta� pokolorowana dolna po�owa, to nale�y zacz�� od po�owy pierwszego wiersza ekranu (160)
	call czyszczenie_ekranu	
	mov cs:czy_pokolorowane, 0

koniec:
; odtworzenie rejestr�w
	pop es
	pop ax

; skok do oryginalnej procedury obs�ugi przerwania klawiatury
jmp dword PTR cs:wektor9

	wektor9 dd ?
obsluga_klawiatury ENDP

; INT 10H, funkcja nr 0 ustawia tryb sterownika graficznego
zacznij:
	mov ah, 0
	mov al, 13H		; nr trybu
	int 10H

; przerwanie klawiatury
	mov bx, 0
	mov es, bx				; zerowanie rejestru ES
	mov eax, es:[36]		; odczytanie wektora nr 9
	mov cs:wektor9, eax		; zapami�tanie wektora nr 9

; adres procedury 'obsluga_klawiatury' w postaci segment:offset
	mov ax, SEG obsluga_klawiatury
	mov bx, OFFSET obsluga_klawiatury
	cli		; zablokowanie przerwa�

; zapisanie adresu procedury 'obsluga_klawiatury' do wektora nr 9
	mov es:[36], bx
	mov es:[36+2], ax

	sti		; odblokowanie przerwa�


; przerwanie zegara
	mov bx, 0
	mov es, bx				; zerowanie rejestru ES
	mov eax, es:[32]		; odczytanie wektora nr 8
	mov cs:wektor8, eax		; zapami�tanie wektora nr 8

; adres procedury 'kolorowanie_ekranu' w postaci segment:offset
	mov ax, SEG kolorowanie_ekranu
	mov bx, OFFSET kolorowanie_ekranu
	cli		; zablokowanie przerwa�

; zapisanie adresu procedury 'kolorowanie_ekranu' do wektora nr 8
	mov es:[32], bx
	mov es:[32+2], ax

	sti		; odblokowanie przerwa�

	czekaj:
	mov ah, 1	; sprawdzenie czy jest jaki� znak
	int 16h		; w buforze klawiatury
	jz czekaj

	mov ah, 0
	int 16H
	cmp al, 'x' ; por�wnanie z kodem litery 'x'
	jne czekaj ; skok, gdy inny znak

	mov ah, 0	; funkcja nr 0 ustawia tryb sterownika
	mov al, 3H	; nr trybu
	int 10H

; odtworzenie oryginalnej zawarto�ci wektora nr 9
	mov eax, cs:wektor9
	mov es:[36], eax

; odtworzenie oryginalnej zawarto�ci wektora nr 8
	mov eax, cs:wektor8
	mov es:[32], eax

; zako�czenie wykonywania programu
	mov ax, 4C00H
	int 21H

rozkazy ENDS

stosik SEGMENT stack
	db 256 dup (?)
stosik ENDS

END zacznij
