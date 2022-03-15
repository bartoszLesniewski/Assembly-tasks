#include <stdio.h>

float dylatacja_czasu(unsigned int detlta_t_zero, float predkosc);

int main()
{
	float wynik = dylatacja_czasu(10, 10000.0f);
	printf("\nwynik = %f", wynik);

	wynik = dylatacja_czasu(10, 200000000.0f);
	printf("\nwynik = %f", wynik);

	wynik = dylatacja_czasu(60, 270000000.0f);
	printf("\nwynik = %f", wynik);

	return 0;
}