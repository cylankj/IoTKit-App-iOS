SET ( name msgpack-c )
PROJECT ( ${name} CXX )

FILE ( GLOB header *.h )
FILE ( GLOB source_c *.c )
FILE ( GLOB source_cxx *.cpp )

SET_SOURCE_FILES_PROPERTIES ( ${source_c} PROPERTIES LANGUAGE CXX )

ADD_DEFINITIONS ( -D_LIB )

#SET ( VERSION "0.5.7" )
#SET ( MSGPACK_VERSION_MAJOR 0 )
#SET ( MSGPACK_VERSION_MINOR 5 )

INCLUDE_DIRECTORIES ( ${CMAKE_CURRENT_SOURCE_DIR}/include )
INCLUDE_DIRECTORIES ( ${CMAKE_CURRENT_SOURCE_DIR}/include/msgpack )

ADD_LIBRARY ( ${name} STATIC ${header} ${source_c} ${source_cxx} )

IF ( USE_PCLINT )
  ADD_PC_LINT ( ${name} ${allsrc} )
ENDIF ( USE_PCLINT )