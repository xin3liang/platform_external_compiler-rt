#
# Copyright (C) 2012 The Android Open Source Project
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
#

LOCAL_PATH:= $(call my-dir)

ifeq ($(TARGET_ARCH),arm)

ASAN_NEEDS_SEGV=0
ASAN_HAS_EXCEPTIONS=1
ASAN_FLEXIBLE_MAPPING_AND_OFFSET=0

asan_rtl_files := \
	asan_activation.cc	\
	asan_allocator2.cc	\
	asan_fake_stack.cc \
	asan_globals.cc	\
	asan_interceptors.cc	\
	asan_linux.cc \
	asan_mac.cc \
	asan_malloc_linux.cc \
	asan_malloc_mac.cc \
	asan_malloc_win.cc \
	asan_new_delete.cc	\
	asan_poisoning.cc	\
	asan_posix.cc \
	asan_report.cc	\
	asan_rtl.cc \
	asan_stack.cc	\
	asan_stats.cc	\
	asan_thread.cc	\
	asan_win.cc \
	../interception/interception_linux.cc \
	../sanitizer_common/sanitizer_allocator.cc \
	../sanitizer_common/sanitizer_common.cc \
	../sanitizer_common/sanitizer_common_libcdep.cc \
	../sanitizer_common/sanitizer_coverage_libcdep.cc \
	../sanitizer_common/sanitizer_coverage_mapping_libcdep.cc \
	../sanitizer_common/sanitizer_deadlock_detector1.cc \
	../sanitizer_common/sanitizer_deadlock_detector2.cc \
	../sanitizer_common/sanitizer_flags.cc \
	../sanitizer_common/sanitizer_libc.cc \
	../sanitizer_common/sanitizer_libignore.cc \
	../sanitizer_common/sanitizer_linux.cc \
	../sanitizer_common/sanitizer_linux_libcdep.cc \
	../sanitizer_common/sanitizer_mac.cc \
	../sanitizer_common/sanitizer_persistent_allocator.cc \
	../sanitizer_common/sanitizer_platform_limits_linux.cc \
	../sanitizer_common/sanitizer_platform_limits_posix.cc \
	../sanitizer_common/sanitizer_posix.cc \
	../sanitizer_common/sanitizer_posix_libcdep.cc \
	../sanitizer_common/sanitizer_printf.cc \
	../sanitizer_common/sanitizer_procmaps_linux.cc \
	../sanitizer_common/sanitizer_procmaps_mac.cc \
	../sanitizer_common/sanitizer_stackdepot.cc \
	../sanitizer_common/sanitizer_stacktrace.cc \
	../sanitizer_common/sanitizer_stacktrace_libcdep.cc \
	../sanitizer_common/sanitizer_stoptheworld_linux_libcdep.cc \
	../sanitizer_common/sanitizer_suppressions.cc \
	../sanitizer_common/sanitizer_symbolizer.cc \
	../sanitizer_common/sanitizer_symbolizer_libbacktrace.cc \
	../sanitizer_common/sanitizer_symbolizer_libcdep.cc \
	../sanitizer_common/sanitizer_symbolizer_posix_libcdep.cc \
	../sanitizer_common/sanitizer_symbolizer_win.cc \
	../sanitizer_common/sanitizer_thread_registry.cc \
	../sanitizer_common/sanitizer_tls_get_addr.cc \
	../sanitizer_common/sanitizer_win.cc

asan_rtl_cflags := \
	-fvisibility=hidden \
	-fno-exceptions \
	-DASAN_LOW_MEMORY=1 \
	-DASAN_NEEDS_SEGV=$(ASAN_NEEDS_SEGV) \
	-DASAN_HAS_EXCEPTIONS=$(ASAN_HAS_EXCEPTIONS) \
	-DASAN_FLEXIBLE_MAPPING_AND_OFFSET=$(ASAN_FLEXIBLE_MAPPING_AND_OFFSET) \
	-Wno-covered-switch-default \
	-Wno-non-virtual-dtor \
	-Wno-sign-compare \
	-Wno-unused-parameter \
	-D__WORDSIZE=32

asan_test_files := \
	tests/asan_globals_test.cc \
	tests/asan_test.cc

#tests/asan_noinst_test.cc \
#tests/asan_test_main.cc \

asan_test_cflags := \
	-fsanitize-blacklist=external/compiler-rt/lib/asan/tests/asan_test.ignore \
	-DASAN_LOW_MEMORY=1 \
	-DASAN_UAR=0 \
	-DASAN_NEEDS_SEGV=$(ASAN_NEEDS_SEGV) \
	-DASAN_HAS_EXCEPTIONS=$(ASAN_HAS_EXCEPTIONS) \
	-DASAN_HAS_BLACKLIST=1 \
	-Wno-covered-switch-default \
	-Wno-non-virtual-dtor \
	-Wno-sign-compare \
	-Wno-unused-parameter \
	-D__WORDSIZE=32 \
	-std=c++11


include $(CLEAR_VARS)

LOCAL_MODULE := libasan
LOCAL_MODULE_TAGS := optional
LOCAL_C_INCLUDES := bionic external/compiler-rt/lib external/compiler-rt/include
LOCAL_CFLAGS += $(asan_rtl_cflags)
LOCAL_SRC_FILES := asan_preinit.cc
#LOCAL_SRC_FILES := asan_android_stub.cc asan_preinit.cc
LOCAL_CPP_EXTENSION := .cc
LOCAL_CLANG := true
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk
include $(BUILD_STATIC_LIBRARY)


include $(CLEAR_VARS)

LOCAL_MODULE := libasan_preload
LOCAL_MODULE_TAGS := eng
LOCAL_C_INCLUDES := \
  bionic \
  external/compiler-rt/lib \
  external/compiler-rt/include
LOCAL_CFLAGS += $(asan_rtl_cflags)
LOCAL_SRC_FILES := $(asan_rtl_files)
LOCAL_CPP_EXTENSION := .cc
LOCAL_SHARED_LIBRARIES := liblog libc libdl
LOCAL_CLANG := true
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk
include $(BUILD_SHARED_LIBRARY)


include $(CLEAR_VARS)

LOCAL_MODULE := asanwrapper
LOCAL_MODULE_TAGS := eng
LOCAL_C_INCLUDES := \
        bionic
LOCAL_SRC_FILES := asanwrapper.cc
LOCAL_CPP_EXTENSION := .cc
LOCAL_CPPFLAGS := -std=c++11
LOCAL_SHARED_LIBRARIES += libc
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk
include external/libcxx/libcxx.mk

include $(BUILD_EXECUTABLE)


include $(CLEAR_VARS)

LOCAL_MODULE := libasan_noinst_test
LOCAL_MODULE_TAGS := tests
LOCAL_C_INCLUDES := \
        bionic \
        external/gtest/include \
        external/compiler-rt/include \
        external/compiler-rt/lib \
	external/compiler-rt/lib/asan/tests \
	external/compiler-rt/lib/sanitizer_common/tests
LOCAL_CFLAGS += \
        -Wno-unused-parameter \
        -Wno-sign-compare \
        -DASAN_UAR=0 \
        -DASAN_HAS_BLACKLIST=1 \
	-DASAN_HAS_EXCEPTIONS=$(ASAN_HAS_EXCEPTIONS) \
	-DASAN_NEEDS_SEGV=$(ASAN_NEEDS_SEGV) \
        -D__WORDSIZE=32
LOCAL_SRC_FILES := tests/asan_noinst_test.cc tests/asan_test_main.cc
LOCAL_CPP_EXTENSION := .cc
LOCAL_CLANG := true
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk
include external/libcxx/libcxx.mk

include $(BUILD_STATIC_LIBRARY)


include $(CLEAR_VARS)

LOCAL_MODULE := asan_test
LOCAL_MODULE_TAGS := tests
LOCAL_C_INCLUDES := \
        bionic \
        external/gtest/include \
        external/compiler-rt/lib \
	external/compiler-rt/lib/asan/tests \
	external/compiler-rt/lib/sanitizer_common/tests
LOCAL_CFLAGS += $(asan_test_cflags)
LOCAL_SRC_FILES := $(asan_test_files)
LOCAL_CPP_EXTENSION := .cc
LOCAL_STATIC_LIBRARIES := libgtest_libc++ libasan_noinst_test
LOCAL_SHARED_LIBRARIES := libc
LOCAL_ADDRESS_SANITIZER := true
LOCAL_CLANG := true
LOCAL_ADDITIONAL_DEPENDENCIES := $(LOCAL_PATH)/Android.mk
include external/libcxx/libcxx.mk

include $(BUILD_EXECUTABLE)

endif # ifeq($(TARGET_ARCH),arm)
