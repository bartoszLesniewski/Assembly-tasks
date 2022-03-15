.686
.model flat

public _dylatacja_czasu

.code
_dylatacja_czasu PROC
	push ebp
	mov ebp, esp

	finit
	fild dword PTR [ebp + 8]		; ST(0) = delta_t0
	fld1							; ST(0) = 1, ST(1) = delta_t0
	fld dword PTR [ebp + 12]		; ST(0) = v, ST(1) = 1, ST(2) = delta_t0
	fmul st(0), st(0)				; ST(0) = v^2, ST(1) = 1, ST(2) = delta_t0

	mov ecx, 300000000			
	push ecx
	fild dword PTR [ebp - 4]		; ST(0) = c, ST(1) = v^2, ST(2) = 1, ST(3) = delta_t0
	fmul st(0), st(0)				; ST(0) = c^2, ST(1) = v^2, ST(2) = 1, ST(3) = delta_t0

	fdivp st(1), st(0)				; ST(0) = v^2 / c^2, ST(1) = 1, ST(2) = delta_t0

; mianownik
	fsubp st(1), st(0)				; ST(0) = 1 - v^2 / c^2, ST(1) = delta_t0
	fsqrt							; ST(0) = sqrt(1 - v^2 / c^2), ST(1) = delta_t0

; koñcowy wynik
	fdivp st(1), st(0)

	add esp, 4
	pop ebp
	ret
_dylatacja_czasu ENDP
END