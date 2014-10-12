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
# @date 03/10/14
# Time: 5:37PM
namespace java ezbake.security.thrift

include "ezbakeBaseTypes.thrift"
include "ezbakeBaseService.thrift"


enum RegistrationStatus {
   PENDING,   # new or updated Registration
   ACTIVE,    # approved application
   DENIED
}

struct ApplicationRegistration {
   1: string id
   2: string owner
   3: string appName
   4: string classification
   5: list<string> authorizations
   10: list<string> communityAuthorizations
   6: RegistrationStatus status
   7: set<string> admins
   8: string appDn
   9:optional string message
}

struct AppCerts {
   1: binary application_priv
   2: binary application_pub
   3: binary application_crt
   4: binary application_p12
   5: binary ezbakeca_crt
   6: binary ezbakeca_jks
   7: binary ezbakesecurityservice_pub
}

exception RegistrationException {
   1: string message
}

exception SecurityIDNotFoundException {
   1: string message
}

exception SecurityIDExistsException {
   1: string message
}

exception PermissionDeniedException {
   1:string message
}

exception AdminNotFoundException {
   1:string message
}

const string SERVICE_NAME = "EzSecurityRegistration"

service EzSecurityRegistration extends ezbakeBaseService.EzBakeBaseService {

   /**
    * Creates a New Application in the EzSecurity Registration database
    *
    * EzSecurityToken    - required token issued by EzSecurity. Will be verified
    * appName            - the application name
    * classification     - classification level of the application
    * authorizations     - list of all authorizations application is authorized for
    * ID                 - optional, if not provided one will be generated
    * admins             - optional, set of user DNs for users who should be allowed to administer this application
    *
    * Returns: the security ID of the registration
    *
    * Throws: RegistrationException if passed ID already exists
    */
    string registerApp(
        1:required ezbakeBaseTypes.EzSecurityToken ezToken,
        2:required string appName,
        3:required string classification,
        4:required list<string> authorizations,
        8:list<string> communityAuthorizations,
        5:string id,
        6:set<string> admins,
        7:string appDn
    ) throws (1:RegistrationException regException, 2:SecurityIDExistsException sidException)

   /**
    * Promotes An Application
    * Must be an admin to use this method
    *
    *  EzSecurityToken    - required token issued by EzSecurity. Will be verified
    *  ID                 - security ID of application being promoted
    *
    * throws:
    *    RegistraitonException - if user is not an admin or registraion does not exist
    */
    void promote(
        1:required ezbakeBaseTypes.EzSecurityToken ezToken,
        2:required string id
    ) throws (1:RegistrationException regException, 2:SecurityIDNotFoundException sidnfException, 3:PermissionDeniedException pdException)

    /**
    * Demotes An Application - sets application status to pending. Application can be re-promoted
    * Must be an admin to use this method
    *
    *  EzSecurityToken    - required token issued by EzSecurity. Will be verified
    *  ID                 - security ID of application being demoted
    *
    * throws:
    *    RegistraitonException - if user is not an admin or registraion does not exist
    */
    void demote(
        1:required ezbakeBaseTypes.EzSecurityToken ezToken,
        2:required string id
    ) throws (1:RegistrationException regException, 2:SecurityIDNotFoundException sidnfException)

   /**
    * Denies An Application
    * Must be an admin to use this method
    *
    *  EzSecurityToken    - required token issued by EzSecurity. Will be verified
    *  ID                 - security ID of application being unregistered
    *
    * throws:
    *    RegistraitonException - if user is not an admin or registraion does not exist
    */
    void denyApp(
        1:required ezbakeBaseTypes.EzSecurityToken ezToken,
        2:required string id
    ) throws (1:RegistrationException regException, 2:SecurityIDNotFoundException sidnfException, 3:PermissionDeniedException pdException)

    /**
    * Deletes an application registration
    *
    * Must be the application owner or EzAdmin to call this method. Can only delete an app that is pending or denied
    **/
    void deleteApp(
        1:required ezbakeBaseTypes.EzSecurityToken securityToken,
        2:required string id
    ) throws (1:RegistrationException regException, 2:SecurityIDNotFoundException sidnfException, 3:PermissionDeniedException pdException)

   /**
    * Updates metadata associated with a registered application
    *
    * Puts the updated application into pending status
    *
    * EzSecurityToken         - required token issued by EzSecurity. Will be verified
    * ApplicationRegistration - ApplicationRegistration with updates
    *
    * throws:
    *    RegistraitonException - if registraion does not exist, or unallowed updates requsted
    */
    void update(
        1:required ezbakeBaseTypes.EzSecurityToken ezToken,
        2:required ApplicationRegistration registration
    ) throws (1:RegistrationException regException, 2:SecurityIDNotFoundException sidnfException)

   /**
    *  Retrieves an Application Registration, regardless of status
    *
    * EzSecurityToken    - required token issued by EzSecurity. Will be verified
    * ID                 - security ID of application being queried
    *
    * throws:
    *    RegistraitonException - if registraion does not exist
    */
    ApplicationRegistration getRegistration(
        1:required ezbakeBaseTypes.EzSecurityToken ezToken,
        2:required string id
    ) throws (1:RegistrationException regException, 2:SecurityIDNotFoundException sidnfException, 3:PermissionDeniedException pemException)

   /**
    *  Retrieves Registration Status for a given security ID
    *
    * EzSecurityToken    - required token issued by EzSecurity. Will be verified
    * ID                 - security ID of application being queried
    *
    * throws:
    *    RegistraitonException - if registraion does not exist
    */
    RegistrationStatus getStatus(
        1:required ezbakeBaseTypes.EzSecurityToken ezToken,
        2:required string id
    ) throws (1:RegistrationException regException, 2:SecurityIDNotFoundException sidnfException)

   /**
    *  Retrieves all Application Registration, owned by a user
    *
    * EzSecurityToken    - required token issued by EzSecurity. Will be verified
    *
    * throws:
    *    RegistraitonException - if registraion does not exist, or other errors
    */
    list<ApplicationRegistration> getRegistrations(
        1:required ezbakeBaseTypes.EzSecurityToken ezToken
    ) throws (1:RegistrationException regException)


   /**
    *  Retrieves all Application Registration, optionally filtered by status.
    *  Admins can see registrations they don't own, but if a non-admin user
    *  calls this method, they will only see registrations they own.
    *
    * EzSecurityToken    - required token issued by EzSecurity. Will be verified
    *
    * throws:
    *    RegistraitonException - if registraion does not exist, or other errors
    */
    list<ApplicationRegistration> getAllRegistrations(
        1:required ezbakeBaseTypes.EzSecurityToken ezToken,
        2:RegistrationStatus status
    ) throws (1:RegistrationException regException)

    /**
     *
     */
    AppCerts getAppCerts(1:required ezbakeBaseTypes.EzSecurityToken ezToken,
                         2:required string id)
        throws (1:RegistrationException regException, 2:SecurityIDNotFoundException sidnfException)


    void addAdmin(1:required ezbakeBaseTypes.EzSecurityToken ezToken,
    	 	  2:required string id, 3:required string admin) throws (1:PermissionDeniedException pdException, 2:SecurityIDNotFoundException sidnfException
		  	     	    		   	  	 	 3:RegistrationException rException)

    void removeAdmin(1:required ezbakeBaseTypes.EzSecurityToken ezToken,
    	 	     2:required string id,
		     3:required string admin) throws (1:PermissionDeniedException pdException, 2:SecurityIDNotFoundException sidnfException,
		     		       	      	      3:RegistrationException rException)

}
