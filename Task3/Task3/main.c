#include <stdio.h>

int dot_product(int tab1[], int tab2[], int n);

int main()
{
	int n;
	printf("\nPodaj ilosc elementow tablic: ");
	scanf_s("%d", &n);

	int* tab1 = (int*)malloc(n * sizeof(int));
	int* tab2 = (int*)malloc(n * sizeof(int));

	printf("\nPodaj elementy tablicy 1: ");

	for (int i = 0; i < n; i++)
		scanf_s("%d", &tab1[i]);


	printf("\nPodaj elementy tablicy 2: ");

	for (int i = 0; i < n; i++)
		scanf_s("%d", &tab2[i]);

	int wynik = dot_product(tab1, tab2, n);

	printf("\nIloczyn skalarany wynosi: %d", wynik);

	return 0;
}