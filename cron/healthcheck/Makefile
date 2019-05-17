.PHONY: all deps compress clean

BUILD := healthcheck
DEPS := $(BUILD).go

export CGO_ENABLED=0

all: $(BUILD)

deps:
	go get golang.org/x/lint/golint
	go get -d -v

compress: $(BUILD)
	upx -q --brute $(BUILD)
	upx -t $(BUILD)

$(BUILD): $(DEPS)
	golint $?
	go vet $?
	gofmt -d $?
	@test -z `gofmt -l $?`
	go build -ldflags "-w -s" -a -installsuffix cgo -o $@

clean:
	rm -f $(BUILD)
