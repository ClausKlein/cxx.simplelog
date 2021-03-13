#

#XXX GENERATOR?="Unix Makefiles"
GENERATOR?=Ninja

STAGEDIR?=$(CURDIR)/stage
BUILD_TYPE?=Debug
CMAKE_PRESET:=-G "$(GENERATOR)" -DCMAKE_EXPORT_COMPILE_COMMANDS=1 -DCMAKE_BUILD_TYPE=$(BUILD_TYPE) -DCMAKE_PREFIX_PATH=$(STAGEDIR)
# Note: not needed -DCMAKE_CXX_COMPILER_LAUNCHER=ccache

#XXX export CXX=clang++
export CPM_USE_LOCAL_PACKAGES=0
export CPM_SOURCE_CACHE=${HOME}/.cache/CPM

PROJECT_NAME:=$(shell basename $(CURDIR))
BUILD_DIR?=../build-$(PROJECT_NAME)-$(CXX)-$(BUILD_TYPE)

.PHONY: update format all test examples check clean distclean

# the default target does just all
all: install

clean:
	rm -rf $(BUILD_DIR)

distclean: clean
	rm -rf ${STAGEDIR}

# update CPM.cmake
update:
	wget -q -O cmake/CPM.cmake https://github.com/cpm-cmake/CPM.cmake/releases/latest/download/get_cpm.cmake

# install the library to stagedir
install:
	cmake -S . -B $(BUILD_DIR)/$@ ${CMAKE_PRESET} -DCMAKE_INSTALL_PREFIX=${STAGEDIR} -DCMAKE_CXX_STANDARD=20 #NO! -DCMAKE_CXX_CLANG_TIDY=clang-tidy # --trace-expand
	cmake --build $(BUILD_DIR)/$@ --target all
	cmake --build $(BUILD_DIR)/$@ --target test
	cmake --build $(BUILD_DIR)/$@ --target $@
	perl -i.bak -pe 's#-I($$CPM_SOURCE_CACHE)#-isystem $$1#g' $(BUILD_DIR)/$@/compile_commands.json
	run-clang-tidy.py -p $(BUILD_DIR)/$@ -quiet -header-filter='$(CURDIR)/.*' tests    # Note: only local sources! CK

format: distclean
	find . -name CMakeLists.txt | xargs cmake-format -i
	find . -type f -name '*.cmake' | xargs cmake-format -i
	find . -name '*.cpp' | xargs clang-format -i
	find . -name '*.h' | xargs clang-format -i

test: examples
	cmake --build $(BUILD_DIR)/examples --target test

examples: install
	cmake -S $@ -B $(BUILD_DIR)/$@ ${CMAKE_PRESET}
	perl -i.bak -pe 's#-I($$CPM_SOURCE_CACHE)#-isystem $$1#g' $(BUILD_DIR)/$@/compile_commands.json
	cmake --build $(BUILD_DIR)/$@

# check the library
check: examples
	run-clang-tidy.py -p $(BUILD_DIR)/examples -quiet -header-filter='$(CURDIR)/.*' -checks='-*,modernize-*,misc-*,hicpp-*,cert-*,readability-*,portability-*,performance-*,google-*' examples
