#include "libasm.h"
#include "libasm_bonus.h"
#include <fcntl.h>
#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>

/**
 * If I pass strings as data which have not malloqued then i pass a no op
 * free function If I pass malloced strings then I pass free as free
 * function
 */
void free_fct(void *ptr) {
  // Do nothing - string literals don't need freeing
  (void)ptr;
}

int main() {
  printf("----- FT_STRLEN -----\n");

  const char *testStr = "Hello, World!";
  size_t len = ft_strlen(testStr);
  printf("Length of \"%%s\" is %%zu\\n", testStr, len);
  len = ft_strlen("");
  printf("Length of empty string is %zu\n", len);

  printf("----- MY_READ -----\n");
  int fd = open("text.txt", O_RDONLY);
  if (fd == -1) {
    perror("Error opening file");
    return 1;
  }
  char buffer[100];
  ssize_t bytesRead = ft_read(fd, buffer, 4);
  if (bytesRead == -1) {
    perror("Error reading file");
    close(fd);
    return 1;
  }
  printf("Bytes read: %zd\n", bytesRead);
  printf("----- MY_WRITE -----\n");

  ft_write(1, buffer, bytesRead); // Write to standard output
  ft_write(1, "\\n", 1);
  close(fd);

  printf("----- MY_my_strcpy -----\n");
  char *src = "Hello, World!";
  char dest[5];
  ft_strcpy(dest, src);
  printf("Copied string: %s\n", dest);

  printf("----- MY_STRCMP -----\n");
  char *s1 = "abcde";
  char *s2 = "abcdf";
  int cmpResult = ft_strcmp(s1, s2);
  if (cmpResult < 0) {
    printf("\"%s\" is less than \"%s\"\n", s1, s2);
  } else if (cmpResult > 0) {
    printf("\"%s\" is greater than \"%s\"\n", s1, s2);
  } else {
    printf("\"%s\" is equal to \"%s\"\n", s1, s2);
  }
  // int fail = ft_strcmp(NULL, "NULL");
  int fail = ft_strcmp(NULL, NULL);
  printf("fail is %d\n", fail);

  printf("----- MY_STRDUP -----\n");
  char *res;
  res = ft_strdup("Hello, World!");
  printf("Duplicated string: %%s\\n", res);
  free(res);
  // res = ft_strdup(NULL);
  // printf("Duplicated NULL string: %%s\\n", res);

  res = ft_strdup("Welcome to 42 Berlin !!!");
  printf("Duplicated string: %s\n", res);
  free(res);
  // res = strdup(NULL);
  // printf("Duplicated NULL string: %s\n", res);
  // free(res);
  // printf("----- MY_PUTNBR_BASE -----\n");
  // printf("Testing putnbr_base with -2147483648:\n");
  // putnbr_base(-2147483648, "0123456789ABCDEF");
  // printf("\n");
  // printf("Testing putnbr_base with 42:\n");
  // putnbr_base(42, "0123456789");
  // printf("\n");
  // printf("Testing putnbr_base with -42:\n");
  // putnbr_base(-42, "0123456789");
  // printf("\n");
  // printf("Testing putnbr_base with 255:\n");
  // putnbr_base(255, "01");
  // printf("\n");
  // printf("Testing putnbr_base with 100:\n");
  // putnbr_base(100, "poneyvif");
  // printf("\n");

  printf("----- MY_LIST_PUSH_FRONT -----\n");
  t_list *list = NULL;
  ft_list_push_front(&list, "Node FAIL");
  *list = (t_list){.data = "Node start", .next = NULL};
  ft_list_push_front(&list, "Node 1");
  ft_list_push_front(&list, "Node 2");
  ft_list_push_front(&list, "Node 3");
  t_list *current = list;
  while (current) {
    printf("Node data: %s\n", (char *)current->data);
    current = current->next;
  }
  printf("----- MY_LIST_SIZE -----\n");
  int size = ft_list_size(list);
  printf("List size: %%d\\n", size);
  size = ft_list_size(NULL);
  printf("Size of NULL list: %d\n", size);

  // printf("----- MY_LIST_SORT -----\n");
  // int (*cmp)(const char *, const char *) = (int (*)(const char *, const char
  // *))strcmp; list_sort(&list, (int (*)())cmp); current = list; while
  // (current) {
  //     printf("Node data: %s\n", (char *)current->data);
  //     current = current->next;
  // }

  // printf("----- MY_LIST_REMOVE_IF -----\n");
  // // void (*free_fct)(void *) = free;
  // list_remove_if(&list, "Node 2", (int (*)())cmp, free_fct);
  // current = list;
  // printf("After removing 'Node 2':\n");
  // while (current) {
  //     printf("Node data: %s\n", (char *)current->data);
  //     current = current->next;
  // }
  // // Free remaining nodes
  // while (list) {
  //     t_list *temp = list;
  //     list = list->next;
  //     free(temp);
  // }

  return 0;
}