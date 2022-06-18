#include <stdio.h>
#include <sys/mman.h>

#define BASE (void *)0x10000000ll
#define KIL 1024ll
#define MEG 1048576
#define GIG 1073741824

int main(int argc, char **argv)
{
        void *base = mmap(BASE,
                          32ll * GIG,
                          PROT_READ | PROT_WRITE,
                          MAP_PRIVATE | MAP_ANONYMOUS | MAP_FIXED,
                          -1, 0);
        printf("base at %p\n", base);
        while(1);
}
