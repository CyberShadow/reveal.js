#include <stdio.h>

void runfun(int line = __LINE__) {
	printf("%d\n", line);
}
template <int line = __LINE__>
void tplfun() {
	printf("%d\n", line);
}

int main()
{
	runfun();
	tplfun<>();
}
