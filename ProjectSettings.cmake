# Please see Documentation/quasarBuildSystem.html for
# information how to use this file.
set(CUSTOM_SERVER_MODULES GpibPowerSupply)
set(EXECUTABLE OpcUaServer)
set(SERVER_INCLUDE_DIRECTORIES  )
set(SERVER_LINK_LIBRARIES -lgpib )
set(SERVER_LINK_DIRECTORIES  )

# If ON, in addition to an executable, a shared object will be created.
set(BUILD_SERVER_SHARED_LIB OFF)
