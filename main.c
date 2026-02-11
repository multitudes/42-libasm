#include "libasm.h"
#include "libasm_bonus.h"
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

void test_strlen(void) {
  printf("\n=== FT_STRLEN TESTS ===\n");

  printf("Test 1: Normal string\n");
  const char *str1 = "Hello, World!";
  size_t len1 = ft_strlen(str1);
  printf("  Expected: 13, Got: %zu\n", len1);

  printf("Test 2: Empty string\n");
  size_t len2 = ft_strlen("");
  printf("  Expected: 0, Got: %zu\n", len2);

  printf("Test 3: Single character\n");
  size_t len3 = ft_strlen("A");
  printf("  Expected: 1, Got: %zu\n", len3);

  printf("Test 4: String with spaces\n");
  const char *str4 = "   ";
  size_t len4 = ft_strlen(str4);
  printf("  Expected: 3, Got: %zu\n", len4);
}

void test_write_read(void) {
  printf("\n=== FT_WRITE & FT_READ TESTS ===\n");

  printf("Test 1: Writing to stdout\n");
  printf("  Bytes written: ");
  ssize_t written = ft_write(1, "Hello from ft_write!", 19);
  printf(" (%zd bytes)\n", written);

  printf("Test 2: Writing to file and reading back\n");
  const char *test_file = "test_data.txt";
  const char *test_data = "Test data 42";

  int fd = open(test_file, O_WRONLY | O_CREAT | O_TRUNC, 0644);
  if (fd != -1) {
    ssize_t w = ft_write(fd, test_data, strlen(test_data));
    printf("  Wrote %zd bytes\n", w);
    close(fd);

    fd = open(test_file, O_RDONLY);
    if (fd != -1) {
      char buffer[100];
      ssize_t r = ft_read(fd, buffer, 100);
      printf("  Read %zd bytes: '%s'\n", r, buffer);
      close(fd);
    }
    unlink(test_file);
  }
}

void test_strcpy(void) {
  printf("\n=== FT_STRCPY TESTS ===\n");

  printf("Test 1: Normal copy\n");
  char dest1[50];
  ft_strcpy(dest1, "Hello");
  printf("  Expected: 'Hello', Got: '%s'\n", dest1);

  printf("Test 2: Empty string copy\n");
  char dest2[50];
  ft_strcpy(dest2, "");
  printf("  Expected: '', Got: '%s'\n", dest2);

  printf("Test 3: Long string copy\n");
  char dest3[100];
  ft_strcpy(dest3, "The quick brown fox jumps over the lazy dog");
  printf("  Got: '%s'\n", dest3);
}

void test_strcmp(void) {
  printf("\n=== FT_STRCMP TESTS ===\n");

  printf("Test 1: Equal strings\n");
  int cmp1 = ft_strcmp("abc", "abc");
  printf("  Expected: 0, Got: %d\n", cmp1);

  printf("Test 2: First string less than second\n");
  int cmp2 = ft_strcmp("abc", "def");
  printf("  Expected: negative, Got: %d\n", cmp2);

  printf("Test 3: First string greater than second\n");
  int cmp3 = ft_strcmp("xyz", "abc");
  printf("  Expected: positive, Got: %d\n", cmp3);

  printf("Test 4: Different lengths (prefix)\n");
  int cmp4 = ft_strcmp("test", "testing");
  printf("  Expected: negative, Got: %d\n", cmp4);

  printf("Test 5: Empty strings\n");
  int cmp5 = ft_strcmp("", "");
  printf("  Expected: 0, Got: %d\n", cmp5);

  printf("Test 6: One empty string\n");
  int cmp6 = ft_strcmp("abc", "");
  printf("  Expected: positive, Got: %d\n", cmp6);
}

void test_strdup(void) {
  printf("\n=== FT_STRDUP TESTS ===\n");

  printf("Test 1: Duplicate normal string\n");
  char *dup1 = ft_strdup("Hello, World!");
  printf("  Expected: 'Hello, World!', Got: '%s'\n", dup1);
  free(dup1);

  printf("Test 2: Duplicate empty string\n");
  char *dup2 = ft_strdup("");
  printf("  Expected: '', Got: '%s'\n", dup2);
  free(dup2);

  printf("Test 3: Check independence (modify copy)\n");
  char *orig = "Original";
  char *dup3 = ft_strdup(orig);
  char *temp = dup3;
  dup3[0] = 'X';
  printf("  Original: '%s', Copy: '%s'\n", orig, temp);
  free(temp);

  printf("Test 4: Long string duplication\n");
  const char *long_str = "This is a longer string to test memory allocation "
                         "and string copying functionality";
  char *dup4 = ft_strdup(long_str);
  printf("  Lengths match: %s\n",
         strlen(dup4) == strlen(long_str) ? "YES" : "NO");
  free(dup4);
}

void test_putnbr_base(void) {
  printf("\n=== FT_PUTNBR_BASE TESTS ===\n");

  printf("Test 1: Decimal base\n");
  printf("  Expected: 42, Got: ");
  ft_putnbr_base(42, "0123456789");
  printf("\n");

  printf("Test 2: Hexadecimal base (uppercase)\n");
  printf("  Expected: FF, Got: ");
  ft_putnbr_base(255, "0123456789ABCDEF");
  printf("\n");

  printf("Test 3: Binary base\n");
  printf("  Expected: 101010, Got: ");
  ft_putnbr_base(42, "01");
  printf("\n");

  printf("Test 4: Negative number (decimal)\n");
  printf("  Expected: -42, Got: ");
  ft_putnbr_base(-42, "0123456789");
  printf("\n");
}

void test_list_functions(void) {
  printf("\n=== LIST FUNCTION TESTS ===\n");

  printf("Test 1: List creation and push_front\n");
  t_list *list = NULL;
  ft_list_push_front(&list, "Node 3");
  ft_list_push_front(&list, "Node 2");
  ft_list_push_front(&list, "Node 1");

  printf("  List contents:\n");
  t_list *current = list;
  int count = 0;
  while (current) {
    printf("    %d: %s\n", count++, (char *)current->data);
    current = current->next;
  }

  printf("Test 2: List size\n");
  int size = ft_list_size(list);
  printf("  Expected: 3, Got: %d\n", size);

  printf("Test 3: List size with NULL\n");
  int empty_size = ft_list_size(NULL);
  printf("  Expected: 0, Got: %d\n", empty_size);

  // Cleanup
  while (list) {
    t_list *temp = list;
    list = list->next;
    free(temp);
  }
}

int main(void) {
  printf("################################\n");
  printf("  COMPREHENSIVE ASSEMBLY TESTS\n");
  printf("################################\n");

  test_strlen();
  test_write_read();
  test_strcpy();
  test_strcmp();
  test_strdup();
  test_putnbr_base();
  test_list_functions();

  printf("\n################################\n");
  printf("  ALL TESTS COMPLETED\n");
  printf("################################\n");

  return 0;
}