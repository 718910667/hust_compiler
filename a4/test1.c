
int func1(int a)
{
	int b, c, d;
	if (a == 0)
		return 1;
	if (a == 1)
		return 1;
	b = 1;
	c = 1;
	a = a - 1;
	while (a)
	{
		d = b;
		b = c;
		c = c + d;
		a = a - 1;
	}
	return c;
}
int main()
{
	int k = 12;
	func1(k);
	while (k < 3)
	{
		k++;
		k--;
	}
	return k;
}