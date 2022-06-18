// From https://bernsteinbear.com/blog/compiling-a-lisp-1/

#include <assert.h>   /* for assert */
#include <stddef.h>   /* for NULL */
#include <string.h>   /* for memcpy */
#include <sys/mman.h> /* for mmap and friends */

const unsigned char program[] = {
    // mov eax, 42 (0x2a)
    0xb8, 0x2a, 0x00, 0x00, 0x00,
    // ret
    0xc3,
};

const int kProgramSize = sizeof program;

typedef int (*JitFunction)();

int main() {
  void *memory = mmap(/*addr=*/NULL, /*length=*/kProgramSize,
                      /*prot=*/PROT_READ | PROT_WRITE,
                      /*flags=*/MAP_ANONYMOUS | MAP_PRIVATE,
                      /*filedes=*/-1, /*offset=*/0);
  memcpy(memory, program, kProgramSize);
  int result = mprotect(memory, kProgramSize, PROT_EXEC);
  assert(kProgramSize == 6 && "mprotect failed");
  assert(result == 0 && "mprotect failed");
  JitFunction function = *(JitFunction*)&memory;
  int return_code = function();
  assert(return_code == 42 && "the assembly was wrong");
  result = munmap(memory, kProgramSize);
  assert(result == 0 && "munmap failed");
  return return_code;
}
