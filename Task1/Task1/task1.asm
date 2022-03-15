; wczytywanie i wy�wietlanie tekstu wielkimi literami
; (inne znaki si� nie zmieniaj�)
.686
.model flat
extern _ExitProcess@4 : PROC
extern __write : PROC ; (dwa znaki podkre�lenia)
extern __read : PROC ; (dwa znaki podkre�lenia)
public _main
.data
	tekst_pocz		db  10, 'Prosz', 169, ' napisa', 134, ' jaki', 152, ' tekst '
					db  'i nacisnac Enter', 10
	koniec_t		db  ?
	magazyn			db  80 dup (?)
	magazyn_out		db	80 dup (?)
	nowa_linia		db  10
	liczba_znakow   dd  ?

.code
_main PROC
; wy�wietlenie tekstu informacyjnego
; liczba znak�w tekstu
	 mov	ecx,(OFFSET koniec_t) - (OFFSET tekst_pocz)
	 push	ecx
	 push	OFFSET tekst_pocz ; adres tekstu
	 push	1 ; nr urz�dzenia (tu: ekran - nr 1)
	 call	 __write ; wy�wietlenie tekstu pocz�tkowego
	 add	esp, 12 ; usuniecie parametr�w ze stosu

; czytanie wiersza z klawiatury
	 push	80 ; maksymalna liczba znak�w
	 push	OFFSET magazyn
	 push	0 ; nr urz�dzenia (tu: klawiatura - nr 0)
	 call	__read ; czytanie znak�w z klawiatury
	 add	esp, 12 ; usuniecie parametr�w ze stosu
; kody ASCII napisanego tekstu zosta�y wprowadzone
; do obszaru 'magazyn'

; funkcja read wpisuje do rejestru EAX liczb�
; wprowadzonych znak�w
	mov liczba_znakow, eax
	sub eax, 1

; rejestr ECX pe�ni rol� licznika obieg�w p�tli
	mov ecx, eax
	;mov ebx, 0 ; indeks pocz�tkowy
	mov ebx, liczba_znakow
	sub ebx, 2
	mov esi, 0

	pt1:
	mov dl, magazyn[ebx]

	cmp ebx, 0
	je poczatek_lancucha

	cmp dl, ' '
	jne dalej

	poczatek_lancucha:
	mov edi, ebx
	cmp ebx, 0
	je dodaj_znak

	inc edi	; kolejny znak po spacji

	dodaj_znak:
	mov dl, magazyn[edi]
	cmp dl, ' '
	je dodaj_spacje
	cmp dl, 0Ah
	je dodaj_spacje

	mov magazyn_out[esi], dl
	inc esi
	inc edi
	cmp esi, eax
	jb dodaj_znak

	dodaj_spacje:
	mov magazyn_out[esi], ' '
	inc esi

	dalej:
	dec ebx
	loop pt1

; wy�wietlenie przekszta�conego tekstu
	 push liczba_znakow
	 push OFFSET magazyn_out
	 push 1
	 call __write ; wy�wietlenie przekszta�conego tekstu
	 add esp, 12 ; usuniecie parametr�w ze stosu
	 push 0
	 call _ExitProcess@4 ; zako�czenie programu
_main ENDP
END

