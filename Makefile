SRC_DIR := src
BUILD_DIR := build
ASM_FILE := $(SRC_DIR)/main.asm
OBJ := $(BUILD_DIR)/main.o
BIN := $(BUILD_DIR)/main
FORMAT := elf64

.PHONY: all clean

all: $(BIN)

# 创建build目录
$(BUILD_DIR):
    mkdir -p $(BUILD_DIR)

# 汇编阶段
$(OBJ): $(ASM_FILE) | $(BUILD_DIR)
    nasm -f $(FORMAT) -g -F dwarf $< -o $@

# 链接阶段
$(BIN): $(OBJ)
    ld $(OBJ) -o $(BIN)

# 清理产物
clean:
    rm -rf $(BUILD_DIR)