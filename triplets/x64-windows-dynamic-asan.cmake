# from upstream x64-windows.cmake
set(VCPKG_TARGET_ARCHITECTURE x64)
set(VCPKG_CRT_LINKAGE dynamic)
set(VCPKG_LIBRARY_LINKAGE dynamic)

# custom
set(VCPKG_C_FLAGS /fsanitize=address)
set(VCPKG_CXX_FLAGS /fsanitize=address)
if(PORT MATCHES "icu")
    # icudt uses /NOENTRY when it's a DLL, which is apparently incompatible with ASAN
    set(VCPKG_LIBRARY_LINKAGE static)
endif()
