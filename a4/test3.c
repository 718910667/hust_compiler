int m()
{
	return 0;
}
int main()
{
	int i=0, j=0,i3=0;
	int i1=2147483647;//INT类型越界;
	int j;//在5行,j 变量重复定义
	float a;
	char h = 'a';
	vv;//vv 变量未定义
	m;//m 是函数名，类型不匹配
	!a;
	a&&i;
	v1();//在10行,v1 函数未定义
	a + 7;//操作数类型不匹配
	10 = i;//左值问题
	i = a;//赋值类型不匹配
	i(10);//i 不是一个函数
	return 0.2;//返回值类型错误
}
int n(int m1,int m1)//参数名重复定义
{
	return m1;
}

int func(int i) 
{return i;}

int func()//函数重复定义
{
	char c='a';
	int b = 0;
	func(3);
	func();//函数参数过少
	func(c);//参数类型不匹配
	func(i, b, c);//函数参数过多
	return 1;
}

