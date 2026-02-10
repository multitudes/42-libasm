#ifndef LIBASM_H
#define LIBASM_H

#include <stdlib.h>

size_t  strlen(const char *s);
char*   my_strcpy(char *dest, const char *src);
int     strcmp(const char *s1, const char *s2);
ssize_t write(int fd, const void *buf, size_t count);
ssize_t read(int fd, void *buf, size_t count);
char *  strdup(const char *s);

typedef struct      s_list {
    void            *data;
    struct s_list   *next;
}                   t_list;

void    putnbr_base(int nbr, char *base);
void    list_push_front(t_list **begin_list, void *data);
int     list_size(t_list *begin_list);
void    list_sort(t_list **begin_list, int (*cmp)());
void    list_remove_if(t_list **begin_list, void *data_ref, int (*cmp)(), void (*free_fct)(void *));


#endif