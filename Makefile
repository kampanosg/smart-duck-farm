.PHONY: install
install:
	yarn install

.PHONY: compile
compile:
	npx hardhat compile

.PHONY: test
test:
	npx hardhat test

.PHONY: clean
clean:
	npx hardhat clean

.PHONY: up
up:
	npx hardhat node