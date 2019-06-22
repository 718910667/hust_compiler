int func()
{
	int i = 15;
	return i;
}
int main()
{
	int a = 3;
	if (1 && 1)
	{
		a++;
		a--;
	}
	if (a == 3)
	{
		a = 8;
	}
	if (a <= 10)
	{
		a = 6;
	}
	if (a >= 3)
	{
		a = 4;
	}
	if (a < 5)
	{
		a = 5;
	}
	if (a > 4)
	{
		a = 10;
	}
	a = func();
	return a;
}