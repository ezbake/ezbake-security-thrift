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

# @author Gary Drocella
# @date 05/21/14
# Time 9:20am
namespace java ezbake.security.lock.smith.thrift

include "ezbakeBaseTypes.thrift"
include "ezbakeBaseService.thrift"

typedef ezbakeBaseTypes.EzSecurityToken EzSecurityToken

enum KeyType {
     RSA,
     AES
}

exception KeyExistsException {
    1: string msg
}

exception KeyNotFoundException {
    1: string msg
}

const string SERVICE_NAME = "locksmith"
service EzLocksmith extends ezbakeBaseService.EzBakeBaseService {

    void generateKey(1:required EzSecurityToken ezToken, 2:required string keyId, 3:required KeyType type,
                     4:list<string> sharedWith
    ) throws (
        1:KeyExistsException keyExistsException,
        2:ezbakeBaseTypes.EzSecurityTokenException tokenException
    );

    void uploadKey(1:required EzSecurityToken ezToken, 2:required string keyId, 3:required string keyData,
                   4:required KeyType type ) throws (
            1:KeyExistsException keyExistsException,
            2:ezbakeBaseTypes.EzSecurityTokenException tokenException
    );

    string retrieveKey(1:required EzSecurityToken ezToken, 2:required string id, 3:required KeyType type) throws (
            1:KeyNotFoundException keyNotFoundException,
            2:KeyExistsException keyExistsException,
            3:ezbakeBaseTypes.EzSecurityTokenException tokenException
    );

    void removeKey(1:required EzSecurityToken ezToken, 2:required string id, 3:required KeyType type) throws (
            1:KeyNotFoundException keyNotFoundException,
            2:ezbakeBaseTypes.EzSecurityTokenException tokenException
    );


    string retrievePublicKey(1:required EzSecurityToken ezToken, 2:required string id, 3:string owner) throws (
            1:KeyNotFoundException keyNotFoundException,
            2:ezbakeBaseTypes.EzSecurityTokenException tokenException
    );
}
