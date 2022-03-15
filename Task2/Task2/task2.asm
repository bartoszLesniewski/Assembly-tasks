.686
.model flat
extern _ExitProcess@4 : PROC
extern __write : PROC
extern __read : PROC
public _main
; obszar danych programu
.data
; deklaracja tablicy 12-bajtowej do przechowywania
; tworzonych cyfr
znaki db 13 dup (?)
obszar db 12 dup (?)
dziesiec dd 10			; mno�nik

; obszar instrukcji (rozkaz�w) programu
.code
wyswietl_EAX_U2 PROC
	pusha

	mov esi, 11			; indeks w tablicy 'znaki'
	mov ebx, 10			; dzielnik r�wny 10

	cmp eax, 0
	je zero

	bt eax, 31
	jc ujemna

	mov cl, '+'
	jmp konwersja

zero:
	mov cl, 20H
	jmp konwersja

ujemna:
	mov cl, '-'
	neg eax

konwersja:
	mov edx, 0			; zerowanie starszej cz�ci dzielnej
	div ebx				; dzielenie przez 10, reszta w EDX,
						; iloraz w EAX
	add dl, 30H			; zamiana reszty z dzielenia na kod
						; ASCII
	mov znaki [esi], dl	; zapisanie cyfry w kodzie ASCII
	dec esi				; zmniejszenie indeksu
	cmp eax, 0			; sprawdzenie czy iloraz = 0
	jne konwersja		; skok, gdy iloraz niezerowy

	mov znaki[esi], cl
	dec esi
; wype�nienie pozosta�ych bajt�w spacjami i wpisanie
; znak�w nowego wiersza
wypeln:
	or esi, esi
	jz wyswietl						; skok, gdy ESI = 0
	mov byte PTR znaki [esi], 20H	; kod spacji
	dec esi							; zmniejszenie indeksu
jmp wypeln

wyswietl:
	mov byte PTR znaki [0], 0AH		; kod nowego wiersza
	mov byte PTR znaki [12], 0AH	; kod nowego wiersza
	
	; wy�wietlenie cyfr na ekranie
	push dword PTR 13				; liczba wy�wietlanych znak�w
	push dword PTR OFFSET znaki		; adres wy�w. obszaru
	push dword PTR 1				; numer urz�dzenia (ekran ma numer 1)
	call __write					; wy�wietlenie liczby na ekranie
	add esp, 12						; usuni�cie parametr�w ze stosu

	popa
	ret
wyswietl_EAX_U2 ENDP

wczytaj_EAX_U2 PROC
	push ebx
	push ecx
	push edx
	push esi

	push dword PTR 12			; max ilo�� znak�w wczytywanej liczby
	push offset obszar			; adres obszaru pami�ci
	push dword PTR 0			; numer urz�dzenia (0 dla klawiatury)
	call __read					; odczytywanie znak�w z klawiatury
								; (dwa znaki podkre�lenia przed read)
	add esp, 12					; usuni�cie parametr�w ze stosu

	; bie��ca warto�� przekszta�canej liczby przechowywana jest
	; w rejestrze EAX; przyjmujemy 0 jako warto�� pocz�tkow�
	mov eax, 0
	mov ebx, OFFSET obszar		; adres obszaru ze znakami
	mov esi, 0

; je�li pierwszym znakiem jest '-' albo '+', to nale�y zwi�kszy� indeks o 1
; aby nie przekszta�ca� tych znak�w na liczb�
	cmp [ebx], byte PTR '-'
	je ze_znakiem
	cmp [ebx], byte PTR '+'
	jne pobieraj_znaki	

ze_znakiem:
	inc esi

pobieraj_znaki:
	mov cl, [ebx + esi]			; pobranie kolejnej cyfry w kodzie ASCII
	inc esi
	cmp cl, 10					; sprawdzenie, czy naci�ni�to enter
	je byl_enter				; skok, gdy naci�ni�to enter
	sub cl, 30H					; zmiana kodu ASCII na warto�� cyfry
	movzx ecx, cl				; przechowanie warto�ci cyfry w rejestrze ECX
	
	mul dword PTR dziesiec		; mno�enie wcze�niej obliczonej warto�ci razy 10
								; dword PTR jest zb�dne, bo dziesiec jest typu dd
								; u�ycie dword PTR by�oby zasadne, gdyby dziesiec by�o typu np. db
	add eax, ecx				; dodanie ostatnio odczytanej cyfry
jmp pobieraj_znaki				; skok na pocz�tek p�tli

byl_enter:
	cmp [ebx], byte PTR '-'
	jne dalej

	neg eax

dalej:
	pop esi
	pop edx
	pop ecx
	pop ebx
	ret
wczytaj_EAX_U2 ENDP

testy_zad1 PROC
	pusha
	mov eax, 15
	call wyswietl_EAX_U2

	mov eax, -15
	call wyswietl_EAX_U2
	
	mov eax, 0
	call wyswietl_EAX_U2	

	mov eax, -192
	call wyswietl_EAX_U2

	mov eax, 5678
	call wyswietl_EAX_U2	

	popa
	ret
testy_zad1 ENDP

_main PROC
	call testy_zad1

	call wczytaj_EAX_U2	
;	sub eax, 10
	call wyswietl_EAX_U2

	push 0
	call _ExitProcess@4
_main ENDP
END