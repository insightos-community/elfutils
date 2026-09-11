#include <assert.h>
#include <fcntl.h>
#include <gelf.h>
#include <libelf.h>
#include <stdio.h>
#include <unistd.h>
int main(int argc, char **argv) {
  assert(elf_version(EV_CURRENT) != EV_NONE);
  int fd = open(argv[0], O_RDONLY);
  assert(fd >= 0);
  Elf *elf = elf_begin(fd, ELF_C_READ, NULL);
  assert(elf && elf_kind(elf) == ELF_K_ELF);
  GElf_Ehdr header;
  assert(gelf_getehdr(elf, &header));
  assert(header.e_machine == EM_X86_64);
  size_t count;
  assert(elf_getshdrnum(elf, &count) == 0 && count > 0);
  elf_end(elf);
  close(fd);
  puts("PASS: libelf reads ELF headers and section table");
  return 0;
}
