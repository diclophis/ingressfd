# Makefile

product=ingressfd
build=build/$(product)-build
target=$(build)/$(product)
mruby_static_lib=mruby/build/host/lib/libmruby.a
ssl_static_lib=$(build)/libressl/lib/libtls.a
#build/libressl/lib/libcrypto.a build/libressl/lib/libssl.a
mrbc=mruby/bin/mrbc

sources = $(wildcard *.c)
objects = $(patsubst %,$(build)/%, $(patsubst %.c,%.o, $(sources)))
static_ruby_headers = $(patsubst %,$(build)/%, $(patsubst lib/%.rb,%.h, $(wildcard lib/*.rb)))
.SECONDARY: $(static_ruby_headers) $(objects)
objects += $(mruby_static_lib)
objects += $(ssl_static_lib)
objects += $(build)/libressl/lib/libcrypto.a $(build)/libressl/lib/libssl.a
objects += mruby/build/host/mrbgems/mruby-uv/libuv-1.0.0/.libs/libuv.a

LDFLAGS=-lm -lpthread -ldl $(shell (uname | grep -q Darwin || echo -lrt -static) )

CFLAGS=-std=c99 -Imruby/include -I$(build) -I$(build)/libressl/include

$(shell mkdir -p $(build))

docker-build: $(target) $(sources)
	(echo $(LDFLAGS) | grep -q static && docker build .) || echo you must build on linux

$(target): $(objects) $(sources)
	$(CC) -o $@ $(objects) $(LDFLAGS)

$(build)/test.yml: $(target) config.ru
	$(target) > $@

clean:
	cd mruby && make clean
	rm -R $(build)

$(build):
	mkdir -p $(build)

$(build)/%.o: %.c $(static_ruby_headers) $(sources)
	$(CC) $(CFLAGS) -c $< -o $@

$(mruby_static_lib): config/mruby.rb
	cd mruby && MRUBY_CONFIG=../config/mruby.rb make

$(mrbc): $(mruby_static_lib)

$(build)/%.h: lib/%.rb $(mrbc)
	mruby/bin/mrbc -g -B $(patsubst $(build)/%.h,%, $@) -o $@ $<

$(build)/libressl/lib/libtls.a:
	cd libressl && sh autogen.sh
	cd libressl && ./configure  --prefix=$(PWD)/$(build)/libressl --enable-shared=no
	cd libressl && make
	cd libressl && make install
