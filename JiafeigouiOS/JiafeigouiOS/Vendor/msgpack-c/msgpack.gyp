# Copyright (c) 2012 The WebRTC project authors. All Rights Reserved.
#
# Use of this source code is governed by a BSD-style license
# that can be found in the LICENSE file in the root of the source
# tree. An additional intellectual property rights grant can be found
# in the file PATENTS.  All contributing project authors may
# be found in the AUTHORS file in the root of the source tree.
{
  'includes':[
    '../build/common.gypi',
  ],  

	'targets': [
    {
		'target_name': 'msgpack',
		'type': 'static_library',
		'include_dirs':[
			'include',
		],
		'direct_dependent_settings': {
			'include_dirs':[
				'include',
			],
      'defines':[
          'WITH_MSGPACK=1',
      ],
		},
		'sources': [
			'gcc_atomic.cpp',
			'object.cpp',
			'msgpack.h',
			'msgpack.hpp',
			'objectc.c',
			'unpack.c',
			'version.c',
			'vrefbuffer.c',
			'zone.c',
		],			
	},],
}
