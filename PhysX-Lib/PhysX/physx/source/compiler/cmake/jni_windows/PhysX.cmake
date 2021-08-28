##
## Redistribution and use in source and binary forms, with or without
## modification, are permitted provided that the following conditions
## are met:
##  * Redistributions of source code must retain the above copyright
##    notice, this list of conditions and the following disclaimer.
##  * Redistributions in binary form must reproduce the above copyright
##    notice, this list of conditions and the following disclaimer in the
##    documentation and/or other materials provided with the distribution.
##  * Neither the name of NVIDIA CORPORATION nor the names of its
##    contributors may be used to endorse or promote products derived
##    from this software without specific prior written permission.
##
## THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS ``AS IS'' AND ANY
## EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
## IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR
## PURPOSE ARE DISCLAIMED.  IN NO EVENT SHALL THE COPYRIGHT OWNER OR
## CONTRIBUTORS BE LIABLE FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL,
## EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT NOT LIMITED TO,
## PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE, DATA, OR
## PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY THEORY
## OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
## (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
## OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
##
## Copyright (c) 2018-2019 NVIDIA Corporation. All rights reserved.

#
# Build PhysX (PROJECT not SOLUTION)
#

IF(PX_USE_NVTX)
	FIND_PACKAGE(nvToolsExt $ENV{PM_nvToolsExt_VERSION} REQUIRED)
	MESSAGE("Using nvtx lib: ${NVTOOLSEXT_LIB} path: ${NVTOOLSEXTSDK_PATH}")
	SET(NV_TOOLS_EXT_LIB ${NVTOOLSEXT_LIB})
ENDIF()

SET(PHYSX_PLATFORM_INCLUDES
	${NVTOOLSEXT_INCLUDE_DIRS}
)

SET(PHYSX_GPU_HEADERS
	${PHYSX_ROOT_DIR}/include/gpu/PxGpu.h
)
SOURCE_GROUP(include\\gpu FILES ${PHYSX_GPU_HEADERS})

SET(PHYSX_CUDACONTEXT_MANAGER_GPU_HEADERS
	${PHYSX_ROOT_DIR}/include/cudamanager/PxCudaContextManager.h
	${PHYSX_ROOT_DIR}/include/cudamanager/PxCudaMemoryManager.h
)
SOURCE_GROUP(include\\cudamanager FILES ${PHYSX_CUDACONTEXT_MANAGER_GPU_HEADERS})

SET(PHYSX_COMMON_WINDOWS_HEADERS
	${PHYSX_ROOT_DIR}/include/common/windows/PxWindowsDelayLoadHook.h
)
SOURCE_GROUP(include\\common\\windows FILES ${PHYSX_COMMON_WINDOWS_HEADERS})

SET(PHYSX_RESOURCE
	${PHYSX_SOURCE_DIR}/compiler/resource_${RESOURCE_LIBPATH_SUFFIX}/PhysX.rc
	${PHYSX_SOURCE_DIR}/compiler/resource_${RESOURCE_LIBPATH_SUFFIX}/resource.h
)
SOURCE_GROUP(resource FILES ${PHYSX_RESOURCE})

SET(PHYSX_DEVICE_SOURCE
	${PX_SOURCE_DIR}/device/nvPhysXtoDrv.h
	${PX_SOURCE_DIR}/device/PhysXIndicator.h
	${PX_SOURCE_DIR}/device/windows/PhysXIndicatorWindows.cpp
)
SOURCE_GROUP(src\\device FILES ${PHYSX_DEVICE_SOURCE})

SET(PHYSX_GPU_SOURCE
	${PX_SOURCE_DIR}/gpu/PxGpu.cpp
	${PX_SOURCE_DIR}/gpu/PxPhysXGpuModuleLoader.cpp
)
SOURCE_GROUP(src\\gpu FILES ${PHYSX_GPU_SOURCE})

SET(PHYSX_WINDOWS_SOURCE
	${PX_SOURCE_DIR}/windows/NpWindowsDelayLoadHook.cpp	
)
SOURCE_GROUP(src\\windows FILES ${PHYSX_WINDOWS_SOURCE})

IF(PX_GENERATE_STATIC_LIBRARIES)
	SET(PHYSX_PLATFORM_OBJECT_FILES
		$<TARGET_OBJECTS:LowLevel>
		$<TARGET_OBJECTS:LowLevelAABB>
		$<TARGET_OBJECTS:LowLevelDynamics>
		$<TARGET_OBJECTS:PhysXTask>
		$<TARGET_OBJECTS:SceneQuery>
		$<TARGET_OBJECTS:SimulationController>	
		$<TARGET_OBJECTS:PhysXVehicle>
	)
ENDIF()

SET(PHYSX_PLATFORM_SRC_FILES
	${PHYSX_GPU_HEADERS}
	${PHYSX_CUDACONTEXT_MANAGER_GPU_HEADERS}
	${PHYSX_RESOURCE}
	${PHYSX_COMMON_WINDOWS_HEADERS}
	
	${PHYSX_DEVICE_SOURCE}
	${PHYSX_GPU_SOURCE}

	${PHYSX_WINDOWS_SOURCE}
	
	${PHYSX_PLATFORM_OBJECT_FILES}	
)

INSTALL(FILES ${PHYSX_GPU_HEADERS} DESTINATION include/gpu)
INSTALL(FILES ${PHYSX_CUDACONTEXT_MANAGER_GPU_HEADERS} DESTINATION include/cudamanager)
INSTALL(FILES ${PHYSX_COMMON_WINDOWS_HEADERS} DESTINATION include/common/windows)

IF(NV_USE_GAMEWORKS_OUTPUT_DIRS)
	SET(BITNESS_STRING $<$<BOOL:${CMAKE_CL_64}>:64>$<$<NOT:${CMAKE_CL_64}>:32>)
	SET(PHYSX_GPU_SHARED_LIB_NAME_DEF PX_PHYSX_GPU_SHARED_LIB_NAME=PhysXGpu_${BITNESS_STRING}.dll)
ELSE()
	SET(CONFIG_STRING $<$<CONFIG:debug>:DEBUG>$<$<CONFIG:checked>:CHECKED>$<$<CONFIG:profile>:PROFILE>)
	SET(BITNESS_STRING $<$<BOOL:${CMAKE_CL_64}>:x64>$<$<NOT:${CMAKE_CL_64}>:x86>)
	SET(PHYSX_GPU_SHARED_LIB_NAME_DEF PX_PHYSX_GPU_SHARED_LIB_NAME=PhysXGpu${CONFIG_STRING}_${BITNESS_STRING}.dll)
ENDIF()

IF(NOT PX_GENERATE_STATIC_LIBRARIES)
	SET(PXPHYSX_LIBTYPE_DEFS
		PX_PHYSX_FOUNDATION_EXPORTS;PX_PHYSX_CORE_EXPORTS;
	)
ENDIF()

SET(PHYSX_COMPILE_DEFS
	# Common to all configurations
	${PHYSX_WINDOWS_COMPILE_DEFS};${PXPHYSX_LIBTYPE_DEFS};${PHYSX_GPU_SHARED_LIB_NAME_DEF};${PHYSX_LIBTYPE_DEFS};${PHYSXGPU_LIBTYPE_DEFS}

	$<$<CONFIG:debug>:${PHYSX_WINDOWS_DEBUG_COMPILE_DEFS};>
	$<$<CONFIG:checked>:${PHYSX_WINDOWS_CHECKED_COMPILE_DEFS};>
	$<$<CONFIG:profile>:${PHYSX_WINDOWS_PROFILE_COMPILE_DEFS};>
	$<$<CONFIG:release>:${PHYSX_WINDOWS_RELEASE_COMPILE_DEFS};>
)

IF(PX_GENERATE_STATIC_LIBRARIES)
	SET(PHYSX_LIBTYPE STATIC)
ELSE()
	SET(PHYSX_LIBTYPE SHARED)
ENDIF()

IF(PX_GENERATE_GPU_PROJECTS)
	SET(PHYSX_PLATFORM_LINK_FLAGS "/DELAYLOAD:nvcuda.dll")
ENDIF()

IF(NOT PX_GENERATE_STATIC_LIBRARIES)
	SET(PHYSX_PRIVATE_PLATFORM_LINKED_LIBS
			LowLevel LowLevelAABB LowLevelDynamics PhysXTask SceneQuery SimulationController ${NV_TOOLS_EXT_LIB}
	)
ENDIF()

IF(NV_USE_GAMEWORKS_OUTPUT_DIRS AND PHYSX_LIBTYPE STREQUAL "STATIC")
	SET(PHYSX_COMPILE_PDB_NAME_DEBUG "PhysX_static${CMAKE_DEBUG_POSTFIX}")
	SET(PHYSX_COMPILE_PDB_NAME_CHECKED "PhysX_static${CMAKE_CHECKED_POSTFIX}")
	SET(PHYSX_COMPILE_PDB_NAME_PROFILE "PhysX_static${CMAKE_PROFILE_POSTFIX}")
	SET(PHYSX_COMPILE_PDB_NAME_RELEASE "PhysX_static${CMAKE_RELEASE_POSTFIX}")
ELSE()
	SET(PHYSX_COMPILE_PDB_NAME_DEBUG "PhysX${CMAKE_DEBUG_POSTFIX}")
	SET(PHYSX_COMPILE_PDB_NAME_CHECKED "PhysX${CMAKE_CHECKED_POSTFIX}")
	SET(PHYSX_COMPILE_PDB_NAME_PROFILE "PhysX${CMAKE_PROFILE_POSTFIX}")
	SET(PHYSX_COMPILE_PDB_NAME_RELEASE "PhysX${CMAKE_RELEASE_POSTFIX}")
ENDIF()

SET(PHYSX_PLATFORM_LINK_FLAGS "/MAP")

IF(PHYSX_LIBTYPE STREQUAL "SHARED")
	INSTALL(FILES $<TARGET_PDB_FILE:PhysX> 
		DESTINATION $<$<CONFIG:debug>:${PX_ROOT_LIB_DIR}/debug>$<$<CONFIG:release>:${PX_ROOT_LIB_DIR}/release>$<$<CONFIG:checked>:${PX_ROOT_LIB_DIR}/checked>$<$<CONFIG:profile>:${PX_ROOT_LIB_DIR}/profile> OPTIONAL)
		
	SET(PHYSX_PLATFORM_LINK_FLAGS_DEBUG "/DELAYLOAD:PhysXFoundation${CMAKE_DEBUG_POSTFIX}.dll /DELAYLOAD:PhysXCommon${CMAKE_DEBUG_POSTFIX}.dll")
	SET(PHYSX_PLATFORM_LINK_FLAGS_CHECKED "/DELAYLOAD:PhysXFoundation${CMAKE_CHECKED_POSTFIX}.dll /DELAYLOAD:PhysXCommon${CMAKE_CHECKED_POSTFIX}.dll")
	SET(PHYSX_PLATFORM_LINK_FLAGS_PROFILE "/DELAYLOAD:PhysXFoundation${CMAKE_PROFILE_POSTFIX}.dll /DELAYLOAD:PhysXCommon${CMAKE_PROFILE_POSTFIX}.dll")
	SET(PHYSX_PLATFORM_LINK_FLAGS_RELEASE "/DELAYLOAD:PhysXFoundation${CMAKE_RELEASE_POSTFIX}.dll /DELAYLOAD:PhysXCommon${CMAKE_RELEASE_POSTFIX}.dll")		
ELSE()	
	INSTALL(FILES ${PHYSX_ROOT_DIR}/$<$<CONFIG:debug>:${PX_ROOT_LIB_DIR}/debug>$<$<CONFIG:release>:${PX_ROOT_LIB_DIR}/release>$<$<CONFIG:checked>:${PX_ROOT_LIB_DIR}/checked>$<$<CONFIG:profile>:${PX_ROOT_LIB_DIR}/profile>/$<$<CONFIG:debug>:${PHYSX_COMPILE_PDB_NAME_DEBUG}>$<$<CONFIG:checked>:${PHYSX_COMPILE_PDB_NAME_CHECKED}>$<$<CONFIG:profile>:${PHYSX_COMPILE_PDB_NAME_PROFILE}>$<$<CONFIG:release>:${PHYSX_COMPILE_PDB_NAME_RELEASE}>.pdb
		DESTINATION $<$<CONFIG:debug>:${PX_ROOT_LIB_DIR}/debug>$<$<CONFIG:release>:${PX_ROOT_LIB_DIR}/release>$<$<CONFIG:checked>:${PX_ROOT_LIB_DIR}/checked>$<$<CONFIG:profile>:${PX_ROOT_LIB_DIR}/profile> OPTIONAL)
ENDIF()
