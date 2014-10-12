/*   Copyright (C) 2013-2014 Computer Sciences Corporation
 *
 * Licensed under the Apache License, Version 2.0 (the "License");
 * you may not use this file except in compliance with the License.
 * You may obtain a copy of the License at
 *
 *     http://www.apache.org/licenses/LICENSE-2.0
 *
 * Unless required by applicable law or agreed to in writing, software
 * distributed under the License is distributed on an "AS IS" BASIS,
 * WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
 * See the License for the specific language governing permissions and
 * limitations under the License. */

namespace py ezca
namespace java ezbake.ezca

include "ezbakeBaseService.thrift"
include "ezbakeBaseTypes.thrift"

const string SERVICE_NAME = "ezca"
service EzCA extends ezbakeBaseService.EzBakeBaseService {
  string csr(1:ezbakeBaseTypes.EzSecurityToken token, 2:string csr);
}
