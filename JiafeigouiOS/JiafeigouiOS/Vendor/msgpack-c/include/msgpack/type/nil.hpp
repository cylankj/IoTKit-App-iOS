//
// MessagePack for C++ static resolution routine
//
// Copyright (C) 2008-2009 FURUHASHI Sadayuki
//
//    Licensed under the Apache License, Version 2.0 (the "License");
//    you may not use this file except in compliance with the License.
//    You may obtain a copy of the License at
//
//        http://www.apache.org/licenses/LICENSE-2.0
//
//    Unless required by applicable law or agreed to in writing, software
//    distributed under the License is distributed on an "AS IS" BASIS,
//    WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
//    See the License for the specific language governing permissions and
//    limitations under the License.
//
#ifndef MSGPACK_TYPE_NIL_HPP__
#define MSGPACK_TYPE_NIL_HPP__

#include "msgpack/object.hpp"

namespace msgpack {

namespace type {

struct nil_ { }; //lzp: nil is keyword of object-c

}  // namespace type


inline type::nil_& operator>> (object o, type::nil_& v)
{
	if(o.type != type::NIL) { throw type_error(); }
	return v;
}

template <typename Stream>
inline packer<Stream>& operator<< (packer<Stream>& o, const type::nil_& v)
{
	o.pack_nil();
	return o;
}

inline void operator<< (object& o, type::nil_ v)
{
	o.type = type::NIL;
}

inline void operator<< (object::with_zone& o, type::nil_ v)
	{ static_cast<object&>(o) << v; }


template <>
inline void object::as<void>() const
{
	msgpack::type::nil_ v;
	convert(&v);
}


}  // namespace msgpack

#endif /* msgpack/type/nil.hpp */

