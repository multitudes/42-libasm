#include "libasm.h"
#include "libasm_bonus.h"
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

/*
Comprehensive test suite for libasm functions
*/

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
      ssize_t r = ft_read(fd, buffer, sizeof(buffer) - 1);
      if (r >= 0)
        buffer[r] = '\0';
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

void test_atoi_base(void) {
  printf("\n=== FT_ATOI_BASE TESTS ===\n");

  printf("Test 1: Decimal base\n");
  int num1 = ft_atoi_base("42", "0123456789");
  printf("  Expected: 42, Got: %d\n", num1);

  printf("Test 2: Hexadecimal base (uppercase)\n");
  int num2 = ft_atoi_base("FF", "0123456789ABCDEF");
  printf("  Expected: 255, Got: %d\n", num2);

  printf("Test 3: Binary base\n");
  int num3 = ft_atoi_base("101010", "01");
  printf("  Expected: 42, Got: %d\n", num3);

  printf("Test 4: Negative number\n");
  int num4 = ft_atoi_base("-2A", "0123456789ABCDEF");
  printf("  Expected: -42, Got: %d\n", num4);

  printf("Test 5: With leading whitespace and sign\n");
  int num5 = ft_atoi_base("   +10", "0123456789");
  printf("  Expected: 10, Got: %d\n", num5);

  printf("Test 6: Invalid base (duplicate)\n");
  int num6 = ft_atoi_base("42", "01234567899");
  printf("  Expected: 0 (invalid base), Got: %d\n", num6);

  printf("Test 7: Invalid base (contains +)\n");
  int num7 = ft_atoi_base("42", "0123456789+");
  printf("  Expected: 0 (invalid base), Got: %d\n", num7);

  printf("Test 8: Invalid base (single character)\n");
  int num8 = ft_atoi_base("42", "0");
  printf("  Expected: 0 (invalid base), Got: %d\n", num8);
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

// Comparison function to feed into ft_list_sort
// Returns > 0 if s1 should come after s2 (standard alphabetical sort)
int compare_strings(const char *s1, const char *s2) { return strcmp(s1, s2); }

// Helper function to cleanly print the entire list
void print_list(t_list *list) {
  t_list *current = list;
  int count = 0;
  if (!current) {
    printf("    (List is completely empty)\n");
    return;
  }
  while (current) {
    printf("    Node %d: %s\n", count++, (char *)current->data);
    current = current->next;
  }
}

// Custom free function: frees dynamically allocated string data
void free_node_data(void *data) {
  printf("    [free_fct called] Freeing data payload: %s\n", (char *)data);
  free(data);
}

// Helper to push a freshly allocated string onto the list
void push_heap_string(t_list **list, const char *str) {
  t_list *new_node = malloc(sizeof(t_list));
  if (!new_node)
    return;
  new_node->data = strdup(str); // Allocates string data on the heap
  new_node->next = *list;
  *list = new_node;
}

void test_list_sort_functions(void) {
  printf("\n=== LIBASM LIST FUNCTION TESTS ===\n");

  // ----------------------------------------------------
  printf("\nTest 1: List creation and push_front\n");
  t_list *list = NULL;

  // Pushing elements (should arrive in reverse order)
  ft_list_push_front(&list, "Zebra");
  ft_list_push_front(&list, "Monkey");
  ft_list_push_front(&list, "Apple");

  printf("  Current List contents (expected: Apple -> Monkey -> Zebra):\n");
  print_list(list);

  // ----------------------------------------------------
  printf("\nTest 2: List size calculation\n");
  int size = ft_list_size(list);
  printf("  Expected size: 3, Got: %d\n", size);

  printf("\nTest 3: List size with NULL\n");
  int empty_size = ft_list_size(NULL);
  printf("  Expected size: 0, Got: %d\n", empty_size);

  // ----------------------------------------------------
  printf("\nTest 4: List sorting (ft_list_sort_bonus)\n");

  // Let's add an unsorted node right to the front to really test it
  ft_list_push_front(&list, "Banana");
  printf("  Before Sort:\n");
  print_list(list);

  // Call your refactored assembly sort routine
  ft_list_sort(&list, compare_strings);

  printf("  After Sort (expected: Apple -> Banana -> Monkey -> Zebra):\n");
  print_list(list);

  // ----------------------------------------------------
  printf("\nTest 5: Sorting empty and single-element lists\n");
  t_list *empty_list = NULL;
  ft_list_sort(&empty_list, compare_strings);
  printf("  Empty list sort safely passed (didn't crash).\n");

  t_list *single_list = NULL;
  ft_list_push_front(&single_list, "Solo Node");
  ft_list_sort(&single_list, compare_strings);
  printf("  Single node list sort safely passed:\n");
  print_list(single_list);

  // ----------------------------------------------------
  // Cleanup heap memory allocation
  while (list) {
    t_list *temp = list;
    list = list->next;
    free(temp);
  }
  free(single_list);

  printf("\n=== TESTS COMPLETE ===\n");
}

void test_list_remove_if(void) {
  printf("\n=== LIBASM ft_list_remove_if TESTS ===\n");

  t_list *list = NULL;

  // Populating a list with heap-allocated strings
  // List order will be: "Target" -> "Apple" -> "Target" -> "Target" -> "Orange"
  // -> NULL
  push_heap_string(&list, "Orange");
  push_heap_string(&list, "Target"); // Back-to-back duplicate test
  push_heap_string(&list, "Target");
  push_heap_string(&list, "Apple");
  push_heap_string(&list, "Target"); // Head element test

  printf("\nInitial List before removal:\n");
  print_list(list);

  // ----------------------------------------------------
  printf("\nExecuting ft_list_remove_if for value: \"Target\"\n");

  // Call your assembly function
  // Expecting: "Target" at the head, middle, and back-to-back nodes to be
  // removed and freed.
  ft_list_remove_if(&list, "Target", compare_strings, free_node_data);

  printf("\nList after removal (Expected: Apple -> Orange):\n");
  print_list(list);

  // ----------------------------------------------------
  printf("\nTesting edge case: Removing remaining nodes to empty the list\n");

  printf("Removing \"Apple\"...\n");
  ft_list_remove_if(&list, "Apple", compare_strings, free_node_data);

  printf("Removing \"Orange\"...\n");
  ft_list_remove_if(&list, "Orange", compare_strings, free_node_data);

  printf("\nFinal List state:\n");
  print_list(list);

  // ----------------------------------------------------
  printf("\nTesting safety edge case: Passing a NULL list pointer\n");
  t_list *null_list = NULL;
  ft_list_remove_if(&null_list, "Anything", compare_strings, free_node_data);
  printf("  Passed safely without crashing!\n");

  printf("\n=== TESTS COMPLETE ===\n");
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
  test_atoi_base();
  test_list_functions();
  test_list_sort_functions();
  test_list_remove_if();

  printf("\n################################\n");
  printf("  ALL TESTS COMPLETED\n");
  printf("################################\n");

  return 0;
}