.386
rozkazy SEGMENT use16
ASSUME cs:rozkazy

czyszczenie_ekranu PROC
	push ax
	push bx
	push es

	mov ax, 0A000H		; adres pamiêci ekranu dla trybu 13H
	mov es, ax

	mov bx, 0			; adres pierwszego piksela
	mov al, 0			; kolor czarny

czyszczenie:
	mov es:[bx], al			 ; wpisanie kodu koloru do pamiêci ekranu
	add bx, 1

	cmp bx, 320*200			; ca³y ekran 320 x 200
	jb czyszczenie

	pop es
	pop bx
	pop ax
	ret
czyszczenie_ekranu ENDP

kolorowanie_ekranu PROC
	; przechowanie rejestrów
	push ax
	push bx
	push es
	push si

	cmp cs:czy_pokolorowane, 0
	je kolorowanie						; skok do kolorowania ekranu, jeœli jest niepokolorowany - sytuacja po uruchomieniu programu lub po wciœniêciu strza³ki
		
	inc cs:licznik_przerwan				; zwiêkszenie licznika przerwañ

	cmp cs:licznik_przerwan, 18			; przerwanie zegarowe jest generowane co ok. 55 ms, 55ms * 18 = 1000 ms ~ 1 s
	jb wyjscie							; jeœli mniej ni¿ 18 przerwañ, to kolor pozostaje bez zmian

	mov cs:licznik_przerwan, 0
	inc cs:licznik_kolorow				; zmiana koloru po up³ywie sekundy
	cmp cs:licznik_kolorow, 3
	jb kolorowanie

	mov cs:licznik_kolorow, 0			; ustawienie pierwszego koloru (czerwonego), jeœli licznik przekroczy³ dopuszczaln¹ iloœæ kolorów

kolorowanie:
	mov ax, 0A000H		; adres pamiêci ekranu dla trybu 13H
	mov es, ax

	mov bx, cs:adres_piksela ; adres bie¿¹cy piksela

	mov si, cs:licznik_kolorow
	mov al, cs:kolor[si]

ptl:
	mov es:[bx], al			 ; wpisanie kodu koloru do pamiêci ekranu

	cmp cs:kierunek, 1
	je gora
	cmp cs:kierunek, 2
	je dol
	
; lewo i prawo
	add bx, 1
	inc cs:licznik_pikseli
	
	cmp cs:licznik_pikseli, 160
	jb dalej
	
	add bx, 160					; przejœcie do kolejnej linii, jeœli narysowno ju¿ 160 pikseli (lewa lub prawa po³owa ekranu)
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
; odtworzenie rejestrów
	mov cs:czy_pokolorowane, 1
	pop si
	pop es
	pop bx
	pop ax
; skok do oryginalnego podprogramu obs³ugi przerwania zegarowego
	jmp dword PTR cs:wektor8

; zmienne procedury
	adres_piksela dw 0		; bie¿¹cy adres piksela
	wektor8 dd ?

	kierunek db 1			; okreœla, któr¹ po³ówkê ekranu pokolorowaæ (1 - górna, 2 - dolna, 3 - lewa, 4 - prawa)
	licznik_pikseli dw 0	; iloœæ pikseli w linii przy kolorowaniu lewej lub prawej po³ówki ekranu, aby mo¿na by³o stwierdziæ, kiedy przejœæ do nastêpnej linii
	licznik_przerwan db 0	; okreœla iloœæ przerwñ
	licznik_kolorow dw 0	; definiuje, który kolor z tablicy wybraæ
	kolor db  4, 2, 1		; tablica z kolorami (4 - czerwony, 2 - zielony, 1 - niebieski)
	czy_pokolorowane db 0	; flaga okreœlaj¹ca, czy ekran jest ju¿ pokolorowany (1 - pokolorowany, 0 - niepokolorowany)

kolorowanie_ekranu ENDP

obsluga_klawiatury PROC
; przechowanie u¿ywanych rejestrów
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
	mov cs:adres_piksela, 0			; jeœli ma zostaæ pokolorowana górna po³owa, to nale¿y zacz¹æ od piksela 0 (lewy górny róg)
	call czyszczenie_ekranu			; wyczyszczenie bie¿¹cego stanu ekranu
	mov cs:czy_pokolorowane, 0		; ustawienie flagi na 0 - ekran niepokolorowany
	jmp koniec
strzalka_dol:
	mov cs:kierunek, 2
	mov cs:adres_piksela, 32000		; jeœli ma zostaæ pokolorowana dolna po³owa, to nale¿y zacz¹æ od po³owy ekranu (320 * 100)
	call czyszczenie_ekranu	
	mov cs:czy_pokolorowane, 0
	jmp koniec
strzalka_lewo:
	mov cs:kierunek, 3
	mov cs:adres_piksela, 0			; jeœli ma zostaæ pokolorowana lewa po³owa, to tak smao jak w przypadku górnej, nale¿y zacz¹æ od lewego górnego rogu
	call czyszczenie_ekranu	
	mov cs:czy_pokolorowane, 0
	jmp koniec
strzalka_prawo:
	mov cs:kierunek, 4
	mov cs:adres_piksela, 160		; jeœli ma zostaæ pokolorowana dolna po³owa, to nale¿y zacz¹æ od po³owy pierwszego wiersza ekranu (160)
	call czyszczenie_ekranu	
	mov cs:czy_pokolorowane, 0

koniec:
; odtworzenie rejestrów
	pop es
	pop ax

; skok do oryginalnej procedury obs³ugi przerwania klawiatury
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
	mov cs:wektor9, eax		; zapamiêtanie wektora nr 9

; adres procedury 'obsluga_klawiatury' w postaci segment:offset
	mov ax, SEG obsluga_klawiatury
	mov bx, OFFSET obsluga_klawiatury
	cli		; zablokowanie przerwañ

; zapisanie adresu procedury 'obsluga_klawiatury' do wektora nr 9
	mov es:[36], bx
	mov es:[36+2], ax

	sti		; odblokowanie przerwañ


; przerwanie zegara
	mov bx, 0
	mov es, bx				; zerowanie rejestru ES
	mov eax, es:[32]		; odczytanie wektora nr 8
	mov cs:wektor8, eax		; zapamiêtanie wektora nr 8

; adres procedury 'kolorowanie_ekranu' w postaci segment:offset
	mov ax, SEG kolorowanie_ekranu
	mov bx, OFFSET kolorowanie_ekranu
	cli		; zablokowanie przerwañ

; zapisanie adresu procedury 'kolorowanie_ekranu' do wektora nr 8
	mov es:[32], bx
	mov es:[32+2], ax

	sti		; odblokowanie przerwañ

	czekaj:
	mov ah, 1	; sprawdzenie czy jest jakiœ znak
	int 16h		; w buforze klawiatury
	jz czekaj

	mov ah, 0
	int 16H
	cmp al, 'x' ; porównanie z kodem litery 'x'
	jne czekaj ; skok, gdy inny znak

	mov ah, 0	; funkcja nr 0 ustawia tryb sterownika
	mov al, 3H	; nr trybu
	int 10H

; odtworzenie oryginalnej zawartoœci wektora nr 9
	mov eax, cs:wektor9
	mov es:[36], eax

; odtworzenie oryginalnej zawartoœci wektora nr 8
	mov eax, cs:wektor8
	mov es:[32], eax

; zakoñczenie wykonywania programu
	mov ax, 4C00H
	int 21H

rozkazy ENDS

stosik SEGMENT stack
	db 256 dup (?)
stosik ENDS

END zacznij
