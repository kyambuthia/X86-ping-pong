AS ?= as
CC ?= gcc
LD ?= ld
BUILD := build

.PHONY: all clean test

all: $(BUILD)/x86pay_server $(BUILD)/x86pay_client

test: all
	./tests/integration.sh

$(BUILD):
	mkdir -p $(BUILD)

$(BUILD)/server.o: server/x86pay_server.s | $(BUILD)
	$(CC) -x assembler-with-cpp -c $< -o $@

$(BUILD)/client.o: client/x86pay_client.s | $(BUILD)
	$(CC) -x assembler-with-cpp -c $< -o $@

$(BUILD)/x86pay_server: $(BUILD)/server.o
	$(LD) -o $@ $<

$(BUILD)/x86pay_client: $(BUILD)/client.o
	$(LD) -o $@ $<

clean:
	rm -rf $(BUILD)
