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

namespace rb EzSecurity
namespace java ezbake.security.thrift
namespace py ezsecurity
namespace cpp ezsecurity
namespace js ezsecurity

include "ezbakeBaseService.thrift"
include "ezbakeBaseTypes.thrift"

typedef ezbakeBaseTypes.EzSecurityToken EzSecurityToken
typedef ezbakeBaseTypes.EzSecurityTokenJson EzSecurityTokenJSON
typedef ezbakeBaseTypes.EzSecurityPrincipal EzSecurityPrincipal
typedef ezbakeBaseTypes.TokenRequest TokenRequest
typedef ezbakeBaseTypes.ValidityCaveats ValidityCaveats
typedef ezbakeBaseTypes.X509Info X509Info

exception AppNotRegisteredException {
    1: string message
}
exception UserNotFoundException {
    1: string message
}

struct ProxyTokenRequest {
    1:X509Info x509
    5:ValidityCaveats validity
}
struct ProxyTokenResponse {
    1:required string token
    2:required string signature
}

const string SERVICE_NAME = "EzBakeSecurityService"
service EzSecurity extends ezbakeBaseService.EzBakeBaseService {

    /*
     * Initial user log in requires a proxy token. Right now proxy tokens are only issued to the frontend
     *
     * @param request the signed token request
     * @return a proxy token issued by EzSecurity
     */
    ProxyTokenResponse requestProxyToken(
        1:required ProxyTokenRequest request
    ) throws (
        1:ezbakeBaseTypes.EzSecurityTokenException ezSecurityTokenException,
        2:UserNotFoundException userNotFound)

    /*
     * Request tokens from EzSecurity. These can be inital token requests (app or user) as well as request
     * to forward a received token to another application
     *
     * @param request a request object generated with the requested information
     * @param signature the base64 encoded signature of the serialized request object
     */
    EzSecurityToken requestToken(
        1:required TokenRequest request,
        2:required string signature
    ) throws (
        1:ezbakeBaseTypes.EzSecurityTokenException ezSecurityTokenException,
        2:AppNotRegisteredException appNotRegistered
    )

    /*
     * Refresh an expired token
     *
     * @param request a token request that includes the expired token
     * @param signature the base64 encoded signature of the serialized request object
     * @return an updated token
     */
    EzSecurityToken refreshToken(
        1:required TokenRequest request,
        2:required string signature
    ) throws (
        1:ezbakeBaseTypes.EzSecurityTokenException ezSecurityTokenException,
        2:AppNotRegisteredException appNotRegistered
    )

    /*
     * Checks whether the given user id is valid
     *
     * @param ezSecurityToken a token issued by EzSecurity to the requesting app, with targetSecurityId EzSecurity
     * @param userId the user's id
     * @return true if the user is valid, otherwise false
     */
    bool isUserInvalid(1:required EzSecurityToken ezSecurityToken, 2:required string userId) throws (
        1:ezbakeBaseTypes.EzSecurityTokenException tokenException)


    EzSecurityTokenJSON requestUserInfoAsJson(
        1:required TokenRequest request,
        2:required string signature
    ) throws (
        1:ezbakeBaseTypes.EzSecurityTokenException ezSecurityTokenException
    )


    /*
     * This function can only be executed EzSecurity -> EzSecurity. It will reject other requests. Depends on SSL
     */
    bool updateEzAdmins(1:set<string> ezAdmins)

    /*
     * Wipe out any caches of external data that EzSecurity is maintining
     */
    void invalidateCache(1:required EzSecurityToken request) throws (
        1:ezbakeBaseTypes.EzSecurityTokenException ezSecurityTokenException
    )
}
