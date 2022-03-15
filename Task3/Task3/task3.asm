.686
.model flat

public _dot_product

.code
_dot_product PROC
	push ebp
	mov ebp, esp
	push ebx
	push esi
	push edi

	mov ecx, [ebp + 16]		; iloœæ elementów w tablicy
	mov esi, 0				; licznik elementów
	mov edi, 0				; wartoœæ iloczynu skalarnego

iloczyn_skalarny:
	mov eax, [ebp + 8]		; adres tablicy 1
	mov eax, [eax + esi]	; element tablicy 1
	mov ebx, [ebp + 12]		; adres tablicy 2
	mov ebx, [ebx + esi]	; element tablict 2
	imul ebx
	add edi, eax
	add esi, 4
	loop iloczyn_skalarny

	mov eax, edi

	pop edi
	pop esi
	pop ebx
	pop ebp
	ret
_dot_product ENDP
END