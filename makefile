ASM_DIR = libasm-x86-64
ASM = nasm
ASM_FLAGS = -f elf64

NAME = $(ASM_DIR)/libasm.a

# Mandatory functions
SRCS_BASE = $(addprefix $(ASM_DIR)/, ft_strlen.s ft_write.s ft_read.s ft_strcpy.s ft_strdup.s ft_strcmp.s ft_atoi_base.s)
OBJS_BASE = $(SRCS_BASE:.s=.o)

# Bonus functions
SRCS_BONUS = $(addprefix $(ASM_DIR)/, ft_atoi_base.s ft_list_push_front.s ft_list_size.s ft_list_sort.s ft_list_remove_if.s)
OBJS_BONUS = $(SRCS_BONUS:.s=.o)

# By default, only use base
OBJS = $(OBJS_BASE)

all: $(NAME)

bonus: OBJS = $(OBJS_BASE) $(OBJS_BONUS)
bonus: fclean $(NAME)

$(NAME): $(OBJS)
	ar rcs $@ $^

%.o: %.s
	$(ASM) $(ASM_FLAGS) $< -o $@

clean:
	rm -f $(OBJS_BASE) $(OBJS_BONUS) 

fclean: clean
	rm -f $(NAME)
	rm -f test

re: fclean all

test: all main.c
	gcc main.c -L$(ASM_DIR) -lasm -o test
	./test

.PHONY: all clean fclean re bonus test
