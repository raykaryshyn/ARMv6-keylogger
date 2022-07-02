#include <unistd.h>
#include <fcntl.h>

int main() {
	int fd;
	fd = open("/dev/input/event3", 0, 0);

	return 0;
}
